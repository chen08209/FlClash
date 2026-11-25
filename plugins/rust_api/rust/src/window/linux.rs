use super::{emit, screens, GEOMETRY_SETTLE_MILLISECONDS};
use crate::api::window::{
    TitleBarStyle, WindowBounds, WindowBrightness, WindowDisplay, WindowEffect, WindowPoint,
    WindowSignal,
};
use futures_util::StreamExt;
use gdk_sys::{
    GdkEvent, GdkEventWindowState, GdkRectangle, GdkScreen, GdkWindow, GDK_BUTTON_PRESS,
    GDK_BUTTON_PRIMARY, GDK_TOUCH_BEGIN, GDK_WINDOW_STATE_FOCUSED, GDK_WINDOW_STATE_FULLSCREEN,
    GDK_WINDOW_STATE_ICONIFIED, GDK_WINDOW_STATE_MAXIMIZED,
};
use glib_sys::{gboolean, gpointer, GFALSE, GTRUE};
use gobject_sys::{GObject, GSignalInvocationHint, GValue, G_CONNECT_AFTER, G_SIGNAL_MATCH_DATA};
use gtk_sys::{GtkContainer, GtkWidget, GtkWindow};
use std::cell::Cell;
use std::ffi::{c_char, c_uint, c_void, CStr};
use std::ptr::{null, null_mut};
use std::sync::{mpsc, Once};

const ACTIVATE_ACTION: &CStr = c"activate-window";
const OPEN_LINK_ACTION: &CStr = c"open-link";
// Coupled to linux/runner/my_application.cc, which holds a relaunch's links
// there until this module adds the action.
const PENDING_LINKS: &CStr = c"flclash-pending-links";
const MINIMIZE_FOCUS_LOSS_MICROSECONDS: i64 = 500_000;
const MAX_RESTORE_CORRECTIONS: u32 = 5;
const LOGIN1: &str = "org.freedesktop.login1";
const UNSEEN_LOCKED: u8 = 1;
const UNSEEN_SCREENSAVER: u8 = 1 << 1;
// GNOME serves its own name; KDE and the rest serve the freedesktop one.
const SCREENSAVERS: [(&str, &str, &str); 2] = [
    (
        "org.gnome.ScreenSaver",
        "/org/gnome/ScreenSaver",
        "org.gnome.ScreenSaver",
    ),
    (
        "org.freedesktop.ScreenSaver",
        "/ScreenSaver",
        "org.freedesktop.ScreenSaver",
    ),
];

#[link(name = "gdk-3")]
extern "C" {
    fn gdk_x11_window_get_type() -> glib_sys::GType;
    fn gdk_x11_screen_get_type() -> glib_sys::GType;
    fn gdk_x11_get_server_time(window: *mut GdkWindow) -> u32;
}

#[derive(Clone, Copy, PartialEq, Eq)]
struct Geometry {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
}

struct State {
    window: Cell<*mut GtkWindow>,
    view: Cell<*mut GtkWidget>,
    event_box: Cell<*mut GtkWidget>,
    prevent_close: Cell<bool>,
    always_on_top: Cell<bool>,
    title_bar_hidden: Cell<bool>,
    minimize_requested_at: Cell<i64>,
    saved: Cell<Option<Geometry>>,
    restore_timeout: Cell<c_uint>,
    restore_corrections: Cell<u32>,
    settled: Cell<Option<Geometry>>,
    settle_timeout: Cell<c_uint>,
    press: Cell<*mut GdkEvent>,
    unseen: Cell<u8>,
}

thread_local! {
    static STATE: State = const {
        State {
            window: Cell::new(null_mut()),
            view: Cell::new(null_mut()),
            event_box: Cell::new(null_mut()),
            prevent_close: Cell::new(false),
            always_on_top: Cell::new(false),
            title_bar_hidden: Cell::new(false),
            minimize_requested_at: Cell::new(0),
            saved: Cell::new(None),
            restore_timeout: Cell::new(0),
            restore_corrections: Cell::new(0),
            settled: Cell::new(None),
            settle_timeout: Cell::new(0),
            press: Cell::new(null_mut()),
            unseen: Cell::new(0),
        }
    };
}

type Job = Box<dyn FnOnce() + Send>;

unsafe extern "C" fn run_job(data: gpointer) -> gboolean {
    let job = Box::from_raw(data.cast::<Job>());
    job();
    GFALSE
}

fn post(job: Job) {
    let data = Box::into_raw(Box::new(job)).cast();
    unsafe {
        glib_sys::g_idle_add_full(glib_sys::G_PRIORITY_DEFAULT, Some(run_job), data, None);
    }
}

fn on_main_thread() -> bool {
    unsafe { glib_sys::g_main_context_is_owner(glib_sys::g_main_context_default()) != GFALSE }
}

fn on_main<T, F>(f: F) -> Result<T, String>
where
    T: Send + 'static,
    F: FnOnce(&State) -> Result<T, String> + Send + 'static,
{
    if on_main_thread() {
        return STATE.with(f);
    }
    let (tx, rx) = mpsc::channel();
    post(Box::new(move || {
        let _ = tx.send(STATE.with(f));
    }));
    rx.recv()
        .map_err(|_| "The main loop dropped the call".to_owned())?
}

unsafe fn is_a(instance: *mut c_void, gtype: glib_sys::GType) -> bool {
    !instance.is_null() && gobject_sys::g_type_check_instance_is_a(instance.cast(), gtype) != GFALSE
}

unsafe fn connect(instance: *mut c_void, signal: &CStr, handler: *const (), after: bool) {
    let flags = if after { G_CONNECT_AFTER } else { 0 };
    gobject_sys::g_signal_connect_data(
        instance.cast(),
        signal.as_ptr(),
        Some(std::mem::transmute::<*const (), unsafe extern "C" fn()>(
            handler,
        )),
        null_mut(),
        None,
        flags,
    );
}

impl State {
    fn set_unseen(&self, reason: u8, unseen: bool) {
        let before = self.unseen.get();
        let after = if unseen {
            before | reason
        } else {
            before & !reason
        };
        self.unseen.set(after);
        if (before == 0) != (after == 0) {
            emit(if after == 0 {
                WindowSignal::ScreensSeen
            } else {
                WindowSignal::ScreensUnseen
            });
        }
    }

    fn require_window(&self) -> Result<*mut GtkWindow, String> {
        let window = self.window.get();
        if window.is_null() {
            Err("ensureInitialized has not run".into())
        } else {
            Ok(window)
        }
    }

    fn gdk_window(&self) -> *mut GdkWindow {
        let window = self.window.get();
        if window.is_null() {
            return null_mut();
        }
        unsafe { gtk_sys::gtk_widget_get_window(window.cast()) }
    }

    fn has_state(&self, flag: gdk_sys::GdkWindowState) -> bool {
        let gdk_window = self.gdk_window();
        !gdk_window.is_null() && unsafe { gdk_sys::gdk_window_get_state(gdk_window) } & flag != 0
    }

    fn geometry(&self) -> Option<Geometry> {
        let window = self.window.get();
        if window.is_null() {
            return None;
        }
        let mut geometry = Geometry {
            x: 0,
            y: 0,
            width: 0,
            height: 0,
        };
        unsafe {
            gtk_sys::gtk_window_get_position(window, &mut geometry.x, &mut geometry.y);
            gtk_sys::gtk_window_get_size(window, &mut geometry.width, &mut geometry.height);
        }
        Some(geometry)
    }

    fn is_geometry_owned_by_wm(&self) -> bool {
        let window = self.window.get();
        window.is_null()
            || unsafe { gtk_sys::gtk_window_is_maximized(window) } != GFALSE
            || self.has_state(GDK_WINDOW_STATE_FULLSCREEN)
    }

    fn apply_geometry(&self, geometry: Geometry) {
        let window = self.window.get();
        if window.is_null() {
            return;
        }
        unsafe {
            gtk_sys::gtk_window_move(window, geometry.x, geometry.y);
            gtk_sys::gtk_window_resize(window, geometry.width, geometry.height);
        }
    }

    // GTK drops an unmapped window's placement; the next map reapplies it.
    fn hide_saving_geometry(&self) {
        let window = self.window.get();
        let saved = (!self.is_geometry_owned_by_wm())
            .then(|| self.geometry())
            .flatten();
        self.saved.set(saved);
        unsafe { gtk_sys::gtk_widget_hide(window.cast()) };
        if let Some(saved) = saved {
            self.apply_geometry(saved);
        }
    }

    fn saved_is_on_a_monitor(&self, saved: Geometry) -> bool {
        unsafe {
            let display =
                gdk_sys::gdk_screen_get_display(gtk_sys::gtk_window_get_screen(self.window.get()));
            let rectangle = GdkRectangle {
                x: saved.x,
                y: saved.y,
                width: saved.width,
                height: saved.height,
            };
            (0..gdk_sys::gdk_display_get_n_monitors(display)).any(|index| {
                let mut workarea: GdkRectangle = std::mem::zeroed();
                gdk_sys::gdk_monitor_get_workarea(
                    gdk_sys::gdk_display_get_monitor(display, index),
                    &mut workarea,
                );
                gdk_sys::gdk_rectangle_intersect(&rectangle, &workarea, null_mut()) != GFALSE
            })
        }
    }

    fn center_on_primary_monitor(&self, size: Geometry) {
        let window = self.window.get();
        unsafe {
            gtk_sys::gtk_window_resize(window, size.width, size.height);
            let display = gdk_sys::gdk_screen_get_display(gtk_sys::gtk_window_get_screen(window));
            let mut monitor = gdk_sys::gdk_display_get_primary_monitor(display);
            if monitor.is_null() {
                monitor = gdk_sys::gdk_display_get_monitor(display, 0);
            }
            if monitor.is_null() {
                return;
            }
            let mut workarea: GdkRectangle = std::mem::zeroed();
            gdk_sys::gdk_monitor_get_workarea(monitor, &mut workarea);
            gtk_sys::gtk_window_move(
                window,
                workarea.x + ((workarea.width - size.width) / 2).max(0),
                workarea.y + ((workarea.height - size.height) / 2).max(0),
            );
        }
    }

    // The window manager may place the window after the map handler restored
    // it, so the restore stays open until the placement settles.
    fn on_map(&self) {
        let Some(saved) = self.saved.get() else {
            return;
        };
        if !self.saved_is_on_a_monitor(saved) {
            self.saved.set(None);
            self.center_on_primary_monitor(saved);
            return;
        }
        self.restore_corrections.set(0);
        self.apply_geometry(saved);
        replace_timeout(&self.restore_timeout, on_restore_settled);
    }

    fn correct_restored_placement(&self) {
        let Some(saved) = self.saved.get() else {
            return;
        };
        if self.restore_timeout.get() == 0
            || self.restore_corrections.get() >= MAX_RESTORE_CORRECTIONS
        {
            return;
        }
        let Some(current) = self.geometry() else {
            return;
        };
        if (current.x, current.y) == (saved.x, saved.y) {
            return;
        }
        self.restore_corrections
            .set(self.restore_corrections.get() + 1);
        self.apply_geometry(saved);
    }

    fn present(&self) {
        let window = self.window.get();
        unsafe {
            // A tray click reaches the app over D-Bus with no input event, so a
            // plain present carries a stale user time and Mutter refuses focus.
            let gdk_window = self.gdk_window();
            if is_a(gdk_window.cast(), gdk_x11_window_get_type()) {
                gtk_sys::gtk_window_present_with_time(window, gdk_x11_get_server_time(gdk_window));
            } else {
                gtk_sys::gtk_window_present(window);
            }
        }
    }

    fn apply_title_bar(&self) {
        let window = self.window.get();
        let normal = !self.title_bar_hidden.get();
        unsafe {
            let header_bar = header_bar(window);
            if !header_bar.is_null() {
                gtk_sys::gtk_widget_set_visible(header_bar, gboolean::from(normal));
                if is_a(header_bar.cast(), gtk_sys::gtk_header_bar_get_type()) {
                    gtk_sys::gtk_header_bar_set_show_close_button(header_bar.cast(), GTRUE);
                }
            } else if !gtk_sys::gtk_window_get_title(window).is_null() {
                gtk_sys::gtk_window_set_decorated(window, gboolean::from(normal));
            }
            if normal {
                gtk_sys::gtk_window_set_decorated(window, GTRUE);
            }
        }
    }
}

fn replace_timeout(slot: &Cell<c_uint>, callback: unsafe extern "C" fn(gpointer) -> gboolean) {
    unsafe {
        if slot.get() != 0 {
            glib_sys::g_source_remove(slot.get());
        }
        slot.set(glib_sys::g_timeout_add(
            GEOMETRY_SETTLE_MILLISECONDS,
            Some(callback),
            null_mut(),
        ));
    }
}

unsafe extern "C" fn on_restore_settled(_: gpointer) -> gboolean {
    STATE.with(|state| {
        state.restore_timeout.set(0);
        if let Some(saved) = state.saved.take() {
            state.apply_geometry(saved);
        }
    });
    GFALSE
}

unsafe extern "C" fn on_settle_timeout(_: gpointer) -> gboolean {
    STATE.with(|state| {
        state.settle_timeout.set(0);
        let Some(current) = state.geometry() else {
            return;
        };
        if state
            .settled
            .replace(Some(current))
            .is_some_and(|settled| settled != current)
        {
            emit(WindowSignal::GeometryChanged);
        }
    });
    GFALSE
}

unsafe fn type_name_ends_with(widget: *mut GtkWidget, suffix: &str) -> bool {
    let name = gobject_sys::g_type_name_from_instance(widget.cast());
    !name.is_null() && CStr::from_ptr(name).to_bytes().ends_with(suffix.as_bytes())
}

unsafe fn is_header_bar(widget: *mut GtkWidget) -> bool {
    !widget.is_null()
        && (is_a(widget.cast(), gtk_sys::gtk_header_bar_get_type())
            || type_name_ends_with(widget, "HeaderBar"))
}

unsafe fn find_header_bar(widget: *mut GtkWidget) -> *mut GtkWidget {
    if is_header_bar(widget) {
        return widget;
    }
    if !is_a(widget.cast(), gtk_sys::gtk_container_get_type()) {
        return null_mut();
    }
    let children = gtk_sys::gtk_container_get_children(widget.cast());
    let mut found: *mut GtkWidget = null_mut();
    let mut node = children;
    while !node.is_null() && found.is_null() {
        found = find_header_bar((*node).data.cast());
        node = (*node).next;
    }
    glib_sys::g_list_free(children);
    found
}

unsafe fn header_bar(window: *mut GtkWindow) -> *mut GtkWidget {
    let titlebar = gtk_sys::gtk_window_get_titlebar(window);
    if is_header_bar(titlebar) {
        titlebar
    } else {
        find_header_bar(window.cast())
    }
}

unsafe extern "C" fn on_delete(_: *mut GtkWidget, _: *mut GdkEvent, _: gpointer) -> gboolean {
    emit(WindowSignal::Close);
    gboolean::from(STATE.with(|state| state.prevent_close.get()))
}

// A re-shown window stays black on Wayland until the engine's renderer, inside
// the view, is allocated again; see .agents/flutter-upgrade.md.
unsafe extern "C" fn on_map_event(_: *mut GtkWidget, _: *mut GdkEvent, _: gpointer) -> gboolean {
    STATE.with(|state| {
        let view = state.view.get();
        if !view.is_null() {
            queue_resize_tree(view, null_mut());
        }
        state.on_map();
    });
    GFALSE
}

// GTK skips allocating a child whose allocation did not change unless the child
// itself was queued.
unsafe extern "C" fn queue_resize_tree(widget: *mut GtkWidget, _: gpointer) {
    gtk_sys::gtk_widget_queue_resize(widget);
    if is_a(widget.cast(), gtk_sys::gtk_container_get_type()) {
        gtk_sys::gtk_container_forall(widget.cast(), Some(queue_resize_tree), null_mut());
    }
}

unsafe extern "C" fn on_configure(_: *mut GtkWidget, _: *mut GdkEvent, _: gpointer) -> gboolean {
    STATE.with(|state| {
        state.correct_restored_placement();
        replace_timeout(&state.settle_timeout, on_settle_timeout);
    });
    GFALSE
}

// Wayland has no minimized state, so the engine reads a minimize as a focus
// loss; one within 500 ms of `minimize` is reported as hidden.
unsafe extern "C" fn on_window_state(
    _: *mut GtkWidget,
    event: *mut GdkEventWindowState,
    _: gpointer,
) -> gboolean {
    let (changed, new) = ((*event).changed_mask, (*event).new_window_state);
    STATE.with(|state| {
        let requested = state.minimize_requested_at.get();
        if requested != 0 && changed & GDK_WINDOW_STATE_FOCUSED != 0 {
            state.minimize_requested_at.set(0);
            let elapsed = glib_sys::g_get_monotonic_time() - requested;
            if new & GDK_WINDOW_STATE_FOCUSED == 0 && elapsed < MINIMIZE_FOCUS_LOSS_MICROSECONDS {
                emit(WindowSignal::LifecycleHidden);
            }
        }
    });
    let transitions = [
        (
            GDK_WINDOW_STATE_MAXIMIZED,
            WindowSignal::Maximize,
            WindowSignal::Unmaximize,
        ),
        (
            GDK_WINDOW_STATE_ICONIFIED,
            WindowSignal::Minimize,
            WindowSignal::Restore,
        ),
        (
            GDK_WINDOW_STATE_FULLSCREEN,
            WindowSignal::EnterFullScreen,
            WindowSignal::LeaveFullScreen,
        ),
    ];
    for (flag, entered, left) in transitions {
        if changed & flag != 0 {
            emit(if new & flag != 0 { entered } else { left });
        }
    }
    GFALSE
}

// Flutter's view consumes the press before any per-window handler, so a global
// emission hook records it for the move drag.
unsafe extern "C" fn on_press(
    _: *mut GSignalInvocationHint,
    _: c_uint,
    values: *const GValue,
    _: gpointer,
) -> gboolean {
    let emitter = gobject_sys::g_value_get_object(values);
    STATE.with(|state| {
        let view = state.view.get();
        if view.is_null()
            || (emitter != view.cast::<GObject>()
                && emitter != state.event_box.get().cast::<GObject>())
        {
            return;
        }
        let event = gobject_sys::g_value_get_boxed(values.add(1)).cast::<GdkEvent>();
        if event.is_null() {
            return;
        }
        let kind = gdk_sys::gdk_event_get_event_type(event);
        if kind != GDK_BUTTON_PRESS && kind != GDK_TOUCH_BEGIN {
            return;
        }
        let previous = state.press.replace(gdk_sys::gdk_event_copy(event));
        if !previous.is_null() {
            gdk_sys::gdk_event_free(previous);
        }
    });
    GTRUE
}

unsafe extern "C" fn collect_event_box(widget: *mut GtkWidget, data: gpointer) {
    if is_a(widget.cast(), gtk_sys::gtk_event_box_get_type()) {
        *data.cast::<*mut GtkWidget>() = widget;
    }
}

unsafe fn find_flutter_window() -> Option<(*mut GtkWindow, *mut GtkWidget)> {
    let toplevels = gtk_sys::gtk_window_list_toplevels();
    let mut found = None;
    let mut node = toplevels;
    while !node.is_null() && found.is_none() {
        let window = (*node).data.cast::<GtkWindow>();
        let child = gtk_sys::gtk_bin_get_child(window.cast());
        if !child.is_null() && type_name_ends_with(child, "FlView") {
            found = Some((window, child));
        }
        node = (*node).next;
    }
    glib_sys::g_list_free(toplevels);
    found
}

unsafe fn attach(state: &State, window: *mut GtkWindow, view: *mut GtkWidget) {
    // The engine's delete-event handler consumes the signal first
    // (flutter/engine#40033).
    let engine_handler = gobject_sys::g_signal_handler_find(
        window.cast(),
        G_SIGNAL_MATCH_DATA,
        0,
        0,
        null_mut(),
        null_mut(),
        view.cast(),
    );
    if engine_handler > 0 {
        gobject_sys::g_signal_handler_disconnect(window.cast(), engine_handler);
    }
    connect(
        window.cast(),
        c"delete-event",
        on_delete as *const (),
        false,
    );
    connect(
        window.cast(),
        c"map-event",
        on_map_event as *const (),
        false,
    );
    connect(
        window.cast(),
        c"configure-event",
        on_configure as *const (),
        false,
    );
    // After the engine's lifecycle monitor, so a minimize reads as hidden.
    connect(
        window.cast(),
        c"window-state-event",
        on_window_state as *const (),
        true,
    );

    let mut event_box: *mut GtkWidget = null_mut();
    gtk_sys::gtk_container_forall(
        view.cast::<GtkContainer>(),
        Some(collect_event_box),
        (&mut event_box as *mut *mut GtkWidget).cast(),
    );
    if !event_box.is_null() {
        state.event_box.set(event_box);
        gobject_sys::g_object_add_weak_pointer(event_box.cast(), state.event_box.as_ptr().cast());
    }
    for signal in [c"button-press-event", c"touch-event"] {
        gobject_sys::g_signal_add_emission_hook(
            gobject_sys::g_signal_lookup(signal.as_ptr(), gtk_sys::gtk_widget_get_type()),
            0,
            Some(on_press),
            null_mut(),
            None,
        );
    }
}

unsafe extern "C" fn on_activate_action(_: *mut c_void, _: *mut glib_sys::GVariant, _: gpointer) {
    emit(WindowSignal::Activate);
}

pub(super) fn observe() {
    static OBSERVE: Once = Once::new();
    OBSERVE.call_once(|| {
        watch_screens();
        post(Box::new(|| unsafe {
            let application = gio_sys::g_application_get_default();
            if application.is_null() {
                return;
            }
            let action = gio_sys::g_simple_action_new(ACTIVATE_ACTION.as_ptr(), null());
            connect(
                action.cast(),
                c"activate",
                on_activate_action as *const (),
                false,
            );
            gio_sys::g_action_map_add_action(application.cast(), action.cast());
            gobject_sys::g_object_unref(action.cast());
        }));
    });
}

fn watch_screens() {
    let Ok(runtime) = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
    else {
        return;
    };
    let _ = std::thread::Builder::new()
        .name("screens".into())
        .spawn(move || {
            runtime.block_on(async {
                let _ = tokio::join!(follow_session_lock(), follow_screensaver());
            })
        });
}

// The app runs outside the login session, in its own scope or a service's, so
// the session is the display of the user the uid names.
async fn follow_session_lock() -> zbus::Result<()> {
    let connection = zbus::Connection::system().await?;
    let manager = zbus::Proxy::new(
        &connection,
        LOGIN1,
        "/org/freedesktop/login1",
        "org.freedesktop.login1.Manager",
    )
    .await?;
    let user: zbus::zvariant::OwnedObjectPath = manager
        .call("GetUser", &(unsafe { libc::getuid() }))
        .await?;
    let user = zbus::Proxy::new(&connection, LOGIN1, user, "org.freedesktop.login1.User").await?;
    let (_, session): (String, zbus::zvariant::OwnedObjectPath) =
        user.get_property("Display").await?;
    let session = zbus::Proxy::new(
        &connection,
        LOGIN1,
        session,
        "org.freedesktop.login1.Session",
    )
    .await?;
    let changes = session.receive_property_changed::<bool>("LockedHint").await;
    let readings = changes.filter_map(|change| async move { change.get().await.ok() });
    screens::follow(readings, |locked| post_unseen(UNSEEN_LOCKED, locked)).await;
    Ok(())
}

// A blanked screen is unseen before any lock, and some desktops never set
// logind's LockedHint at all.
async fn follow_screensaver() -> zbus::Result<()> {
    let connection = zbus::Connection::session().await?;
    for (name, path, interface) in SCREENSAVERS {
        let Ok(screensaver) = zbus::Proxy::new(&connection, name, path, interface).await else {
            continue;
        };
        let Ok(changes) = screensaver.receive_signal("ActiveChanged").await else {
            continue;
        };
        let Ok(active) = screensaver.call::<_, _, bool>("GetActive", &()).await else {
            continue;
        };
        let readings =
            futures_util::stream::once(std::future::ready(active))
                .chain(changes.filter_map(|message| async move {
                    message.body().deserialize::<bool>().ok()
                }));
        screens::follow(readings, |active| post_unseen(UNSEEN_SCREENSAVER, active)).await;
        return Ok(());
    }
    Ok(())
}

fn post_unseen(reason: u8, unseen: bool) {
    post(Box::new(move || {
        STATE.with(|state| state.set_unseen(reason, unseen))
    }));
}

unsafe extern "C" fn on_open_link_action(
    _: *mut c_void,
    parameter: *mut glib_sys::GVariant,
    _: gpointer,
) {
    if !parameter.is_null() {
        let link = glib_sys::g_variant_get_string(parameter, null_mut());
        super::link::push(CStr::from_ptr(link).to_string_lossy().into_owned());
    }
}

pub(super) fn observe_links() {
    static OBSERVE: Once = Once::new();
    OBSERVE.call_once(|| {
        post(Box::new(|| unsafe {
            let application = gio_sys::g_application_get_default();
            if application.is_null() {
                return;
            }
            let pending: *mut glib_sys::GPtrArray =
                gobject_sys::g_object_steal_data(application.cast(), PENDING_LINKS.as_ptr()).cast();
            if !pending.is_null() {
                for index in 0..(*pending).len as usize {
                    let link: *const c_char = (*(*pending).pdata.add(index)).cast();
                    super::link::push(CStr::from_ptr(link).to_string_lossy().into_owned());
                }
                glib_sys::g_ptr_array_unref(pending);
            }
            let action = gio_sys::g_simple_action_new(
                OPEN_LINK_ACTION.as_ptr(),
                c"s".as_ptr().cast::<glib_sys::GVariantType>(),
            );
            connect(
                action.cast(),
                c"activate",
                on_open_link_action as *const (),
                false,
            );
            gio_sys::g_action_map_add_action(application.cast(), action.cast());
            gobject_sys::g_object_unref(action.cast());
        }));
    });
}

pub fn ensure_initialized() -> Result<(), String> {
    on_main(|state| {
        if !state.window.get().is_null() {
            return Ok(());
        }
        let (window, view) = unsafe { find_flutter_window() }
            .ok_or_else(|| "No window hosts the Flutter view".to_owned())?;
        state.window.set(window);
        state.view.set(view);
        unsafe { attach(state, window, view) };
        Ok(())
    })
}

pub fn show() -> Result<(), String> {
    on_main(|state| {
        unsafe { gtk_sys::gtk_widget_show(state.require_window()?.cast()) };
        Ok(())
    })
}

pub fn hide() -> Result<(), String> {
    on_main(|state| {
        state.require_window()?;
        state.hide_saving_geometry();
        Ok(())
    })
}

pub fn is_visible() -> Result<bool, String> {
    on_main(|state| {
        let window = state.window.get();
        Ok(!window.is_null() && unsafe { gtk_sys::gtk_widget_is_visible(window.cast()) } != GFALSE)
    })
}

pub fn focus() -> Result<(), String> {
    on_main(|state| {
        state.require_window()?;
        state.present();
        Ok(())
    })
}

pub fn close() -> Result<(), String> {
    on_main(|state| {
        unsafe { gtk_sys::gtk_window_close(state.require_window()?) };
        Ok(())
    })
}

pub fn set_prevent_close(value: bool) -> Result<(), String> {
    on_main(move |state| {
        state.prevent_close.set(value);
        Ok(())
    })
}

pub fn is_maximized() -> Result<bool, String> {
    on_main(|state| {
        let window = state.window.get();
        Ok(!window.is_null() && unsafe { gtk_sys::gtk_window_is_maximized(window) } != GFALSE)
    })
}

pub fn maximize() -> Result<(), String> {
    on_main(|state| {
        unsafe { gtk_sys::gtk_window_maximize(state.require_window()?) };
        Ok(())
    })
}

pub fn unmaximize() -> Result<(), String> {
    on_main(|state| {
        unsafe { gtk_sys::gtk_window_unmaximize(state.require_window()?) };
        Ok(())
    })
}

pub fn is_minimized() -> Result<bool, String> {
    on_main(|state| Ok(state.has_state(GDK_WINDOW_STATE_ICONIFIED)))
}

pub fn minimize() -> Result<(), String> {
    on_main(|state| {
        unsafe { gtk_sys::gtk_window_iconify(state.require_window()?) };
        state
            .minimize_requested_at
            .set(unsafe { glib_sys::g_get_monotonic_time() });
        Ok(())
    })
}

pub fn is_full_screen() -> Result<bool, String> {
    on_main(|state| Ok(state.has_state(GDK_WINDOW_STATE_FULLSCREEN)))
}

pub fn set_full_screen(value: bool) -> Result<(), String> {
    on_main(move |state| {
        let window = state.require_window()?;
        unsafe {
            if value {
                gtk_sys::gtk_window_fullscreen(window);
            } else {
                gtk_sys::gtk_window_unfullscreen(window);
            }
        }
        Ok(())
    })
}

pub fn get_bounds() -> Result<WindowBounds, String> {
    on_main(|state| {
        state.require_window()?;
        let geometry = state.geometry().unwrap_or(Geometry {
            x: 0,
            y: 0,
            width: 0,
            height: 0,
        });
        Ok(WindowBounds {
            x: f64::from(geometry.x),
            y: f64::from(geometry.y),
            width: f64::from(geometry.width),
            height: f64::from(geometry.height),
        })
    })
}

fn bounds(rectangle: GdkRectangle) -> WindowBounds {
    WindowBounds {
        x: f64::from(rectangle.x),
        y: f64::from(rectangle.y),
        width: f64::from(rectangle.width),
        height: f64::from(rectangle.height),
    }
}

// GDK has no primary monitor on Wayland; the first one stands in for it.
pub fn get_displays() -> Result<Vec<WindowDisplay>, String> {
    on_main(|_| unsafe {
        let display = gdk_sys::gdk_display_get_default();
        if display.is_null() {
            return Ok(Vec::new());
        }
        let primary = gdk_sys::gdk_display_get_primary_monitor(display);
        Ok((0..gdk_sys::gdk_display_get_n_monitors(display))
            .map(|index| {
                let monitor = gdk_sys::gdk_display_get_monitor(display, index);
                let (mut frame, mut workarea): (GdkRectangle, GdkRectangle) =
                    (std::mem::zeroed(), std::mem::zeroed());
                gdk_sys::gdk_monitor_get_geometry(monitor, &mut frame);
                gdk_sys::gdk_monitor_get_workarea(monitor, &mut workarea);
                WindowDisplay {
                    bounds: bounds(frame),
                    work_area: bounds(workarea),
                    scale_factor: f64::from(gdk_sys::gdk_monitor_get_scale_factor(monitor)),
                    primary: monitor == primary || (primary.is_null() && index == 0),
                }
            })
            .collect())
    })
}

pub fn get_cursor_position() -> Result<WindowPoint, String> {
    on_main(|_| unsafe {
        let display = gdk_sys::gdk_display_get_default();
        if display.is_null() {
            return Err("No display is open".into());
        }
        let pointer = gdk_sys::gdk_seat_get_pointer(gdk_sys::gdk_display_get_default_seat(display));
        let (mut x, mut y) = (0, 0);
        gdk_sys::gdk_device_get_position(pointer, null_mut(), &mut x, &mut y);
        Ok(WindowPoint {
            x: f64::from(x),
            y: f64::from(y),
        })
    })
}

pub fn set_bounds(position: Option<(f64, f64)>, size: Option<(f64, f64)>) -> Result<(), String> {
    on_main(move |state| {
        let window = state.require_window()?;
        unsafe {
            if let Some((x, y)) = position {
                gtk_sys::gtk_window_move(window, x as i32, y as i32);
            }
            if let Some((width, height)) = size {
                let (width, height) = (width as i32, height as i32);
                if gtk_sys::gtk_widget_get_mapped(window.cast()) != GFALSE {
                    gtk_sys::gtk_window_resize(window, width, height);
                } else {
                    // A resize loses to the default-size hint when an unmapped
                    // window is mapped.
                    gtk_sys::gtk_window_set_default_size(window, width, height);
                }
            }
        }
        Ok(())
    })
}

pub fn is_position_supported() -> Result<bool, String> {
    on_main(|state| {
        let window = state.window.get();
        if window.is_null() {
            return Ok(false);
        }
        let screen: *mut GdkScreen = unsafe { gtk_sys::gtk_window_get_screen(window) };
        Ok(unsafe { is_a(screen.cast(), gdk_x11_screen_get_type()) })
    })
}

// On Wayland neither GdkWindow nor GtkWindow geometry hints stop a resize
// below their minimum; GTK only holds a toplevel to its content's size request.
pub fn set_minimum_size(width: f64, height: f64) -> Result<(), String> {
    on_main(move |state| {
        state.require_window()?;
        let (width, height) = if width >= 0.0 && height >= 0.0 {
            (width as i32, height as i32)
        } else {
            (-1, -1)
        };
        unsafe { gtk_sys::gtk_widget_set_size_request(state.view.get(), width, height) };
        Ok(())
    })
}

pub fn is_always_on_top() -> Result<bool, String> {
    on_main(|state| Ok(state.always_on_top.get()))
}

pub fn set_always_on_top(value: bool) -> Result<(), String> {
    on_main(move |state| {
        unsafe {
            gtk_sys::gtk_window_set_keep_above(state.require_window()?, gboolean::from(value))
        };
        state.always_on_top.set(value);
        Ok(())
    })
}

pub fn set_title_bar_style(style: TitleBarStyle) -> Result<(), String> {
    on_main(move |state| {
        state.require_window()?;
        state.title_bar_hidden.set(style == TitleBarStyle::Hidden);
        state.apply_title_bar();
        Ok(())
    })
}

pub fn set_skip_taskbar(value: bool) -> Result<(), String> {
    on_main(move |state| {
        unsafe {
            gtk_sys::gtk_window_set_skip_taskbar_hint(
                state.require_window()?,
                gboolean::from(value),
            )
        };
        Ok(())
    })
}

pub fn set_rounded_corners(_value: bool) -> Result<(), String> {
    Ok(())
}

pub fn is_effect_supported(effect: WindowEffect) -> Result<bool, String> {
    Ok(effect == WindowEffect::None)
}

pub fn set_effect(
    effect: WindowEffect,
    _tint: Option<u32>,
    _brightness: Option<WindowBrightness>,
) -> Result<(), String> {
    if effect == WindowEffect::None {
        Ok(())
    } else {
        Err("Linux supports only the none effect".into())
    }
}

// Flutter cancels the press itself once the move takes the grab, so no
// release follows.
pub fn start_dragging() -> Result<(), String> {
    on_main(|state| {
        let window = state.require_window()?;
        let press = state.press.get();
        unsafe {
            let gdk_window = gtk_sys::gtk_widget_get_window(window.cast());
            if gdk_window.is_null() || press.is_null() {
                return Err("No press to start a window move from".into());
            }
            let (mut x, mut y) = (0.0, 0.0);
            gdk_sys::gdk_event_get_root_coords(press, &mut x, &mut y);
            let button = if gdk_sys::gdk_event_get_event_type(press) == GDK_BUTTON_PRESS {
                (*press).button.button as i32
            } else {
                GDK_BUTTON_PRIMARY
            };
            let time = gdk_sys::gdk_event_get_time(press);
            let device = gdk_sys::gdk_event_get_device(press);
            if device.is_null() {
                gtk_sys::gtk_window_begin_move_drag(window, button, x as i32, y as i32, time);
            } else {
                gdk_sys::gdk_window_begin_move_drag_for_device(
                    gdk_window, device, button, x as i32, y as i32, time,
                );
            }
        }
        Ok(())
    })
}

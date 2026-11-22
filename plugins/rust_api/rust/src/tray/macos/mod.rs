mod menu;
mod status;

use crate::api::tray::TrayContent;
use block2::RcBlock;
use menu::TrayMenu;
use objc2::rc::Retained;
use objc2::MainThreadMarker;
use objc2_app_kit::NSStatusItem;
use objc2_foundation::NSRunLoop;
use status::StatusItem;
use std::cell::RefCell;

thread_local! {
    static TRAY: RefCell<Option<Tray>> = const { RefCell::new(None) };
}

struct Tray {
    status: StatusItem,
    menu: Option<Retained<TrayMenu>>,
}

// Every entry point is a synchronous bridge call, which Flutter runs on the
// platform thread; one that is not is refused rather than sent across.
pub fn show(content: TrayContent) -> Result<(), String> {
    let mtm = MainThreadMarker::new().ok_or("called off the main thread")?;
    let image = status::image(&content.image).ok_or_else(|| {
        format!(
            "none of the {} icon images decoded",
            content.image.pngs.len()
        )
    })?;
    TRAY.with(|cell| {
        let mut slot = cell
            .try_borrow_mut()
            .map_err(|_| "the status item is in use by another call")?;
        let tray = match slot.as_mut() {
            Some(tray) => tray,
            None => slot.insert(Tray {
                status: StatusItem::new(mtm)?,
                menu: None,
            }),
        };
        tray.status.set_image(&image, content.image.placement);
        tray.status.set_title(&content.title);
        tray.menu = Some(TrayMenu::new(mtm, &content.menu, true));
        Ok(())
    })
}

pub fn set_title(title: String) -> bool {
    if MainThreadMarker::new().is_none() {
        return false;
    }
    TRAY.with(|cell| match cell.try_borrow().as_deref() {
        Ok(Some(tray)) => {
            tray.status.set_title(&title);
            true
        }
        _ => false,
    })
}

pub fn hide() {
    if MainThreadMarker::new().is_none() {
        return;
    }
    let tray = TRAY.with(|cell| cell.try_borrow_mut().ok().and_then(|mut slot| slot.take()));
    if let Some(tray) = tray {
        tray.status.remove();
    }
}

pub fn open_menu() -> bool {
    if MainThreadMarker::new().is_none() {
        return false;
    }
    let has_menu = TRAY.with(|cell| {
        cell.try_borrow()
            .is_ok_and(|slot| slot.as_ref().is_some_and(|tray| tray.menu.is_some()))
    });
    // Tracking a menu runs a nested event loop, which inside this call would
    // hold the Dart isolate until the menu closes.
    if has_menu {
        unsafe { NSRunLoop::mainRunLoop().performBlock(&RcBlock::new(track_menu)) };
    }
    has_menu
}

fn track_menu() {
    let Some(mtm) = MainThreadMarker::new() else {
        return;
    };
    let target = TRAY.with(|cell| {
        let slot = cell.try_borrow().ok()?;
        let tray = slot.as_ref()?;
        Some((tray.status.item().clone(), tray.menu.clone()?))
    });
    let Some((item, menu)) = target else {
        return;
    };
    item.setMenu(Some(&menu));
    if let Some(button) = item.button(mtm) {
        unsafe { button.performClick(None) };
    }
}

fn close_menu() {
    let item: Option<Retained<NSStatusItem>> = TRAY.with(|cell| {
        cell.try_borrow()
            .ok()
            .and_then(|slot| slot.as_ref().map(|tray| tray.status.item().clone()))
    });
    if let Some(item) = item {
        item.setMenu(None);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::tray::{TrayIconPlacement, TrayImage};

    #[test]
    fn a_show_off_the_main_thread_says_so() {
        let content = TrayContent {
            id: String::new(),
            image: TrayImage {
                path: String::new(),
                pngs: Vec::new(),
                template: true,
                size: 18,
                placement: TrayIconPlacement::Leading,
            },
            tool_tip: String::new(),
            title: String::new(),
            menu: Vec::new(),
        };
        assert_eq!(show(content), Err("called off the main thread".into()));
    }
}

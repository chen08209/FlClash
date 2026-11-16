use super::super::emit;
use crate::api::tray::{TrayItem, TrayItemKind, TraySignalKind};
use block2::RcBlock;
use objc2::rc::Retained;
use objc2::runtime::{AnyObject, Bool, ProtocolObject};
use objc2::{
    available, define_class, msg_send, sel, DefinedClass, MainThreadMarker, MainThreadOnly, Message,
};
use objc2_app_kit::{
    NSAccessibility, NSAccessibilityMenuItemRole, NSAutoresizingMaskOptions, NSBezierPath, NSColor,
    NSCompositingOperation, NSControlStateValueOff, NSControlStateValueOn, NSEvent, NSFont,
    NSFontAttributeName, NSFontWeight, NSFontWeightMedium, NSFontWeightRegular,
    NSFontWeightSemibold, NSForegroundColorAttributeName, NSImage, NSImageSymbolConfiguration,
    NSLineBreakMode, NSMenu, NSMenuDelegate, NSMenuItem, NSMutableParagraphStyle,
    NSParagraphStyleAttributeName, NSRectFillUsingOperation, NSResponder, NSStringDrawing,
    NSStringDrawingOptions, NSStringNSExtendedStringDrawing, NSView,
};
use objc2_foundation::{
    NSAttributedStringKey, NSDictionary, NSObject, NSObjectProtocol, NSPoint, NSRect, NSSize,
    NSString,
};
use std::cell::RefCell;

const DETAIL_GAP: f64 = 20.0;
const ARROW_GAP: f64 = 6.0;
const CHECK_GAP: f64 = 3.0;

pub(in super::super) struct MenuIvars {
    pending: RefCell<Vec<Option<ItemContent>>>,
    is_root: bool,
}

define_class!(
    #[unsafe(super(NSMenu, NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashTrayMenu"]
    #[ivars = MenuIvars]
    pub(in super::super) struct TrayMenu;

    unsafe impl NSObjectProtocol for TrayMenu {}

    unsafe impl NSMenuDelegate for TrayMenu {
        // A delay test rebuilds the menu per result; measuring every row then costs ~20x.
        #[unsafe(method(menuNeedsUpdate:))]
        fn menu_needs_update(&self, _menu: &NSMenu) {
            let pending = match self.ivars().pending.try_borrow_mut() {
                Ok(mut pending) => std::mem::take(&mut *pending),
                Err(_) => return,
            };
            for (item, content) in self.itemArray().iter().zip(pending) {
                if let Some(content) = content {
                    item.setView(Some(&ItemView::new(self.mtm(), content)));
                }
            }
        }

        // AppKit does not redraw an item's view when its highlight changes.
        #[unsafe(method(menu:willHighlightItem:))]
        fn will_highlight_item(&self, menu: &NSMenu, item: Option<&NSMenuItem>) {
            let previous = menu.highlightedItem();
            for item in previous.as_deref().into_iter().chain(item) {
                if let Some(view) = item.view() {
                    view.setNeedsDisplay(true);
                }
            }
        }

        #[unsafe(method(menuDidClose:))]
        fn menu_did_close(&self, _menu: &NSMenu) {
            if self.ivars().is_root {
                super::close_menu();
            }
        }
    }

    impl TrayMenu {
        #[unsafe(method(selectItem:))]
        fn select_item(&self, sender: &NSMenuItem) {
            emit(TraySignalKind::ItemSelected, sender.tag() as u32);
        }
    }
);

impl TrayMenu {
    pub fn new(mtm: MainThreadMarker, items: &[TrayItem], is_root: bool) -> Retained<Self> {
        let this = Self::alloc(mtm).set_ivars(MenuIvars {
            pending: RefCell::new(Vec::new()),
            is_root,
        });
        let menu: Retained<Self> =
            unsafe { msg_send![super(this), initWithTitle: &*NSString::from_str("")] };
        menu.setAutoenablesItems(false);
        menu.setDelegate(Some(ProtocolObject::from_ref(&*menu)));
        let pending = items
            .iter()
            .map(|entry| {
                menu.addItem(&menu.make_item(mtm, entry));
                ItemContent::of(entry)
            })
            .collect();
        *menu.ivars().pending.borrow_mut() = pending;
        menu
    }

    fn make_item(&self, mtm: MainThreadMarker, entry: &TrayItem) -> Retained<NSMenuItem> {
        if entry.kind == TrayItemKind::Separator {
            return NSMenuItem::separatorItem(mtm);
        }
        let item = NSMenuItem::new(mtm);
        item.setTitle(&NSString::from_str(&entry.label));
        item.setTag(entry.id as isize);
        item.setEnabled(entry.enabled);
        let checked = entry.kind == TrayItemKind::Checkbox && entry.checked;
        item.setState(if checked {
            NSControlStateValueOn
        } else {
            NSControlStateValueOff
        });
        if entry.kind == TrayItemKind::Submenu {
            item.setSubmenu(Some(&TrayMenu::new(mtm, &entry.items, false)));
        } else {
            unsafe {
                item.setTarget(Some(self));
                item.setAction(Some(sel!(selectItem:)));
            }
        }
        item
    }
}

pub(super) struct ItemContent {
    label: String,
    detail: Option<String>,
    checked: bool,
    enabled: bool,
    has_submenu: bool,
}

impl ItemContent {
    fn of(entry: &TrayItem) -> Option<Self> {
        if entry.kind == TrayItemKind::Separator {
            return None;
        }
        Some(Self {
            label: entry.label.clone(),
            detail: entry.detail.clone().filter(|detail| !detail.is_empty()),
            checked: entry.kind == TrayItemKind::Checkbox && entry.checked,
            enabled: entry.enabled,
            has_submenu: entry.kind == TrayItemKind::Submenu,
        })
    }
}

/// The metrics copy the native menu so these rows line up with the separators
/// the menu still draws.
struct Style {
    height: f64,
    state_x: f64,
    title_x: f64,
    trailing: f64,
    highlight_inset: f64,
    highlight_radius: f64,
    font: Retained<NSFont>,
    detail_font: Retained<NSFont>,
    checkmark: Retained<NSImage>,
    arrow: Retained<NSImage>,
}

impl Style {
    fn current() -> Self {
        let modern = available!(macos = 26);
        let font = NSFont::menuFontOfSize(if modern { 13.0 } else { 0.0 });
        let size = font.pointSize();
        let detail_font =
            NSFont::monospacedDigitSystemFontOfSize_weight(size, unsafe { NSFontWeightRegular });
        let checkmark = symbol("checkmark", size, unsafe { NSFontWeightMedium });
        let arrow = symbol("chevron.right", size, unsafe { NSFontWeightSemibold });
        let (height, state_x, title_x, trailing, highlight_radius) = if modern {
            (24.0, 12.0, 30.0, 23.0, 8.0)
        } else {
            (22.0, 9.0, 21.0, 14.0, 4.0)
        };
        Self {
            height,
            state_x,
            title_x,
            trailing,
            highlight_inset: 5.0,
            highlight_radius,
            font,
            detail_font,
            checkmark,
            arrow,
        }
    }
}

thread_local! {
    static STYLE: Style = Style::current();
}

fn symbol(name: &str, size: f64, weight: NSFontWeight) -> Retained<NSImage> {
    let configuration = NSImageSymbolConfiguration::configurationWithPointSize_weight(size, weight);
    NSImage::imageWithSystemSymbolName_accessibilityDescription(&NSString::from_str(name), None)
        .and_then(|image| image.imageWithSymbolConfiguration(&configuration))
        .unwrap_or_default()
}

// A native item leaves a fixed gap before its submenu arrow, so rows are drawn
// here to keep a detail next to the arrow.
define_class!(
    #[unsafe(super(NSView, NSResponder, NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashTrayMenuItemView"]
    #[ivars = ItemContent]
    struct ItemView;

    impl ItemView {
        #[unsafe(method(isFlipped))]
        fn is_flipped(&self) -> bool {
            true
        }

        #[unsafe(method(drawRect:))]
        fn draw_rect(&self, _dirty: NSRect) {
            STYLE.with(|style| self.draw(style));
        }

        #[unsafe(method(mouseUp:))]
        fn mouse_up(&self, _event: &NSEvent) {
            let content = self.ivars();
            if !content.enabled || content.has_submenu {
                return;
            }
            let Some(item) = self.enclosingMenuItem() else {
                return;
            };
            let mut root = unsafe { item.menu() };
            while let Some(parent) = root.as_ref().and_then(|menu| unsafe { menu.supermenu() }) {
                root = Some(parent);
            }
            if let Some(root) = root {
                root.cancelTracking();
            }
            emit(TraySignalKind::ItemSelected, item.tag() as u32);
        }
    }
);

impl ItemView {
    fn new(mtm: MainThreadMarker, content: ItemContent) -> Retained<Self> {
        let (width, height) = STYLE.with(|style| {
            let mut width =
                style.title_x + text_width(&content.label, &style.font) + style.trailing;
            if let Some(detail) = &content.detail {
                width += DETAIL_GAP + text_width(detail, &style.detail_font);
            }
            if content.has_submenu {
                width += ARROW_GAP + style.arrow.size().width;
            }
            (width.ceil(), style.height)
        });
        let label = match &content.detail {
            Some(detail) => format!("{}, {detail}", content.label),
            None => content.label.clone(),
        };
        let enabled = content.enabled;
        let this = Self::alloc(mtm).set_ivars(content);
        let frame = NSRect::new(NSPoint::ZERO, NSSize::new(width, height));
        let view: Retained<Self> = unsafe { msg_send![super(this), initWithFrame: frame] };
        view.setAutoresizingMask(NSAutoresizingMaskOptions::ViewWidthSizable);
        unsafe {
            view.setAccessibilityElement(true);
            view.setAccessibilityRole(Some(NSAccessibilityMenuItemRole));
            view.setAccessibilityLabel(Some(&NSString::from_str(&label)));
        }
        view.setAccessibilityEnabled(enabled);
        view
    }

    fn draw(&self, style: &Style) {
        let content = self.ivars();
        let bounds = self.bounds();
        let highlighted = content.enabled
            && self
                .enclosingMenuItem()
                .is_some_and(|item| item.isHighlighted());
        if highlighted {
            NSColor::controlAccentColor().setFill();
            let inset = NSRect::new(
                NSPoint::new(bounds.origin.x + style.highlight_inset, bounds.origin.y),
                NSSize::new(
                    bounds.size.width - 2.0 * style.highlight_inset,
                    bounds.size.height,
                ),
            );
            NSBezierPath::bezierPathWithRoundedRect_xRadius_yRadius(
                inset,
                style.highlight_radius,
                style.highlight_radius,
            )
            .fill();
        }

        let primary = if highlighted {
            NSColor::selectedMenuItemTextColor()
        } else if content.enabled {
            NSColor::labelColor()
        } else {
            NSColor::tertiaryLabelColor()
        };
        if content.checked {
            draw_symbol(
                &style.checkmark,
                style.state_x,
                &primary,
                style.title_x - style.state_x - CHECK_GAP,
                bounds,
            );
        }

        let mut trailing_x = bounds.size.width - style.trailing;
        if content.has_submenu {
            let arrow_width = style.arrow.size().width;
            draw_symbol(
                &style.arrow,
                trailing_x - arrow_width,
                &primary,
                f64::INFINITY,
                bounds,
            );
            trailing_x -= arrow_width + ARROW_GAP;
        }

        if let Some(detail) = &content.detail {
            let color = if highlighted {
                NSColor::selectedMenuItemTextColor()
            } else if content.enabled {
                NSColor::secondaryLabelColor()
            } else {
                NSColor::tertiaryLabelColor()
            };
            let detail_width = text_width(detail, &style.detail_font);
            draw_text(
                detail,
                trailing_x - detail_width,
                detail_width,
                &color,
                &style.detail_font,
                bounds,
            );
            trailing_x -= detail_width + DETAIL_GAP;
        }

        draw_text(
            &content.label,
            style.title_x,
            trailing_x - style.title_x,
            &primary,
            &style.font,
            bounds,
        );
    }
}

fn attributes(
    font: &NSFont,
    color: &NSColor,
    paragraph: Option<&NSMutableParagraphStyle>,
) -> Retained<NSDictionary<NSAttributedStringKey, AnyObject>> {
    let mut keys: Vec<&NSAttributedStringKey> =
        unsafe { vec![NSFontAttributeName, NSForegroundColorAttributeName] };
    let mut values: Vec<&AnyObject> = vec![font, color];
    if let Some(paragraph) = paragraph {
        keys.push(unsafe { NSParagraphStyleAttributeName });
        values.push(paragraph);
    }
    NSDictionary::from_slices(&keys, &values)
}

fn text_width(text: &str, font: &NSFont) -> f64 {
    let attributes = attributes(font, &NSColor::labelColor(), None);
    let size = unsafe { NSString::from_str(text).sizeWithAttributes(Some(&attributes)) };
    size.width.ceil()
}

fn draw_text(text: &str, x: f64, width: f64, color: &NSColor, font: &NSFont, bounds: NSRect) {
    let paragraph = NSMutableParagraphStyle::new();
    paragraph.setLineBreakMode(NSLineBreakMode::ByTruncatingTail);
    let height = (font.ascender() - font.descender()).ceil();
    let rect = NSRect::new(
        NSPoint::new(x, (bounds.size.height - height) / 2.0),
        NSSize::new(width.max(0.0), height),
    );
    let attributes = attributes(font, color, Some(&paragraph));
    unsafe {
        NSString::from_str(text).drawWithRect_options_attributes_context(
            rect,
            NSStringDrawingOptions::UsesLineFragmentOrigin
                | NSStringDrawingOptions::TruncatesLastVisibleLine,
            Some(&attributes),
            None,
        );
    }
}

// Before macOS 26 the title starts closer to the state column than a
// checkmark at the menu font's size is wide, so the mark shrinks to fit.
fn draw_symbol(image: &NSImage, x: f64, color: &NSColor, max_width: f64, bounds: NSRect) {
    let natural = image.size();
    let scale = (max_width / natural.width).min(1.0);
    let size = NSSize::new(natural.width * scale, natural.height * scale);
    let rect = NSRect::new(
        NSPoint::new(x, ((bounds.size.height - size.height) / 2.0).round()),
        size,
    );
    let image = image.retain();
    let color = color.retain();
    let tint = RcBlock::new(move |area: NSRect| -> Bool {
        image.drawInRect(area);
        color.setFill();
        NSRectFillUsingOperation(area, NSCompositingOperation::SourceAtop);
        Bool::YES
    });
    let tinted = NSImage::imageWithSize_flipped_drawingHandler(size, false, &tint);
    unsafe {
        tinted.drawInRect_fromRect_operation_fraction_respectFlipped_hints(
            rect,
            NSRect::ZERO,
            NSCompositingOperation::SourceOver,
            1.0,
            true,
            None,
        );
    }
}

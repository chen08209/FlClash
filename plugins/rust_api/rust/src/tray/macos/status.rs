use super::super::emit;
use crate::api::tray::{TrayIconPlacement, TrayImage, TraySignalKind};
use objc2::rc::Retained;
use objc2::runtime::AnyObject;
use objc2::{
    define_class, msg_send, AllocAnyThread, DefinedClass, MainThreadMarker, MainThreadOnly,
};
use objc2_app_kit::{
    NSAttributedStringNSExtendedStringDrawing, NSAttributedStringNSStringDrawing, NSBitmapImageRep,
    NSColor, NSEvent, NSFont, NSFontAttributeName, NSForegroundColorAttributeName, NSImage,
    NSImageScaling, NSImageView, NSLayoutConstraint, NSLayoutConstraintOrientation,
    NSLayoutPriorityRequired, NSResponder, NSStackView, NSStackViewDistribution, NSStatusBar,
    NSStatusBarButton, NSStatusItem, NSStringDrawingOptions, NSUserInterfaceLayoutOrientation,
    NSVariableStatusItemLength, NSView, NSViewNoIntrinsicMetric,
};
use objc2_foundation::{
    NSArray, NSAttributedString, NSAttributedStringKey, NSData, NSDictionary, NSObject, NSPoint,
    NSRect, NSSize, NSString,
};
use std::cell::{Cell, RefCell};

const TITLE_MIN_WIDTH: f64 = 42.0;
const TITLE_FONT_SIZE: f64 = 8.75;
const TITLE_LINE_HEIGHT: f64 = 9.0;

pub(super) fn image(spec: &TrayImage) -> Option<Retained<NSImage>> {
    let size = NSSize::new(f64::from(spec.size), f64::from(spec.size));
    let image = NSImage::initWithSize(NSImage::alloc(), size);
    for png in &spec.pngs {
        let Some(rep) = NSBitmapImageRep::imageRepWithData(&NSData::with_bytes(png)) else {
            continue;
        };
        rep.setSize(size);
        image.addRepresentation(&rep);
    }
    if image.representations().count() == 0 {
        return None;
    }
    image.setTemplate(spec.template);
    Some(image)
}

pub(super) struct StatusItem {
    item: Retained<NSStatusItem>,
    content: Retained<ContentView>,
}

impl StatusItem {
    pub fn new(mtm: MainThreadMarker) -> Option<Self> {
        let bar = NSStatusBar::systemStatusBar();
        let item = bar.statusItemWithLength(NSVariableStatusItemLength);
        let Some(button) = item.button(mtm) else {
            bar.removeStatusItem(&item);
            return None;
        };
        let content = ContentView::new(mtm);
        button.addSubview(&content);
        content.setTranslatesAutoresizingMaskIntoConstraints(false);
        activate(&[
            content
                .leadingAnchor()
                .constraintEqualToAnchor(&button.leadingAnchor()),
            content
                .trailingAnchor()
                .constraintEqualToAnchor(&button.trailingAnchor()),
            content
                .topAnchor()
                .constraintEqualToAnchor(&button.topAnchor()),
            content
                .bottomAnchor()
                .constraintEqualToAnchor(&button.bottomAnchor()),
            content
                .heightAnchor()
                .constraintEqualToConstant(bar.thickness()),
        ]);
        Some(Self { item, content })
    }

    pub fn item(&self) -> &Retained<NSStatusItem> {
        &self.item
    }

    pub fn set_image(&self, image: &NSImage, placement: TrayIconPlacement) {
        if self.content.set_image(image, placement) {
            self.refit();
        }
    }

    pub fn set_title(&self, title: &str) {
        if self.content.ivars().title.set_title(title) {
            self.refit();
        }
    }

    pub fn remove(self) {
        self.item.setMenu(None);
        NSStatusBar::systemStatusBar().removeStatusItem(&self.item);
    }

    fn refit(&self) {
        if let Some(button) = self.button() {
            button.sizeToFit();
        }
    }

    fn button(&self) -> Option<Retained<NSStatusBarButton>> {
        self.item.button(self.content.mtm())
    }
}

fn activate(constraints: &[Retained<NSLayoutConstraint>]) {
    NSLayoutConstraint::activateConstraints(&NSArray::from_retained_slice(constraints));
}

pub(super) struct ContentIvars {
    image: Retained<NSImageView>,
    title: Retained<TitleView>,
    stack: Retained<NSStackView>,
}

define_class!(
    #[unsafe(super(NSView, NSResponder, NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashTrayContentView"]
    #[ivars = ContentIvars]
    pub(super) struct ContentView;

    impl ContentView {
        #[unsafe(method(mouseDown:))]
        fn mouse_down(&self, _event: &NSEvent) {
            emit(TraySignalKind::MenuRequested, 0);
        }

        #[unsafe(method(rightMouseDown:))]
        fn right_mouse_down(&self, _event: &NSEvent) {
            emit(TraySignalKind::MenuRequested, 0);
        }
    }
);

impl ContentView {
    fn new(mtm: MainThreadMarker) -> Retained<Self> {
        let image = NSImageView::new(mtm);
        image.setImageScaling(NSImageScaling::ScaleProportionallyDown);
        image.setHidden(true);
        image.setContentHuggingPriority_forOrientation(
            NSLayoutPriorityRequired,
            NSLayoutConstraintOrientation::Horizontal,
        );
        let title = TitleView::new(mtm);
        title.setHidden(true);
        let stack = NSStackView::new(mtm);
        stack.setOrientation(NSUserInterfaceLayoutOrientation::Horizontal);
        stack.setSpacing(6.0);
        stack.setDistribution(NSStackViewDistribution::EqualSpacing);

        let this = Self::alloc(mtm).set_ivars(ContentIvars {
            image,
            title,
            stack,
        });
        let view: Retained<Self> = unsafe { msg_send![super(this), initWithFrame: NSRect::ZERO] };
        let ivars = view.ivars();
        view.addSubview(&ivars.stack);
        ivars
            .stack
            .setTranslatesAutoresizingMaskIntoConstraints(false);
        activate(&[
            ivars
                .stack
                .leadingAnchor()
                .constraintEqualToAnchor_constant(&view.leadingAnchor(), 8.0),
            ivars
                .stack
                .trailingAnchor()
                .constraintEqualToAnchor_constant(&view.trailingAnchor(), -8.0),
            ivars
                .stack
                .topAnchor()
                .constraintEqualToAnchor_constant(&view.topAnchor(), 2.0),
            ivars
                .stack
                .bottomAnchor()
                .constraintEqualToAnchor_constant(&view.bottomAnchor(), -2.0),
        ]);
        view.apply_placement(TrayIconPlacement::Leading);
        ivars
            .title
            .setTranslatesAutoresizingMaskIntoConstraints(false);
        ivars.title.setContentHuggingPriority_forOrientation(
            NSLayoutPriorityRequired,
            NSLayoutConstraintOrientation::Horizontal,
        );
        ivars
            .title
            .setContentCompressionResistancePriority_forOrientation(
                NSLayoutPriorityRequired,
                NSLayoutConstraintOrientation::Horizontal,
            );
        activate(&[ivars
            .title
            .widthAnchor()
            .constraintGreaterThanOrEqualToConstant(TITLE_MIN_WIDTH)]);
        view
    }

    fn set_image(&self, image: &NSImage, placement: TrayIconPlacement) -> bool {
        let view = &self.ivars().image;
        let was_hidden = view.isHidden();
        let previous = view.image().map_or(NSSize::ZERO, |image| image.size());
        view.setImage(Some(image));
        view.setHidden(false);
        self.apply_placement(placement);
        was_hidden || previous != image.size()
    }

    fn apply_placement(&self, placement: TrayIconPlacement) {
        let ivars = self.ivars();
        let image: &NSView = &ivars.image;
        let title: &NSView = &ivars.title;
        let wanted = match placement {
            TrayIconPlacement::Leading => [image, title],
            TrayIconPlacement::Trailing => [title, image],
        };
        let current = ivars.stack.arrangedSubviews().to_vec();
        let in_place = current.len() == wanted.len()
            && current
                .iter()
                .zip(wanted)
                .all(|(view, wanted)| std::ptr::eq(&**view, wanted));
        if in_place {
            return;
        }
        for view in &current {
            ivars.stack.removeArrangedSubview(view);
        }
        for (index, view) in wanted.into_iter().enumerate() {
            ivars
                .stack
                .insertArrangedSubview_atIndex(view, index as isize);
        }
    }
}

pub(super) struct TitleIvars {
    lines: RefCell<Vec<Retained<NSAttributedString>>>,
    width: Cell<f64>,
}

define_class!(
    #[unsafe(super(NSView, NSResponder, NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashTrayTitleView"]
    #[ivars = TitleIvars]
    pub(super) struct TitleView;

    impl TitleView {
        #[unsafe(method(isFlipped))]
        fn is_flipped(&self) -> bool {
            true
        }

        #[unsafe(method(intrinsicContentSize))]
        fn intrinsic_content_size(&self) -> NSSize {
            NSSize::new(self.ivars().width.get(), unsafe { NSViewNoIntrinsicMetric })
        }

        // Line boxes carry descender space, so centring them leaves the digits high.
        #[unsafe(method(drawRect:))]
        fn draw_rect(&self, _dirty: NSRect) {
            let Ok(lines) = self.ivars().lines.try_borrow() else {
                return;
            };
            if lines.is_empty() {
                return;
            }
            let bounds = self.bounds();
            let cap_height = title_font().capHeight();
            let block_height = cap_height + TITLE_LINE_HEIGHT * (lines.len() - 1) as f64;
            let scale = self.window().map_or(2.0, |window| window.backingScaleFactor());
            let mut baseline =
                (((bounds.size.height - block_height) / 2.0 + cap_height) * scale).round() / scale;
            for line in lines.iter() {
                let width = line.size().width;
                line.drawWithRect_options_context(
                    NSRect::new(
                        NSPoint::new(bounds.size.width - width, baseline),
                        NSSize::new(width, 0.0),
                    ),
                    NSStringDrawingOptions::empty(),
                    None,
                );
                baseline += TITLE_LINE_HEIGHT;
            }
        }
    }
);

impl TitleView {
    fn new(mtm: MainThreadMarker) -> Retained<Self> {
        let this = Self::alloc(mtm).set_ivars(TitleIvars {
            lines: RefCell::new(Vec::new()),
            width: Cell::new(TITLE_MIN_WIDTH),
        });
        unsafe { msg_send![super(this), initWithFrame: NSRect::ZERO] }
    }

    fn set_title(&self, title: &str) -> bool {
        let was_hidden = self.isHidden();
        let previous_width = self.ivars().width.get();
        let lines: Vec<_> = if title.is_empty() {
            Vec::new()
        } else {
            let attributes = title_attributes();
            title
                .split('\n')
                .map(|line| unsafe {
                    NSAttributedString::initWithString_attributes(
                        NSAttributedString::alloc(),
                        &NSString::from_str(line),
                        Some(&attributes),
                    )
                })
                .collect()
        };
        let text_width = lines
            .iter()
            .map(|line| line.size().width.ceil())
            .fold(0.0, f64::max);
        let width = TITLE_MIN_WIDTH.max(text_width);
        if let Ok(mut current) = self.ivars().lines.try_borrow_mut() {
            *current = lines;
        }
        self.setNeedsDisplay(true);
        self.ivars().width.set(width);
        self.setHidden(title.is_empty());
        let width_changed = width != previous_width;
        if width_changed {
            self.invalidateIntrinsicContentSize();
        }
        was_hidden != self.isHidden() || width_changed
    }
}

fn title_font() -> Retained<NSFont> {
    NSFont::systemFontOfSize(TITLE_FONT_SIZE)
}

fn title_attributes() -> Retained<NSDictionary<NSAttributedStringKey, AnyObject>> {
    let font = title_font();
    let color = NSColor::labelColor();
    let keys: [&NSAttributedStringKey; 2] =
        unsafe { [NSFontAttributeName, NSForegroundColorAttributeName] };
    let values: [&AnyObject; 2] = [&font, &color];
    NSDictionary::from_slices(&keys, &values)
}

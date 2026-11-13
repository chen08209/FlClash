//! A StatusNotifierItem over D-Bus, without GTK. KDE and most panels show it
//! natively; GNOME needs the AppIndicator extension, as it did for the
//! libappindicator item this replaced.

use super::emit;
use crate::api::tray::{TrayContent, TrayItem, TrayItemKind, TraySignalKind};
use ksni::menu::{CheckmarkItem, MenuItem, StandardItem, SubMenu};
use ksni::{Category, Handle, ToolTip, TrayMethods};
use std::path::Path;
use std::sync::OnceLock;
use std::time::Duration;
use tokio::sync::mpsc::{self, UnboundedReceiver, UnboundedSender};

const RETRY_INTERVAL: Duration = Duration::from_secs(2);

enum Command {
    Show(TrayContent),
    Hide,
}

static COMMANDS: OnceLock<Option<UnboundedSender<Command>>> = OnceLock::new();

pub fn show(content: TrayContent) -> bool {
    if !Path::new(&content.image.path).is_file() {
        return false;
    }
    commands().is_some_and(|commands| commands.send(Command::Show(content)).is_ok())
}

pub fn set_title(_title: String) -> bool {
    false
}

pub fn hide() {
    if let Some(commands) = COMMANDS.get().and_then(Option::as_ref) {
        let _ = commands.send(Command::Hide);
    }
}

pub fn open_menu() -> bool {
    false
}

fn commands() -> Option<&'static UnboundedSender<Command>> {
    COMMANDS
        .get_or_init(|| {
            let runtime = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .ok()?;
            let (commands, inbox) = mpsc::unbounded_channel();
            std::thread::Builder::new()
                .name("tray".into())
                .spawn(move || runtime.block_on(serve(inbox)))
                .ok()?;
            Some(commands)
        })
        .as_ref()
}

// `show` answered before a spawn can fail (no bus or watcher yet at sign-in).
async fn serve(mut inbox: UnboundedReceiver<Command>) {
    let mut shown: Option<Handle<Item>> = None;
    let mut unshown: Option<TrayContent> = None;
    loop {
        let next = match unshown.take() {
            Some(content) => tokio::select! {
                command = inbox.recv() => command,
                () = tokio::time::sleep(RETRY_INTERVAL) => Some(Command::Show(content)),
            },
            None => inbox.recv().await,
        };
        let Some(mut command) = next else {
            return;
        };
        while let Ok(newer) = inbox.try_recv() {
            command = newer;
        }
        match command {
            Command::Show(content) => {
                let mut pending = Some(content);
                if let Some(handle) = &shown {
                    handle
                        .update(|item| {
                            if let Some(content) = pending.take() {
                                item.content = content;
                            }
                        })
                        .await;
                }
                if let Some(content) = pending {
                    let item = Item {
                        content: content.clone(),
                    };
                    match item.assume_sni_available(true).spawn().await {
                        Ok(handle) => shown = Some(handle),
                        Err(_) => unshown = Some(content),
                    }
                }
            }
            Command::Hide => {
                if let Some(handle) = shown.take() {
                    handle.shutdown().await;
                }
            }
        }
    }
}

struct Item {
    content: TrayContent,
}

impl ksni::Tray for Item {
    fn id(&self) -> String {
        self.content.id.clone()
    }

    fn activate(&mut self, _x: i32, _y: i32) {
        emit(TraySignalKind::IconActivated, 0);
    }

    fn secondary_activate(&mut self, _x: i32, _y: i32) {
        emit(TraySignalKind::IconActivated, 0);
    }

    fn category(&self) -> Category {
        Category::ApplicationStatus
    }

    fn title(&self) -> String {
        self.content.tool_tip.clone()
    }

    // An absolute path goes through the theme path, as libappindicator does
    // with one, so no image decoder is needed here.
    fn icon_theme_path(&self) -> String {
        icon_parts(&self.content.image.path).0
    }

    fn icon_name(&self) -> String {
        icon_parts(&self.content.image.path).1
    }

    fn tool_tip(&self) -> ToolTip {
        ToolTip {
            title: self.content.tool_tip.clone(),
            ..ToolTip::default()
        }
    }

    fn menu(&self) -> Vec<MenuItem<Self>> {
        menu_items(&self.content.menu)
    }
}

fn menu_items(items: &[TrayItem]) -> Vec<MenuItem<Item>> {
    items
        .iter()
        .map(|item| match item.kind {
            TrayItemKind::Separator => MenuItem::Separator,
            TrayItemKind::Action => StandardItem {
                label: menu_label(item),
                enabled: item.enabled,
                activate: select(item.id),
                ..StandardItem::default()
            }
            .into(),
            TrayItemKind::Checkbox => CheckmarkItem {
                label: menu_label(item),
                enabled: item.enabled,
                checked: item.checked,
                activate: select(item.id),
                ..CheckmarkItem::default()
            }
            .into(),
            TrayItemKind::Submenu => SubMenu {
                label: menu_label(item),
                enabled: item.enabled,
                submenu: menu_items(&item.items),
                ..SubMenu::default()
            }
            .into(),
        })
        .collect()
}

fn select(id: u32) -> Box<dyn Fn(&mut Item) + Send> {
    Box::new(move |_| emit(TraySignalKind::ItemSelected, id))
}

// dbusmenu has no column for free text, and reads an underscore as the
// mnemonic marker.
fn menu_label(item: &TrayItem) -> String {
    let label = item.label.replace('_', "__");
    match item.detail.as_deref() {
        Some(detail) if !detail.is_empty() => format!("{label}  ({})", detail.replace('_', "__")),
        _ => label,
    }
}

fn icon_parts(path: &str) -> (String, String) {
    let path = Path::new(path);
    let directory = path.parent().map(Path::to_string_lossy).unwrap_or_default();
    let name = path
        .file_stem()
        .map(|stem| stem.to_string_lossy())
        .unwrap_or_default();
    (directory.into_owned(), name.into_owned())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn item(label: &str, detail: Option<&str>) -> TrayItem {
        TrayItem {
            id: 1024,
            kind: TrayItemKind::Action,
            label: label.into(),
            detail: detail.map(Into::into),
            enabled: true,
            checked: false,
            items: Vec::new(),
        }
    }

    #[test]
    fn an_icon_path_splits_into_theme_directory_and_name() {
        assert_eq!(
            icon_parts("/opt/flclash/data/flutter_assets/tray/unix/4.0x/status_1.png"),
            (
                "/opt/flclash/data/flutter_assets/tray/unix/4.0x".to_owned(),
                "status_1".to_owned()
            ),
        );
    }

    #[test]
    fn a_detail_follows_the_label_in_parentheses() {
        assert_eq!(menu_label(&item("Show", Some("Ctrl+S"))), "Show  (Ctrl+S)");
        assert_eq!(menu_label(&item("Show", Some(""))), "Show");
    }

    #[test]
    fn underscores_stay_literal() {
        assert_eq!(menu_label(&item("HK_01", Some("1_2"))), "HK__01  (1__2)");
    }
}

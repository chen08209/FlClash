use crate::api::hotkey::{HotKeyModifier, HotKeySpec};
use global_hotkey::hotkey::{Code, HotKey, Modifiers};

const PRIMARY_MODIFIERS: Modifiers = Modifiers::SHIFT
    .union(Modifiers::CONTROL)
    .union(Modifiers::ALT)
    .union(Modifiers::META)
    .union(Modifiers::SUPER);

pub fn to_hot_key(spec: &HotKeySpec) -> Result<HotKey, String> {
    let code = code_for_usage(spec.key)
        .ok_or_else(|| format!("Key 0x{:08x} cannot be a global hotkey", spec.key))?;
    let modifiers = modifiers_for(&spec.modifiers);
    if !modifiers.intersects(PRIMARY_MODIFIERS) {
        return Err("A global hotkey needs Shift, Control, Alt or Meta".into());
    }
    Ok(HotKey::new(Some(modifiers), code))
}

fn modifiers_for(modifiers: &[HotKeyModifier]) -> Modifiers {
    modifiers.iter().fold(Modifiers::empty(), |acc, modifier| {
        acc | match modifier {
            HotKeyModifier::Alt => Modifiers::ALT,
            HotKeyModifier::CapsLock => Modifiers::CAPS_LOCK,
            HotKeyModifier::Control => Modifiers::CONTROL,
            HotKeyModifier::Fn => Modifiers::FN,
            HotKeyModifier::Meta => Modifiers::META,
            HotKeyModifier::Shift => Modifiers::SHIFT,
        }
    })
}

fn code_for_usage(usage: u32) -> Option<Code> {
    let code = match usage {
        0x0007_0004 => Code::KeyA,
        0x0007_0005 => Code::KeyB,
        0x0007_0006 => Code::KeyC,
        0x0007_0007 => Code::KeyD,
        0x0007_0008 => Code::KeyE,
        0x0007_0009 => Code::KeyF,
        0x0007_000a => Code::KeyG,
        0x0007_000b => Code::KeyH,
        0x0007_000c => Code::KeyI,
        0x0007_000d => Code::KeyJ,
        0x0007_000e => Code::KeyK,
        0x0007_000f => Code::KeyL,
        0x0007_0010 => Code::KeyM,
        0x0007_0011 => Code::KeyN,
        0x0007_0012 => Code::KeyO,
        0x0007_0013 => Code::KeyP,
        0x0007_0014 => Code::KeyQ,
        0x0007_0015 => Code::KeyR,
        0x0007_0016 => Code::KeyS,
        0x0007_0017 => Code::KeyT,
        0x0007_0018 => Code::KeyU,
        0x0007_0019 => Code::KeyV,
        0x0007_001a => Code::KeyW,
        0x0007_001b => Code::KeyX,
        0x0007_001c => Code::KeyY,
        0x0007_001d => Code::KeyZ,
        0x0007_001e => Code::Digit1,
        0x0007_001f => Code::Digit2,
        0x0007_0020 => Code::Digit3,
        0x0007_0021 => Code::Digit4,
        0x0007_0022 => Code::Digit5,
        0x0007_0023 => Code::Digit6,
        0x0007_0024 => Code::Digit7,
        0x0007_0025 => Code::Digit8,
        0x0007_0026 => Code::Digit9,
        0x0007_0027 => Code::Digit0,
        0x0007_0028 => Code::Enter,
        0x0007_0029 => Code::Escape,
        0x0007_002a => Code::Backspace,
        0x0007_002b => Code::Tab,
        0x0007_002c => Code::Space,
        0x0007_002d => Code::Minus,
        0x0007_002e => Code::Equal,
        0x0007_002f => Code::BracketLeft,
        0x0007_0030 => Code::BracketRight,
        0x0007_0031 => Code::Backslash,
        0x0007_0033 => Code::Semicolon,
        0x0007_0034 => Code::Quote,
        0x0007_0035 => Code::Backquote,
        0x0007_0036 => Code::Comma,
        0x0007_0037 => Code::Period,
        0x0007_0038 => Code::Slash,
        0x0007_0039 => Code::CapsLock,
        0x0007_003a => Code::F1,
        0x0007_003b => Code::F2,
        0x0007_003c => Code::F3,
        0x0007_003d => Code::F4,
        0x0007_003e => Code::F5,
        0x0007_003f => Code::F6,
        0x0007_0040 => Code::F7,
        0x0007_0041 => Code::F8,
        0x0007_0042 => Code::F9,
        0x0007_0043 => Code::F10,
        0x0007_0044 => Code::F11,
        0x0007_0045 => Code::F12,
        0x0007_0046 => Code::PrintScreen,
        0x0007_0047 => Code::ScrollLock,
        0x0007_0048 => Code::Pause,
        0x0007_0049 => Code::Insert,
        0x0007_004a => Code::Home,
        0x0007_004b => Code::PageUp,
        0x0007_004c => Code::Delete,
        0x0007_004d => Code::End,
        0x0007_004e => Code::PageDown,
        0x0007_004f => Code::ArrowRight,
        0x0007_0050 => Code::ArrowLeft,
        0x0007_0051 => Code::ArrowDown,
        0x0007_0052 => Code::ArrowUp,
        0x0007_0053 => Code::NumLock,
        0x0007_0054 => Code::NumpadDivide,
        0x0007_0055 => Code::NumpadMultiply,
        0x0007_0056 => Code::NumpadSubtract,
        0x0007_0057 => Code::NumpadAdd,
        0x0007_0058 => Code::NumpadEnter,
        0x0007_0059 => Code::Numpad1,
        0x0007_005a => Code::Numpad2,
        0x0007_005b => Code::Numpad3,
        0x0007_005c => Code::Numpad4,
        0x0007_005d => Code::Numpad5,
        0x0007_005e => Code::Numpad6,
        0x0007_005f => Code::Numpad7,
        0x0007_0060 => Code::Numpad8,
        0x0007_0061 => Code::Numpad9,
        0x0007_0062 => Code::Numpad0,
        0x0007_0063 => Code::NumpadDecimal,
        0x0007_0064 => Code::IntlBackslash,
        0x0007_0065 => Code::ContextMenu,
        0x0007_0067 => Code::NumpadEqual,
        0x0007_0068 => Code::F13,
        0x0007_0069 => Code::F14,
        0x0007_006a => Code::F15,
        0x0007_006b => Code::F16,
        0x0007_006c => Code::F17,
        0x0007_006d => Code::F18,
        0x0007_006e => Code::F19,
        0x0007_006f => Code::F20,
        0x0007_0070 => Code::F21,
        0x0007_0071 => Code::F22,
        0x0007_0072 => Code::F23,
        0x0007_0073 => Code::F24,
        0x0007_0085 => Code::NumpadComma,
        0x0007_0087 => Code::IntlRo,
        0x0007_0089 => Code::IntlYen,
        0x000c_00b5 => Code::MediaTrackNext,
        0x000c_00b6 => Code::MediaTrackPrevious,
        0x000c_00b7 => Code::MediaStop,
        0x000c_00cd => Code::MediaPlayPause,
        0x000c_00e2 => Code::AudioVolumeMute,
        0x000c_00e9 => Code::AudioVolumeUp,
        0x000c_00ea => Code::AudioVolumeDown,
        _ => return None,
    };
    Some(code)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn spec(key: u32, modifiers: &[HotKeyModifier]) -> HotKeySpec {
        HotKeySpec {
            id: 7,
            key,
            modifiers: modifiers.to_vec(),
        }
    }

    #[test]
    fn maps_flutter_usb_hid_usages() {
        assert_eq!(code_for_usage(0x0007_0004), Some(Code::KeyA));
        assert_eq!(code_for_usage(0x0007_0027), Some(Code::Digit0));
        assert_eq!(code_for_usage(0x0007_0045), Some(Code::F12));
        assert_eq!(code_for_usage(0x0007_0062), Some(Code::Numpad0));
        assert_eq!(code_for_usage(0x000c_00e9), Some(Code::AudioVolumeUp));
        assert_eq!(code_for_usage(0x0007_00e0), None);
    }

    #[test]
    fn builds_hot_key_with_primary_modifiers() {
        let hot_key = to_hot_key(&spec(
            0x0007_0004,
            &[HotKeyModifier::Control, HotKeyModifier::Shift],
        ))
        .unwrap();
        assert_eq!(hot_key.key, Code::KeyA);
        assert_eq!(hot_key.mods, Modifiers::CONTROL | Modifiers::SHIFT);
        assert_eq!(
            hot_key,
            HotKey::new(Some(Modifiers::CONTROL | Modifiers::SHIFT), Code::KeyA)
        );
    }

    #[test]
    fn meta_becomes_super() {
        let hot_key = to_hot_key(&spec(0x0007_0004, &[HotKeyModifier::Meta])).unwrap();
        assert_eq!(hot_key.mods, Modifiers::SUPER);
    }

    #[test]
    fn rejects_lock_only_modifiers() {
        let error = to_hot_key(&spec(0x0007_0004, &[HotKeyModifier::CapsLock])).unwrap_err();
        assert!(error.contains("Shift, Control, Alt or Meta"));
        assert!(to_hot_key(&spec(0x0007_0004, &[HotKeyModifier::Fn])).is_err());
    }

    #[test]
    fn rejects_unknown_key() {
        let error = to_hot_key(&spec(0x0007_00e0, &[HotKeyModifier::Control])).unwrap_err();
        assert!(error.contains("0x000700e0"));
    }
}

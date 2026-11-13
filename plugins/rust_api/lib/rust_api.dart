library;

import 'src/rust/frb_generated.dart';

export 'src/rust/api/charset.dart';
export 'src/rust/api/device.dart';
export 'src/rust/api/fonts.dart';
export 'src/rust/api/hotkey.dart';
export 'src/rust/api/ipc.dart';
export 'src/rust/api/launch.dart';
export 'src/rust/api/proxy.dart';
export 'src/rust/api/script.dart';
export 'src/rust/frb_generated.dart' show RustLib;

bool get isRustLibInitialized => RustLib.instance.initialized;

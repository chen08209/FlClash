library;

import 'src/rust/frb_generated.dart';

export 'src/rust/api/hotkey.dart';
export 'src/rust/api/ipc.dart';
export 'src/rust/api/script.dart';
export 'src/rust/frb_generated.dart' show RustLib;

bool get isRustLibInitialized => RustLib.instance.initialized;

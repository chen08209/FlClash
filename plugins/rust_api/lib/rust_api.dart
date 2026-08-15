library;

import 'dart:async';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import 'src/rust/frb_generated.dart';

export 'src/rust/api/free_nodes.dart';
export 'src/rust/api/ipc.dart';
export 'src/rust/frb_generated.dart' show RustLib;

Future<void>? _rustApiInitFuture;

Future<void> ensureRustApiInitialized({String? externalLibraryPath}) {
  final current = _rustApiInitFuture;
  if (current != null) return current;

  final completer = Completer<void>();
  _rustApiInitFuture = completer.future;
  RustLib.init(
        externalLibrary: externalLibraryPath == null
            ? null
            : ExternalLibrary.open(externalLibraryPath),
      )
      .then((_) {
        completer.complete();
      })
      .catchError((Object error, StackTrace stackTrace) {
        if (identical(_rustApiInitFuture, completer.future)) {
          _rustApiInitFuture = null;
        }
        completer.completeError(error, stackTrace);
      });
  return completer.future;
}

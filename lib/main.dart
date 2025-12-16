import 'dart:async';
import 'dart:io';

import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final version = await system.version;
  final container = await globalState.init(version);
  HttpOverrides.global = FlClashHttpOverrides();
  runApp(
    UncontrolledProviderScope(container: container, child: const Application()),
  );
}

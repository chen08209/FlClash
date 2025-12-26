import 'dart:async';
import 'dart:io';

import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'application.dart';
import 'common/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Isar.initializeIsarCore(download: true);
  final version = await system.version;
  await globalState.initApp(version);
  HttpOverrides.global = FlClashHttpOverrides();
  runApp(ProviderScope(child: const Application()));
}

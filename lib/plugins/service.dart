import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/api/channels/android_frames.dart';
import 'package:fl_clash/core/api/channels/ffi_channel.dart';
import 'package:fl_clash/core/api/channels/method_channel_channel.dart';
import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class ServiceListener {
  void onServiceStopped([ServiceStartFailure? failure]) {}
}

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;
  static const _coreChannel = MethodChannel('$packageName/core');

  @visibleForTesting
  static SessionFrameChannel Function(
    MethodChannel coreChannel, {
    void Function(int session)? onSession,
  })
  framesFactory = createAndroidFrames;

  /// The frames of the Core's JSON-RPC session.
  late final SessionFrameChannel frames = framesFactory(
    _coreChannel,
    onSession: _attachSession,
  );

  final ObserverList<ServiceListener> _listeners =
      ObserverList<ServiceListener>();

  int _commandRevision = 0;
  bool _startRequested = false;

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Service._internal() {
    methodChannel = const MethodChannel('$packageName/service');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'event':
          final channel = frames;
          if (channel is MethodChannelFrameChannel) {
            channel.receive(call.arguments as Uint8List);
          }
          break;
        case 'stopped':
          final report = call.arguments as Map<Object?, Object?>;
          // A report stamped before the newest command no longer describes it.
          if (report['revision'] != _commandRevision || !_startRequested) {
            break;
          }
          _startRequested = false;
          final failure = ServiceStartFailure.fromCode(report['failure']);
          _dispatch(
            'stop report',
            (listener) => listener.onServiceStopped(failure),
          );
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  void _dispatch(String label, void Function(ServiceListener) deliver) {
    for (final listener in List.of(_listeners)) {
      try {
        deliver(listener);
      } catch (error) {
        commonPrint.log(
          'Unable to dispatch Android $label: $error',
          logLevel: LogLevel.error,
        );
      }
    }
  }

  Future<bool> start() async {
    _startRequested = true;
    return await methodChannel.invokeMethod<bool>(
          'start',
          ++_commandRevision,
        ) ??
        false;
  }

  Future<bool> stop() async {
    _startRequested = false;
    return await methodChannel.invokeMethod<bool>('stop', ++_commandRevision) ??
        false;
  }

  Future<String> init() async {
    return await methodChannel.invokeMethod<String>(
          'init',
          frames is FfiFrameChannel ? 'ffi' : 'method',
        ) ??
        '';
  }

  /// Tells the platform which session the engine owns, so that it ends with the engine.
  void _attachSession(int session) {
    unawaited(
      methodChannel.invokeMethod<void>('session', session).catchError((
        Object error,
      ) {
        commonPrint.log(
          'Unable to report the Core session: $error',
          logLevel: LogLevel.debug,
        );
      }),
    );
  }

  Future<String> syncState(SharedState state) async {
    return await methodChannel.invokeMethod<String>(
          'syncState',
          json.encode(state),
        ) ??
        '';
  }

  Future<bool> shutdown() async {
    return await methodChannel.invokeMethod<bool>('shutdown') ?? true;
  }

  Future<DateTime?> getRunTime() async {
    final ms = await methodChannel.invokeMethod<int>('getRunTime') ?? 0;
    if (ms == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ServiceListener listener) {
    _listeners.remove(listener);
  }
}

Service? get service => system.isAndroid ? Service() : null;

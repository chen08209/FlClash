import 'package:fl_clash/core/api/channels/ffi_channel.dart';
import 'package:fl_clash/core/api/channels/method_channel_channel.dart';
import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:flutter/services.dart';

/// `method` carries frames over the core MethodChannel; `ffi` over `dart:ffi`.
const _frames = String.fromEnvironment('CORE_FRAMES', defaultValue: 'ffi');

SessionFrameChannel createAndroidFrames(
  MethodChannel coreChannel, {
  void Function(int session)? onSession,
}) {
  if (_frames == 'ffi') {
    return FfiFrameChannel(onSession: onSession);
  }
  return MethodChannelFrameChannel(coreChannel);
}

import 'dart:async';

import 'package:fl_clash/common/windows_hotspot.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/hotspot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Backend implements HotspotBackend {
  final calls = <HotspotCommand>[];
  HotspotSnapshot snapshot = const HotspotSnapshot();
  Completer<void>? enableGate;
  Completer<void>? inspectGate;
  bool repairFails = false;

  @override
  Future<HotspotSnapshot> execute(HotspotCommand command) async {
    calls.add(command);
    switch (command) {
      case HotspotCommand.inspect:
        await inspectGate?.future;
      case HotspotCommand.enable:
        await enableGate?.future;
        snapshot = const HotspotSnapshot(
          managed: true,
          on: true,
          throughTun: true,
          ssid: 'test-hotspot',
        );
      case HotspotCommand.disable:
        snapshot = const HotspotSnapshot();
      case HotspotCommand.repair:
        snapshot = repairFails
            ? const HotspotSnapshot(error: 'sharing_bypass')
            : const HotspotSnapshot(managed: true, on: true, throughTun: true);
    }
    return snapshot;
  }
}

void main() {
  late _Backend backend;
  late ProviderContainer container;

  ProviderContainer create({bool safeMode = false, bool ready = true}) {
    return ProviderContainer(
      overrides: [
        hotspotBackendProvider.overrideWithValue(backend),
        hotspotSupportedProvider.overrideWithValue(true),
        hotspotReadyProvider.overrideWithValue(ready),
        safeModeProvider.overrideWithValue(safeMode),
      ],
    );
  }

  setUp(() => backend = _Backend());
  tearDown(() => container.dispose());

  test('安全模式不会检查、启动或停止宿主热点', () async {
    container = create(safeMode: true);
    final controller = container.read(hotspotControllerProvider.notifier);
    controller.startMonitoring();
    await controller.refresh();
    await controller.setEnabled(true);
    await controller.shutdown();
    expect(backend.calls, isEmpty);
  });

  test('未启动规则模式 TUN 时拒绝开启', () async {
    container = create(ready: false);
    await container.read(hotspotControllerProvider.notifier).setEnabled(true);
    expect(backend.calls, isEmpty);
    expect(container.read(hotspotControllerProvider).error, 'tun_required');
  });

  test('开启尚未完成时关闭，最终状态服从最后一次操作', () async {
    container = create();
    backend.enableGate = Completer<void>();
    final controller = container.read(hotspotControllerProvider.notifier);
    final enable = controller.setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    final disable = controller.setEnabled(false);
    backend.enableGate!.complete();
    await Future.wait([enable, disable]);
    expect(backend.calls, [HotspotCommand.enable, HotspotCommand.disable]);
    expect(container.read(hotspotControllerProvider).managed, isFalse);
  });

  test('识别实际发生过的 TUN 旁路并请求重建共享', () async {
    container = create();
    backend.snapshot = const HotspotSnapshot(managed: true, on: true);
    await container.read(hotspotControllerProvider.notifier).refresh();
    expect(backend.calls, [HotspotCommand.inspect, HotspotCommand.repair]);
    expect(container.read(hotspotControllerProvider).throughTun, isTrue);
  });

  test('不接管不属于本功能的现有热点', () async {
    container = create();
    backend.snapshot = const HotspotSnapshot(on: true);
    await container.read(hotspotControllerProvider.notifier).refresh();
    expect(backend.calls, [HotspotCommand.inspect]);
    expect(container.read(hotspotControllerProvider).managed, isFalse);
  });

  test('修复失败后保留错误并显示共享已停止', () async {
    container = create();
    backend.snapshot = const HotspotSnapshot(managed: true, on: true);
    backend.repairFails = true;
    await container.read(hotspotControllerProvider.notifier).refresh();
    final state = container.read(hotspotControllerProvider);
    expect(state.managed, isFalse);
    expect(state.error, 'sharing_bypass');
  });

  test('退出清理停止自己管理的热点', () async {
    container = create();
    final controller = container.read(hotspotControllerProvider.notifier);
    await controller.setEnabled(true);
    await controller.shutdown();
    expect(backend.calls.last, HotspotCommand.disable);
    expect(container.read(hotspotControllerProvider).managed, isFalse);
  });

  test('TUN 或规则模式不可用时停止自己管理的热点', () async {
    container = create();
    final controller = container.read(hotspotControllerProvider.notifier);
    await controller.setEnabled(true);
    container.updateOverrides([
      hotspotBackendProvider.overrideWithValue(backend),
      hotspotSupportedProvider.overrideWithValue(true),
      hotspotReadyProvider.overrideWithValue(false),
      safeModeProvider.overrideWithValue(false),
    ]);
    await container.pump();
    await Future<void>.delayed(Duration.zero);
    expect(backend.calls.last, HotspotCommand.disable);
    expect(container.read(hotspotControllerProvider).managed, isFalse);
  });

  test('读取状态期间的新操作会排队并可以等待完成', () async {
    container = create();
    backend.inspectGate = Completer<void>();
    final controller = container.read(hotspotControllerProvider.notifier);
    final inspect = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    final enable = controller.setEnabled(true);
    backend.inspectGate!.complete();
    await Future.wait([inspect, enable]);
    expect(backend.calls, [HotspotCommand.inspect, HotspotCommand.enable]);
    expect(container.read(hotspotControllerProvider).managed, isTrue);
  });
}

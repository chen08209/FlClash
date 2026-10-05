import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SceneLinkageManager extends ConsumerStatefulWidget {
  final Widget child;

  const SceneLinkageManager({super.key, required this.child});

  @override
  ConsumerState<SceneLinkageManager> createState() =>
      _SceneLinkageManagerState();
}

class _SceneLinkageManagerState extends ConsumerState<SceneLinkageManager> {
  Timer? _timer;
  String? _lastCandidatePackage;
  DateTime? _candidateStartTime;
  String? _appliedPackage;

  @override
  void initState() {
    super.initState();
    if (system.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkSync();
      });
      ref.listenManual(isStartProvider, (_, _) => _checkSync());
      ref.listenManual(sceneLinkageSettingProvider, (_, _) => _checkSync());
    }
  }

  void _checkSync() {
    final isStart = ref.read(isStartProvider);
    final setting = ref.read(sceneLinkageSettingProvider);
    final shouldRun = system.isAndroid && isStart && setting.enable;

    if (shouldRun) {
      _startWatcher();
    } else {
      _stopWatcher();
    }
  }

  void _startWatcher() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _pollForegroundApp(),
    );
  }

  void _stopWatcher() {
    _timer?.cancel();
    _timer = null;
    _lastCandidatePackage = null;
    _candidateStartTime = null;
    _appliedPackage = null;
  }

  @override
  void dispose() {
    _stopWatcher();
    super.dispose();
  }

  Future<void> _pollForegroundApp() async {
    if (!mounted || app == null) return;
    final fgPackage = await app!.getForegroundPackage();
    if (fgPackage == null || fgPackage.isEmpty) return;

    final now = DateTime.now();
    if (_lastCandidatePackage != fgPackage) {
      _lastCandidatePackage = fgPackage;
      _candidateStartTime = now;
      return;
    }

    if (_candidateStartTime == null ||
        now.difference(_candidateStartTime!).inMilliseconds < 1500) {
      return;
    }

    if (_appliedPackage == fgPackage) {
      return;
    }

    _appliedPackage = fgPackage;
    _processLinkageForPackage(fgPackage);
  }

  void _processLinkageForPackage(String packageName) {
    final props = ref.read(sceneLinkageSettingProvider);
    if (!props.enable) return;

    SceneRule? matchedRule;
    for (final rule in props.rules) {
      if (rule.enable && rule.packageNames.contains(packageName)) {
        matchedRule = rule;
        break;
      }
    }

    if (matchedRule == null) {
      return;
    }

    final profiles = ref.read(profilesProvider);
    final currentProfile = ref.read(currentProfileProvider);
    Profile? targetProfile;

    if (matchedRule.profileId != null && matchedRule.profileId!.isNotEmpty) {
      targetProfile = profiles.firstWhere(
        (p) => p.id.toString() == matchedRule!.profileId,
        orElse: () => currentProfile ?? profiles.first,
      );
    } else {
      targetProfile = currentProfile;
    }

    if (targetProfile == null) return;

    if (currentProfile?.id != targetProfile.id) {
      ref.read(currentProfileIdProvider.notifier).value = targetProfile.id;
    }

    String? nodeChangedName;
    if (matchedRule.proxyName != null && matchedRule.proxyName!.isNotEmpty) {
      final proxyName = matchedRule.proxyName!;
      final currentGroup = targetProfile.currentGroupName;
      ref
          .read(proxiesActionProvider.notifier)
          .changeProxyDebounce(currentGroup, proxyName);
      nodeChangedName = proxyName;
    }

    if (props.enableNotification && matchedRule.enableNotification) {
      final packages = ref.read(packagesProvider);
      final package = packages.firstWhere(
        (p) => p.packageName == packageName,
        orElse: () => Package(packageName: packageName, label: packageName),
      );
      final appName = package.label;
      final profileName = targetProfile.label;
      final nodeDisplay = nodeChangedName ?? '最近节点';

      app?.showSceneNotification(
        title: '应用场景联动',
        content: '已为 [$appName] 切换至 [$profileName] · [$nodeDisplay]',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

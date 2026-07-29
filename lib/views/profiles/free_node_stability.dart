import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FreeNodeStabilitySheet extends ConsumerStatefulWidget {
  final Profile profile;

  const FreeNodeStabilitySheet({super.key, required this.profile});

  @override
  ConsumerState<FreeNodeStabilitySheet> createState() =>
      _FreeNodeStabilitySheetState();
}

class _FreeNodeStabilitySheetState
    extends ConsumerState<FreeNodeStabilitySheet> {
  final List<FreeNodeStabilityResult> _results = [];
  bool _testing = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runTest();
    });
  }

  Future<void> _runTest() async {
    setState(() {
      _testing = true;
      _error = null;
      _results.clear();
      _total = 0;
    });
    try {
      final profilesAction = ref.read(profilesActionProvider.notifier);
      final checkedOnSelection = await profilesAction.selectProfile(
        widget.profile.id,
      );
      if (!checkedOnSelection) {
        await profilesAction.checkFreeNodesProfileAutoUpdateIfNeeded(
          widget.profile.id,
        );
      }
      await ref
          .read(setupActionProvider.notifier)
          .applyProfile(force: true, silence: true);
      final latestProfile =
          ref.read(profilesProvider).getProfile(widget.profile.id) ??
          widget.profile;
      final names = await freeNodesService.getProfileProxyNames(latestProfile);
      final testUrl = ref.read(appSettingProvider).testUrl;
      setState(() {
        _total = names.length;
      });
      var nextIndex = 0;
      Future<void> worker() async {
        while (nextIndex < names.length && mounted) {
          final name = names[nextIndex++];
          final result = await freeNodesService.testProxyStability(
            proxyName: name,
            testUrl: testUrl,
          );
          _addResult(result);
        }
      }

      final workers = names.length.clamp(1, 12);
      await Future.wait([for (var i = 0; i < workers; i++) worker()]);
      if (!mounted) {
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _testing = false;
        });
      }
    }
  }

  void _addResult(FreeNodeStabilityResult result) {
    if (!mounted) return;
    setState(() {
      _results.add(result);
      _results.sort((a, b) {
        final aDelay = a.averageDelay ?? 1 << 30;
        final bDelay = b.averageDelay ?? 1 << 30;
        return aDelay.compareTo(bDelay);
      });
    });
  }

  Color _levelColor(FreeNodeStabilityLevel level) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (level) {
      FreeNodeStabilityLevel.good => Colors.green,
      FreeNodeStabilityLevel.normal => colorScheme.tertiary,
      FreeNodeStabilityLevel.poor => colorScheme.error,
    };
  }

  String _levelText(FreeNodeStabilityLevel level) {
    return switch (level) {
      FreeNodeStabilityLevel.good => '稳定',
      FreeNodeStabilityLevel.normal => '一般',
      FreeNodeStabilityLevel.poor => '波动',
    };
  }

  Widget _buildBody() {
    if (_error != null) {
      return ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: context.sheetTopPadding,
          bottom: 32,
        ),
        children: [
          ListItem(
            leading: Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(_error!),
            subtitle: const Text('稳定性测试未完成'),
          ),
        ],
      );
    }
    if (_total == 0 && _testing) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: context.sheetTopPadding,
        bottom: 32,
      ),
      itemCount: _results.length + (_testing ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == 0 && _testing) {
          return ListItem(
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            title: Text('测试中 ${_results.length}/$_total'),
            subtitle: const Text('最多 12 个节点并发，每个节点快速测试 2-4 次'),
          );
        }
        final result = _results[index - (_testing ? 1 : 0)];
        final color = _levelColor(result.level);
        final average = result.averageDelay;
        return ListItem(
          leading: Icon(Icons.circle, color: color, size: 14),
          title: Text(
            result.proxyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '均值 ${average == null ? '-' : '${average}ms'} · 方差 ${result.variance.toStringAsFixed(0)} · 失败 ${result.failures}/${result.delays.length + result.failures}',
          ),
          trailing: Text(
            _levelText(result.level),
            style: context.textTheme.labelLarge?.copyWith(color: color),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      title: '稳定性测试',
      actions: [
        IconButtonData(
          icon: Icons.refresh,
          onPressed: _testing ? () {} : _runTest,
        ),
      ],
      body: _buildBody(),
    );
  }
}

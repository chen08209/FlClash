import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpeedTestButton extends ConsumerWidget {
  const SpeedTestButton({super.key});

  void _handleDelayTest(WidgetRef ref) {
    final groups = ref.read(currentGroupsStateProvider).value;
    ref.read(proxiesActionProvider.notifier).delayTestGroups(groups);
  }

  Widget _buildIcon(BuildContext context, bool isDelayTesting) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: isDelayTesting
          ? const SizedBox.square(
              key: ValueKey('loading'),
              dimension: 24,
              child: CommonCircleLoading(),
            )
          : const GlyphIcon(
              AppGlyphs.bolt,
              key: ValueKey('icon'),
              fill: 1,
            ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return const SizedBox.shrink();
    }
    final isDelayTesting = ref.watch(
      delayTestingGroupsProvider.select((groups) => groups.isNotEmpty),
    );
    final appLocalizations = context.appLocalizations;

    return ElasticButton(
      enabled: !isDelayTesting,
      child: FloatingActionButton(
        heroTag: null,
        tooltip: appLocalizations.delayTest,
        onPressed: isDelayTesting ? null : () => _handleDelayTest(ref),
        child: _buildIcon(context, isDelayTesting),
      ),
    );
  }
}

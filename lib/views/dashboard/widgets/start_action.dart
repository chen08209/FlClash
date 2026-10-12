import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartAction extends ConsumerWidget {
  const StartAction({super.key, this.floating = false});

  final bool floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return const SizedBox.shrink();
    }
    final isStart = ref.watch(isStartProvider);
    final appLocalizations = context.appLocalizations;
    final tooltip = isStart ? appLocalizations.stop : appLocalizations.start;
    void onPressed() => ref.read(commonActionProvider.notifier).toggleRunning();
    final icon = TweenAnimationBuilder<double>(
      tween: Tween(end: isStart ? 1 : 0),
      duration: context.motionDuration(const Duration(milliseconds: 450)),
      curve: Curves.easeOutBack,
      builder: (_, progress, _) =>
          GlyphIcon(AppGlyphs.playPause(progress), fill: floating ? 1 : 0),
    );
    return floating
        ? FloatingActionButton(
            heroTag: null,
            tooltip: tooltip,
            onPressed: onPressed,
            child: icon,
          )
        : IconButton(tooltip: tooltip, onPressed: onPressed, icon: icon);
  }
}

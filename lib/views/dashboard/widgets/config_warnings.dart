import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'card.dart';

final _warningsProvider = configWarningsStateProvider.select(
  (items) => items.warnings,
);

/// The phone dashboard's top card while the Core reports warnings about the
/// config it runs; a tap lists them.
class ConfigWarningsSlot extends ConsumerStatefulWidget {
  const ConfigWarningsSlot({super.key, required this.gap});

  final double gap;

  @override
  ConsumerState<ConfigWarningsSlot> createState() => _ConfigWarningsSlotState();
}

class _ConfigWarningsSlotState extends ConsumerState<ConfigWarningsSlot> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final warnings = ref.watch(_warningsProvider);
    return AnimatedSize(
      duration: context.disableAnimations ? Duration.zero : commonDuration,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: warnings.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.only(bottom: widget.gap),
              child: RepaintBoundary(
                child: _ConfigWarningsCard(
                  warnings: warnings,
                  expanded: _expanded,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
              ),
            ),
    );
  }
}

class _ConfigWarningsCard extends StatelessWidget {
  const _ConfigWarningsCard({
    required this.warnings,
    required this.expanded,
    required this.onTap,
  });

  final List<ConfigWarning> warnings;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final title = context.appLocalizations.configWarnings;
    return DashboardCard(
      onTap: onTap,
      semanticLabel: title,
      child: AnimatedSize(
        duration: context.disableAnimations ? Duration.zero : commonDuration,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            DashboardCardHeader(
              glyph: AppGlyphs.warning,
              title: title,
              leading: [
                DashboardChip(
                  label: '${warnings.length}',
                  tone: DashboardChipTone.warn,
                ),
              ],
              trailing: [
                GlyphIcon(
                  expanded ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (expanded)
              for (final warning in warnings)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warning.message,
                      style: AppTextStyle.subheadline.of(context),
                    ),
                    if (warning.path.isNotEmpty)
                      Text(warning.path, style: DashboardText.label(context)),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

/// The desktop dashboard's bar button while the Core reports warnings.
class ConfigWarningsButton extends ConsumerWidget {
  const ConfigWarningsButton({super.key});

  Future<void> _handlePressed(List<ConfigWarning> warnings) {
    return dialogs.showAlert(
      title: currentAppLocalizations.configWarnings,
      message: TextSpan(
        text: warnings
            .map(
              (warning) => warning.path.isEmpty
                  ? warning.message
                  : '${warning.message}\n${warning.path}',
            )
            .join('\n\n'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warnings = ref.watch(_warningsProvider);
    final colorScheme = context.colorScheme;
    final title = context.appLocalizations.configWarnings;
    final pane = TonalButtonTheme.glassOf(context)
        ? LiquidGlassStyle.tinted(colorScheme, colorScheme.warningContainer)
        : null;
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: warnings.isEmpty
          ? const SizedBox.shrink()
          : Tooltip(
              message: title,
              child: FilledButton.icon(
                onPressed: () => unawaited(_handlePressed(warnings)),
                style: ButtonStyle.from(
                  backgroundColor: pane == null
                      ? colorScheme.warningContainer
                      : Colors.transparent,
                  foregroundColor: colorScheme.onWarningContainer,
                  backgroundBuilder: pane == null
                      ? null
                      : LiquidGlass.buttonBackground((_) => pane),
                  pressLook: PressLook.none,
                ),
                icon: GlyphIcon(
                  AppGlyphs.warning,
                  fill: 1,
                  size: globalState.measure.textHeight(
                    AppTextStyle.subheadline,
                  ),
                ),
                label: Text('${warnings.length}'),
              ),
            ),
    );
  }
}

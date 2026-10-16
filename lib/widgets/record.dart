import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class RecordTextStyles {
  final TextStyle title;
  final TextStyle primary;
  final TextStyle secondary;

  const RecordTextStyles._({
    required this.title,
    required this.primary,
    required this.secondary,
  });

  factory RecordTextStyles.of(BuildContext context) {
    final colorScheme = context.colorScheme;
    return RecordTextStyles._(
      title: AppTextStyle.subheadline
          .of(context, emphasized: true)
          .copyWith(color: colorScheme.onSurface),
      primary: AppTextStyle.subheadline
          .of(context)
          .copyWith(color: colorScheme.onSurface),
      secondary: AppTextStyle.footnote
          .of(context)
          .copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

const recordListGap = 8.0;

double recordListExtentEstimation(int? index, double crossAxisExtent) {
  return switch (index) {
    // SuperSliverList gives every child the null estimate unless it is 0.
    null => 0,
    _ when index.isEven => 100,
    _ => recordListGap,
  };
}

class RecordListItem extends StatelessWidget {
  final Widget header;
  final Widget body;
  final VoidCallback? onTap;

  const RecordListItem({
    super.key,
    required this.header,
    required this.body,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const shape = AppShape.xl;
    final level = context.raisedSurfaceLevel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: level.colorOf(context.colorScheme),
          shape: shape,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SurfaceScope(
            level: level,
            child: ListTileTheme.merge(
              shape: shape,
              child: ListItem(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                minVerticalPadding: 0,
                minTileHeight: 0,
                horizontalTitleGap: 12,
                tileTitleAlignment: ListTileTitleAlignment.top,
                onTap: onTap,
                title: header,
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: body,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecordHeader extends StatelessWidget {
  final List<Widget> children;
  final Widget? trailing;

  const RecordHeader({super.key, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return DefaultTextStyle.merge(
      style: AppTextStyle.caption1
          .of(context)
          .toTabular
          .copyWith(color: context.colorScheme.onSurfaceVariant),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: children,
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class RecordLabel extends StatelessWidget {
  final String label;
  final RecordTone tone;
  final VoidCallback? onPressed;

  const RecordLabel({
    super.key,
    required this.label,
    this.tone = RecordTone.neutral,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TonalChip(
      label: label,
      color: tone.labelContainerColor(context),
      foregroundColor: tone.labelColor(context),
      onPressed: onPressed,
    );
  }
}

class RecordTimestamp extends StatelessWidget {
  final String dateTime;

  const RecordTimestamp(this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(dateTime, maxLines: 1);
  }
}

class RecordArrow extends StatelessWidget {
  const RecordArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '→',
      style: RecordTextStyles.of(context).secondary.toJetBrainsMono,
    );
  }
}

class DetailRow extends StatelessWidget {
  final String title;
  final Widget? value;
  final String? copyText;

  const DetailRow({super.key, required this.title, this.value, this.copyText});

  DetailRow.text({super.key, required this.title, required String value})
    : value = Text(value),
      copyText = value;

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final copyText = this.copyText;
    return DecorationListItem(
      onPressed: copyText == null ? null : () => _copy(context, copyText),
      title: value == null
          ? Text(title)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              children: [
                Text(title),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DefaultTextStyle.merge(
                      textAlign: TextAlign.end,
                      style: AppTextStyle.subheadline
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                      child: value,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'chip.dart';
import 'list.dart';

class RecordTextStyles {
  final TextStyle? primary;
  final TextStyle? secondary;
  final TextStyle? muted;

  const RecordTextStyles._({this.primary, this.secondary, this.muted});

  factory RecordTextStyles.of(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final secondary = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return RecordTextStyles._(
      primary: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      secondary: secondary,
      muted: secondary?.copyWith(color: colorScheme.outline),
    );
  }
}

class RecordListItem extends StatelessWidget {
  final Widget header;
  final Widget body;
  final RecordTone tone;
  final VoidCallback? onTap;

  const RecordListItem({
    super.key,
    required this.header,
    required this.body,
    this.tone = RecordTone.neutral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = ListItem(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      minVerticalPadding: 0,
      minTileHeight: 0,
      horizontalTitleGap: 12,
      tileTitleAlignment: ListTileTitleAlignment.top,
      color: tone.tintColor(context),
      onTap: onTap,
      title: header,
      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: body),
    );
    final accentColor = tone.accentColor(context);
    if (accentColor == null) {
      return item;
    }
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: item,
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
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
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
    final split = dateTime.lastIndexOf(' ');
    return Text.rich(
      TextSpan(
        children: [
          if (split > 0)
            TextSpan(
              text: dateTime.substring(0, split + 1),
              style: TextStyle(color: context.colorScheme.outline),
            ),
          TextSpan(text: split > 0 ? dateTime.substring(split + 1) : dateTime),
        ],
      ),
      maxLines: 1,
    );
  }
}

class RecordArrow extends StatelessWidget {
  const RecordArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '→',
      style: RecordTextStyles.of(context).muted?.toJetBrainsMono,
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
                      style: context.textTheme.bodyMedium?.copyWith(
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

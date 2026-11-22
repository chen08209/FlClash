import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';

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

const recordListEstimatedExtent = 100.0;

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
    final level = context.raisedSurfaceLevel;
    return PressSurface(
      fill: level.colorOf(context.colorScheme),
      shape: AppShape.xl,
      onPressed: onTap,
      child: SurfaceScope(
        level: level,
        child: ListRow(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          minVerticalPadding: 0,
          minHeight: 0,
          horizontalTitleGap: 12,
          alignment: ListRowAlignment.top,
          title: header,
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: body,
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

PopupMenuItem copyMenuItem(
  String label,
  String text, {
  PopupMenuSection? section,
}) => PopupMenuItem(
  glyph: AppGlyphs.copy,
  label: label,
  section: section,
  onPressed: () => dialogs.copy(text),
);

class DetailRow extends StatelessWidget {
  final String title;
  final Widget value;
  final String? copyText;
  final Widget? leading;
  final bool _stacked;

  const DetailRow({
    super.key,
    required this.title,
    required this.value,
    this.copyText,
  }) : leading = null,
       _stacked = false;

  /// Copies [value] on a tap only when [copyable], which a detail keeps for
  /// the values one pastes elsewhere, such as hosts and addresses.
  DetailRow.text({
    super.key,
    required this.title,
    required String value,
    bool copyable = false,
  }) : value = Text(value),
       copyText = copyable ? value : null,
       leading = null,
       _stacked = false;

  /// [value] under the title in up to three lines, for one too long to end
  /// the title's line, such as a URL, a header or an error.
  DetailRow.stacked({
    super.key,
    required this.title,
    required String value,
    bool copyable = false,
    this.leading,
  }) : value = Text(value, maxLines: 3, overflow: TextOverflow.ellipsis),
       copyText = copyable ? value : null,
       _stacked = true;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final copyText = this.copyText;
    final onPressed = copyText == null ? null : () => dialogs.copy(copyText);
    if (_stacked) {
      return DecorationListItem(
        onPressed: onPressed,
        leading: leading,
        title: Text(title),
        subtitle: value,
      );
    }
    return DecorationListItem(
      onPressed: onPressed,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: DefaultTextStyle.merge(
        textAlign: TextAlign.end,
        style: context.listValueStyle.toTabular,
        child: value,
      ),
    );
  }
}

/// A row one level up from its run, marked at its start.
class RecordSelectedRow extends StatelessWidget {
  final Widget child;

  const RecordSelectedRow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SurfaceScope(level: context.raisedSurfaceLevel, child: child),
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 3,
              height: 16,
              decoration: ShapeDecoration(
                color: context.colorScheme.primary,
                shape: AppShape.full,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The head of a record's detail: its well, its name, a line under it, and
/// [actions] at the end, which share the width of the content below.
class DetailHeader extends StatelessWidget {
  final Widget Function(double size) well;
  final String title;
  final Widget subtitle;
  final List<Widget> actions;

  const DetailHeader({
    super.key,
    required this.well,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final compact = ViewScope.isMobileOf(context);
    return Row(
      spacing: compact ? 14 : 16,
      children: [
        well(compact ? 44 : 52),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (compact ? AppTextStyle.headline : AppTextStyle.title3)
                    .of(context, emphasized: true),
              ),
              DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.listSubtitleStyle.toTabular,
                child: subtitle,
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty) TonalButtonGroup(children: actions),
      ],
    );
  }
}

/// A short [label], such as a record type or a method, set in a well.
class LabelWell extends StatelessWidget {
  final String label;
  final double size;

  const LabelWell({super.key, required this.label, this.size = _listSize});

  static const _listSize = 40.0;

  TextStyle _styleOf(BuildContext context) {
    final large = size > _listSize;
    return switch (label.length) {
      <= 3 => large ? AppTextStyle.title3 : AppTextStyle.subheadline,
      4 => large ? AppTextStyle.callout : AppTextStyle.caption1,
      _ => large ? AppTextStyle.footnote : AppTextStyle.caption2,
    }.of(context, emphasized: true).toJetBrainsMono;
  }

  @override
  Widget build(BuildContext context) {
    return InsetWell(
      size: size,
      label: label,
      style: _styleOf(context),
      padding: EdgeInsets.all(AppCorner.fit(size) / 2),
    );
  }
}

class InsetWell extends StatelessWidget {
  final double size;
  final String label;
  final TextStyle style;
  final EdgeInsets padding;

  const InsetWell({
    super.key,
    required this.size,
    required this.label,
    required this.style,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: SurfaceLevel.inset.colorOf(colorScheme),
          shape: AppShape.all(AppCorner.fit(size)),
        ),
        child: Padding(
          padding: padding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: style.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pushes the detail a detail beside a list opens over it, in place of a
/// sheet; what lies under stays mounted, so its tab and scroll survive.
class DetailPane extends StatefulWidget {
  final Widget child;

  const DetailPane({super.key, required this.child});

  static DetailPaneState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<DetailPaneState>();

  @override
  State<DetailPane> createState() => DetailPaneState();
}

class DetailPaneState extends State<DetailPane> {
  ({String back, WidgetBuilder builder})? _pushed;

  void push({required String back, required WidgetBuilder builder}) =>
      setState(() => _pushed = (back: back, builder: builder));

  void _pop() => setState(() => _pushed = null);

  @override
  Widget build(BuildContext context) {
    final pushed = _pushed;
    final top = context.contentTopPadding;
    final margin = context.listInsets.margin;
    return Stack(
      children: [
        Offstage(
          offstage: pushed != null,
          child: TickerMode(enabled: pushed == null, child: widget.child),
        ),
        if (pushed != null) ...[
          TopInsetScope(
            inset: top + TonalButtonSize.bar.button + _backGap,
            child: Builder(builder: pushed.builder),
          ),
          PositionedDirectional(
            top: top,
            start: margin,
            end: margin,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TonalButton(
                size: TonalButtonSize.bar,
                glyph: Glyphs.backFor(Theme.of(context).platform),
                label: pushed.back,
                onPressed: _pop,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

const _backGap = 16.0;

/// Starts a record's head a gap below the sheet's bar, clear of its buttons.
class DetailSheet extends StatelessWidget {
  final String title;
  final Widget? menu;
  final Widget child;

  const DetailSheet({
    super.key,
    required this.title,
    this.menu,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      title: title,
      actions: [?menu],
      body: Builder(
        builder: (context) => TopInsetScope(
          inset: context.appBarInset + appBarContentGap,
          child: child,
        ),
      ),
    );
  }
}

/// A [DetailHeader] action that opens [items] as a menu.
class DetailMenuButton extends StatelessWidget {
  final List<PopupMenuItem> Function() items;

  const DetailMenuButton({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupAnchor(
      targetBuilder: (open) => AppBarActionButton(
        data: IconButtonData(
          glyph: AppGlyphs.more,
          tooltip: context.appLocalizations.more,
          onPressed: open,
        ),
      ),
      popupBuilder: (_) => PopupMenu(items: items()),
    );
  }
}

/// A figure in a card: its label, the figure, and what [below] adds under it.
class FigureCard extends StatelessWidget {
  final Glyph? glyph;
  final String label;
  final String figure;
  final List<Widget> below;

  const FigureCard({
    super.key,
    this.glyph,
    required this.label,
    required this.figure,
    this.below = const [],
  });

  @override
  Widget build(BuildContext context) {
    final caption = context.listCaptionStyle.toTabular;
    final glyph = this.glyph;
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: caption,
    );
    return Card(
      shape: AppShape.all(AppCorner.lg),
      child: Padding(
        padding: figureCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            if (glyph == null)
              labelText
            else
              Row(
                spacing: 4,
                children: [
                  GlyphIcon(
                    glyph,
                    size: footnoteGlyphSize,
                    color: caption.color,
                  ),
                  Flexible(child: labelText),
                ],
              ),
            Text(
              figure,
              maxLines: 1,
              style: AppTextStyle.title3
                  .of(context, emphasized: true)
                  .toTabular,
            ),
            ...below,
          ],
        ),
      ),
    );
  }
}

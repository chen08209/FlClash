import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'connection_condition_form.dart';
import 'connection_conditions.dart';
import 'connection_filters.dart';

final _grouped = NumberFormat.decimalPattern('en');

/// A list's status and add button, over the conditions set.
class ConditionFilterRow<T extends Object, S extends Enum>
    extends StatelessWidget {
  final ConditionFilterController<T, S> controller;

  const ConditionFilterRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.listInsets.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Flexible(child: _StatusMenuButton(controller: controller)),
                TonalButtonTheme(
                  size: TonalButtonSize.section,
                  child: AppBarActionButton(
                    data: IconButtonData(
                      glyph: AppGlyphs.add,
                      tooltip: context.appLocalizations.addCondition,
                      onPressed: () => showConditionDialog<T>(
                        context,
                        controller: controller,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (ConditionBlock.showsFor(controller))
              ConditionBlock<T>(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// The status shown, with its count, opening a menu of the others.
class _StatusMenuButton<T extends Object, S extends Enum>
    extends StatelessWidget {
  final ConditionFilterController<T, S> controller;

  const _StatusMenuButton({required this.controller});

  String _countOf(S status) => _grouped.format(controller.countOf(status));

  @override
  Widget build(BuildContext context) {
    final secondary = context.colorScheme.onSurfaceVariant;
    final style = AppTextStyle.subheadline.of(context).toTabular;
    return PopupAnchor(
      placement: PopupPlacement.overAnchorStart,
      targetBuilder: (open) => SizedBox(
        height: TonalButtonSize.section.button,
        child: Card(
          shape: AppShape.full,
          padding: const EdgeInsetsDirectional.only(
            start: 14,
            end: 10,
          ).resolve(Directionality.of(context)),
          onPressed: open,
          child: ListenableBuilder(
            listenable: controller.counted,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Flexible(
                  child: Text(
                    controller.labelOf(controller.status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.subheadline
                        .of(context, emphasized: true)
                        .copyWith(color: context.colorScheme.onSurface),
                  ),
                ),
                Text(
                  _countOf(controller.status),
                  maxLines: 1,
                  style: style.copyWith(color: secondary),
                ),
                GlyphIcon(AppGlyphs.picker, size: 16, color: secondary),
              ],
            ),
          ),
        ),
      ),
      popupBuilder: (_) => ListenableBuilder(
        listenable: Listenable.merge([controller, controller.counted]),
        builder: (_, _) => PopupMenu(
          items: [
            for (final status in controller.statuses)
              PopupMenuItem(
                label: controller.labelOf(status),
                detail: _countOf(status),
                checked: status == controller.status,
                onPressed: () => controller.status = status,
              ),
          ],
        ),
      ),
    );
  }
}

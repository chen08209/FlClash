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
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ListenableBuilder(
                      listenable: controller.counted,
                      builder: (_, _) => SegmentedControl<S>(
                        size: TonalButtonSize.compact,
                        segments: [
                          for (final status in controller.statuses)
                            (
                              status,
                              '${controller.labelOf(status)} '
                                  '${_grouped.format(controller.countOf(status))}',
                            ),
                        ],
                        value: controller.status,
                        onChanged: (status) => controller.status = status,
                      ),
                    ),
                  ),
                ),
                TonalButtonTheme(
                  size: TonalButtonSize.compact,
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

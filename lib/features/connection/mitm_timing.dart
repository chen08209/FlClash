import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'mitm_texts.dart';

/// What a request took: the wait for its response's first byte, then the
/// rest of its receiving, as shares of one bar.
class TimingCard extends StatelessWidget {
  final int waiting;
  final int total;

  const TimingCard({super.key, required this.waiting, required this.total});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final caption = context.listCaptionStyle.toTabular;
    final receiving = total - waiting;
    final waitColor = colorScheme.primary.opacity38;
    Widget legend(Color color, String label, int milliseconds) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(color: color, shape: AppShape.circle),
          child: const SizedBox.square(dimension: _timingDot),
        ),
        Text('$label ${httpMillisText(milliseconds)}', style: caption),
      ],
    );
    return FigureCard(
      label: appLocalizations.total,
      figure: httpMillisText(total),
      below: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: _timingBarHeight,
            child: Row(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (waiting > 0)
                  Expanded(
                    flex: waiting,
                    child: _TimingShare(color: waitColor),
                  ),
                if (receiving > 0)
                  Expanded(
                    flex: receiving,
                    child: _TimingShare(color: colorScheme.primary),
                  ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            legend(waitColor, appLocalizations.httpWaiting, waiting),
            legend(
              colorScheme.primary,
              appLocalizations.httpReceiving,
              receiving,
            ),
          ],
        ),
      ],
    );
  }
}

const _timingBarHeight = 6.0;

const _timingDot = 6.0;

class _TimingShare extends StatelessWidget {
  final Color color;

  const _TimingShare({required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
    );
  }
}

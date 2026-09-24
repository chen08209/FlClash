import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card for one of the live feeds: a label, its glyph and a single figure
/// over a tap that opens the feed's own list.
class FeedCard extends StatelessWidget {
  final String label;
  final Glyph glyph;
  final VoidCallback onPressed;
  final Widget child;

  const FeedCard({
    super.key,
    required this.label,
    required this.glyph,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        infoPadding: DashboardWidgetMetrics.paddingOf(
          context,
        ).copyWith(bottom: 0),
        info: Info(label: label, glyph: glyph),
        onPressed: onPressed,
        child: Container(
          padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height:
                    globalState.measure.bodyMediumHeight *
                        DashboardWidgetMetrics.textScaleOf(context) +
                    2,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedCount extends StatelessWidget {
  final int count;

  const FeedCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        '$count',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
      ),
    );
  }
}

/// Follows a counter that the Core drives per event, repainting on the same
/// cadence as the list the card opens.
class ThrottledFeedCount extends ConsumerStatefulWidget {
  final ProviderListenable<int> provider;

  const ThrottledFeedCount({super.key, required this.provider});

  @override
  ConsumerState<ThrottledFeedCount> createState() => _ThrottledFeedCountState();
}

class _ThrottledFeedCountState extends ConsumerState<ThrottledFeedCount> {
  late var _count = ref.read(widget.provider);
  late var _latest = _count;
  Timer? _repaint;
  var _active = true;

  @override
  void initState() {
    super.initState();
    ref.listenManual(widget.provider, (_, next) {
      _latest = next;
      if (!_active) {
        return;
      }
      _repaint ??= Timer(renderThrottleDuration, _showLatest);
    });
  }

  void _showLatest() {
    _repaint = null;
    setState(() => _count = _latest);
  }

  // A card can stay deactivated across timer ticks; a repaint there throws.
  @override
  void deactivate() {
    _active = false;
    _repaint?.cancel();
    _repaint = null;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _active = true;
    _count = _latest;
  }

  @override
  Widget build(BuildContext context) {
    return FeedCount(count: _count);
  }
}

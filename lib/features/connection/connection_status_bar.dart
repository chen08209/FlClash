import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;

final _grouped = NumberFormat.decimalPattern('en');

String _count(int count) => _grouped.format(count);

String _speedText(Traffic traffic) =>
    '↓ ${traffic.down.traffic.show}/s　↑ ${traffic.up.traffic.show}/s';

String _totalText(Traffic traffic) =>
    '↓ ${traffic.down.traffic.show}　↑ ${traffic.up.traffic.show}';

String _activeText(AppLocalizations appLocalizations, int active) =>
    '${appLocalizations.connectionsActive} ${_count(active)}';

/// What the page shows, how fast the Core moves now and what it has moved
/// this run, along the foot of a desktop page.
class ConnectionStatusBar extends ConsumerWidget {
  final int shown;
  final int active;
  final bool selected;
  final List<Widget> trailing;

  const ConnectionStatusBar({
    super.key,
    required this.shown,
    required this.active,
    this.selected = false,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final speed = ref.watch(
      trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
    );
    final total = ref.watch(totalTrafficProvider);
    return DefaultTextStyle.merge(
      style: AppTextStyle.caption1
          .of(context)
          .copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 20,
            children: [
              Expanded(
                child: Row(
                  spacing: 20,
                  children: [
                    Flexible(
                      child: Text(
                        [
                          appLocalizations.connectionsShown(shown),
                          _activeText(appLocalizations, active),
                          if (selected) appLocalizations.selectedCount(1),
                        ].join(' · '),
                      ),
                    ),
                    Flexible(child: Text(_speedText(speed))),
                    Flexible(
                      child: Text(
                        '${appLocalizations.thisRun} ${_totalText(total)}',
                      ),
                    ),
                  ],
                ),
              ),
              ...trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A phone's line under the filter strip: what it selects, or with nothing
/// selected, what is open and what this run has moved.
class ConnectionSummary extends ConsumerWidget {
  final int shown;
  final int active;
  final bool filtering;

  const ConnectionSummary({
    super.key,
    required this.shown,
    required this.active,
    required this.filtering,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final activeText = _activeText(appLocalizations, active);
    if (filtering) {
      return Text(
        '${appLocalizations.connectionsFiltered(shown)} · $activeText',
      );
    }
    final total = ref.watch(
      totalTrafficProvider.select((traffic) => traffic.down.traffic.show),
    );
    return Text('$activeText · ${appLocalizations.thisRun} ↓ $total');
  }
}

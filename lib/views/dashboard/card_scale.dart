import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const dashboardMinScale = 0.6;
const dashboardMaxScale = 1.6;

const _prefsKey = 'dashboardCardScales';

/// How much each dashboard card is scaled, by card name; a card not listed
/// keeps its own size. Kept apart from the app settings so it needs no
/// generated code.
class DashboardCardScales extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_prefsKey);
      if (raw == null) {
        return;
      }
      final decoded = json.decode(raw);
      if (decoded is Map) {
        state = {
          for (final entry in decoded.entries)
            if (entry.value is num)
              '${entry.key}': (entry.value as num)
                  .toDouble()
                  .clamp(dashboardMinScale, dashboardMaxScale)
                  .toDouble(),
        };
      }
    } catch (_) {}
  }

  void set(DashboardWidget item, double scale, {bool save = false}) {
    final clamped = scale
        .clamp(dashboardMinScale, dashboardMaxScale)
        .toDouble();
    final next = {...state};
    if ((clamped - 1).abs() < 0.02) {
      next.remove(item.name);
    } else {
      next[item.name] = clamped;
    }
    state = next;
    if (save) {
      this.save();
    }
  }

  Future<void> save() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_prefsKey, json.encode(state));
    } catch (_) {}
  }
}

final dashboardCardScalesProvider =
    NotifierProvider<DashboardCardScales, Map<String, double>>(
      DashboardCardScales.new,
    );

/// Lays [child] out as wide as it would be at its own size divided by the
/// card's scale, then scales it back to the column's width, so the card, its
/// text and its controls grow and shrink together and the list reflows.
///
/// It wraps the card at every scale, one included, so dragging through 1
/// does not rebuild the card.
class DashboardScaled extends ConsumerWidget {
  const DashboardScaled({super.key, required this.item, required this.child});

  final DashboardWidget item;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(
      dashboardCardScalesProvider.select((scales) => scales[item.name] ?? 1.0),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite) {
          return child;
        }
        return SizedBox(
          width: width,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(width: width / scale, child: child),
          ),
        );
      },
    );
  }
}

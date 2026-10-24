import 'package:fl_clash/common/application_proxy.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ApplicationProxyAggregator =
    Future<ApplicationProxySnapshot> Function(ApplicationProxyInput input);

final applicationRulesProvider = StreamProvider.autoDispose
    .family<List<Rule>, int>((ref, profileId) {
      return database.rulesDao.queryApplicationRules(profileId).watch();
    });

final applicationProxyAggregatorProvider = Provider<ApplicationProxyAggregator>(
  (ref) => (input) => compute(aggregateApplicationProxies, input),
);

final applicationProxyHistoryProvider =
    AsyncNotifierProvider<ApplicationProxyHistory, List<ApplicationProcess>>(
      ApplicationProxyHistory.new,
    );

class ApplicationProxyHistory extends AsyncNotifier<List<ApplicationProcess>> {
  final _seen = <ApplicationProcess>{};
  Future<void>? _writing;
  bool _dirty = false;

  @override
  Future<List<ApplicationProcess>> build() async {
    final history = await preferences.getApplicationProxyHistory();
    _seen
      ..clear()
      ..addAll(history);
    return List.unmodifiable(_seen);
  }

  Future<void> remember(Iterable<ApplicationProcess> processes) async {
    final batch = processes
        .where((process) => process.process.isNotEmpty || process.path.isNotEmpty)
        .toSet();
    if (batch.isEmpty) return;
    if (!state.hasValue) await future;
    if (!ref.mounted) return;
    final previousLength = _seen.length;
    _seen.addAll(batch);
    if (_seen.length == previousLength) return;
    state = AsyncData(List.unmodifiable(_seen));
    _dirty = true;
    await (_writing ??= _persist().whenComplete(() => _writing = null));
  }

  Future<void> _persist() async {
    do {
      _dirty = false;
      try {
        await preferences.saveApplicationProxyHistory(List.of(_seen));
      } catch (error) {
        commonPrint.log('saveApplicationProxyHistory error: $error');
      }
    } while (_dirty);
  }
}

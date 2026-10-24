import 'package:fl_clash/common/application_proxy.dart';
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

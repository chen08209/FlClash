import 'dart:collection';
import 'dart:math';

import 'package:fl_clash/models/models.dart';

typedef AppTrafficPersist =
    Future<void> Function(Iterable<AppTrafficDelta> deltas);
typedef AppTrafficProfileResolver = AppTrafficProfileContext Function();

class AppTrafficTracker {
  final AppTrafficPersist persist;
  final AppTrafficProfileResolver resolveProfile;
  final Map<String, _TrackedConnection> _connections = {};
  final LinkedHashSet<String> _closedConnectionIds = LinkedHashSet();

  AppTrafficTracker({required this.persist, required this.resolveProfile});

  void observeStart(TrackerInfo connection) {
    _closedConnectionIds.remove(connection.id);
    _connections.putIfAbsent(
      connection.id,
      () => _TrackedConnection(profile: resolveProfile()),
    );
  }

  Future<void> observeSnapshot(Iterable<TrackerInfo> connections) {
    final deltas = <AppTrafficDelta>[];
    for (final connection in connections) {
      if (_closedConnectionIds.contains(connection.id)) {
        continue;
      }
      final tracked = _connections.putIfAbsent(
        connection.id,
        () => _TrackedConnection(profile: resolveProfile()),
      );
      final delta = _buildDelta(connection, tracked);
      if (delta != null) {
        deltas.add(delta);
      }
    }
    return persist(deltas);
  }

  Future<void> observeClosed(TrackerInfo connection) {
    if (_closedConnectionIds.contains(connection.id)) {
      return Future.value();
    }
    final tracked =
        _connections.remove(connection.id) ??
        _TrackedConnection(profile: resolveProfile());
    final delta = _buildDelta(connection, tracked);
    _closedConnectionIds.add(connection.id);
    while (_closedConnectionIds.length > 2048) {
      _closedConnectionIds.remove(_closedConnectionIds.first);
    }
    return persist(delta == null ? const [] : [delta]);
  }

  AppTrafficDelta? _buildDelta(
    TrackerInfo connection,
    _TrackedConnection tracked,
  ) {
    final upload = max(0, connection.upload - tracked.upload);
    final download = max(0, connection.download - tracked.download);
    tracked.upload = max(tracked.upload, connection.upload);
    tracked.download = max(tracked.download, connection.download);
    if (upload == 0 && download == 0) {
      return null;
    }
    final proxy = connection.chains.isEmpty ? '' : connection.chains.first;
    if (connection.direct || proxy.isEmpty || proxy == 'DIRECT') {
      return null;
    }
    final identity = _applicationIdentity(connection.metadata);
    final providers = connection.providerChains.where(
      (value) => value.isNotEmpty,
    );
    final provider = providers.isEmpty ? '' : providers.first;
    final now = DateTime.now();
    return AppTrafficDelta(
      day: DateTime(now.year, now.month, now.day),
      profileId: tracked.profile.id,
      profileLabel: tracked.profile.label,
      applicationId: identity.id,
      applicationLabel: identity.label,
      processPath: connection.metadata.processPath,
      proxy: proxy,
      provider: provider,
      upload: upload,
      download: download,
    );
  }

  _ApplicationIdentity _applicationIdentity(Metadata metadata) {
    final path = metadata.processPath.trim();
    final match = RegExp(r'(^|/)([^/]+\.app)(/|$)').firstMatch(path);
    if (match != null) {
      final bundleName = match.group(2)!;
      final bundleEnd = match.end;
      return _ApplicationIdentity(
        id: path.substring(0, bundleEnd),
        label: bundleName.substring(0, bundleName.length - 4),
      );
    }
    final process = metadata.process.trim();
    if (path.isNotEmpty) {
      return _ApplicationIdentity(
        id: path,
        label: process.isEmpty ? path.split('/').last : process,
      );
    }
    if (process.isNotEmpty) {
      return _ApplicationIdentity(id: process, label: process);
    }
    return const _ApplicationIdentity(id: 'unknown', label: '');
  }
}

class _TrackedConnection {
  final AppTrafficProfileContext profile;
  int upload = 0;
  int download = 0;

  _TrackedConnection({required this.profile});
}

class _ApplicationIdentity {
  final String id;
  final String label;

  const _ApplicationIdentity({required this.id, required this.label});
}

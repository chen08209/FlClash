import 'dart:convert';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiMcpStoreProvider = Provider<AiMcpStore>((ref) => _LocalAiMcpStore());
final aiMcpServiceProvider = Provider<AiMcpService>((ref) {
  final service = AiMcpService(
    store: ref.read(aiMcpStoreProvider),
    backend: AppAiMcpBackend(ref),
  );
  ref.onDispose(service.dispose);
  return service;
});

class _LocalAiMcpStore implements AiMcpStore {
  static const key = 'aiMcpLocal';

  @override
  Future<Map<String, Object?>> load() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (prefs == null) throw StateError('preferences unavailable');
    final value = prefs.getString(key);
    return value == null ? {} : Map<String, Object?>.from(jsonDecode(value));
  }

  @override
  Future<void> save(Map<String, Object?> settings) async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (prefs == null || !await prefs.setString(key, jsonEncode(settings))) {
      throw StateError('preferences unavailable');
    }
  }
}

class AppAiMcpBackend implements AiMcpBackend {
  AppAiMcpBackend(this.ref);
  final Ref ref;

  Future<List<Group>> _groups() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      throw const AiMcpFailure('core_unavailable');
    }
    final groups = await ref
        .read(coreHandlerProvider)
        .getProxiesGroups(
          sortType: ProxiesSortType.none,
          delayMap: ref.read(delayDataSourceProvider),
          selectedMap: const {},
          defaultTestUrl: ref.read(appSettingProvider).testUrl,
        );
    return groups.where((group) => group.hidden != true).toList();
  }

  String _name(Map<String, dynamic> args, String key) {
    final value = args[key];
    if (value is! String || value.isEmpty || value.length > 256) {
      throw const AiMcpFailure('invalid_arguments');
    }
    return value;
  }

  @override
  Future<Map<String, Object?>> execute(
    String name,
    Map<String, dynamic> arguments,
    void Function() checkPermission,
  ) async {
    final allowed = switch (name) {
      'app_status' || 'close_connections' => <String>{},
      'list_proxies' => {'offset', 'limit'},
      'select_proxy' => {'group', 'node'},
      'test_delays' => {'nodes'},
      'set_mode' => {'mode'},
      _ => throw const AiMcpFailure('unknown_tool'),
    };
    if (arguments.keys.any((key) => !allowed.contains(key))) {
      throw const AiMcpFailure('invalid_arguments');
    }
    checkPermission();
    switch (name) {
      case 'app_status':
        return {
          'app': 'FlClash',
          'core': ref.read(coreStatusProvider).name,
          'running': ref.read(runTimeProvider) != null,
          'configuredMode': ref.read(patchClashConfigProvider).mode.name,
        };
      case 'list_proxies':
        final offset = arguments['offset'] ?? 0;
        final limit = arguments['limit'] ?? 50;
        if (offset is! int ||
            offset < 0 ||
            limit is! int ||
            limit < 1 ||
            limit > 100) {
          throw const AiMcpFailure('invalid_arguments');
        }
        final groups = await _groups();
        checkPermission();
        final url = ref.read(appSettingProvider).testUrl;
        final delays = ref.read(delayDataSourceProvider)[url] ?? {};
        final rows = groups.expand(
          (group) => group.all.map(
            (node) => {
              'group': group.name,
              'groupType': group.type.value,
              'selectable': group.type == GroupType.Selector,
              'selected': group.now,
              'node': node.name,
              'type': node.type,
              'delayMs': delays[node.name],
            },
          ),
        );
        final page = rows.skip(offset).take(limit + 1).toList();
        return {
          'items': page.take(limit).toList(),
          'nextOffset': page.length > limit ? offset + limit : null,
        };
      case 'select_proxy':
        final groupName = _name(arguments, 'group');
        final nodeName = _name(arguments, 'node');
        final profile = ref.read(currentProfileProvider);
        if (profile == null) throw const AiMcpFailure('profile_unavailable');
        final groups = await _groups();
        final group = groups.getGroup(groupName);
        if (group == null ||
            group.type != GroupType.Selector ||
            !group.all.any((node) => node.name == nodeName)) {
          throw const AiMcpFailure('invalid_selection');
        }
        void checkSelection() {
          checkPermission();
          if (!ref.mounted ||
              ref.read(currentProfileProvider)?.id != profile.id) {
            throw const AiMcpFailure('profile_changed');
          }
        }
        checkSelection();
        final applied = await ref
            .read(proxiesActionProvider.notifier)
            .changeProxy(
              groupName: groupName,
              proxyName: nodeName,
              notifyFailure: false,
              maintainConnections: false,
              checkContinuation: checkSelection,
            );
        if (!applied) throw const AiMcpFailure('selection_failed');
        checkSelection();
        final actual = (await _groups()).getGroup(groupName)?.now;
        checkSelection();
        final selectedProfile = ref.read(currentProfileProvider);
        if (actual != nodeName ||
            selectedProfile?.id != profile.id ||
            selectedProfile?.selectedMap[groupName] != nodeName) {
          throw const AiMcpFailure('selection_not_confirmed');
        }
        return {
          'group': groupName,
          'selected': actual,
          'persistence': 'app_managed',
        };
      case 'test_delays':
        final nodes = arguments['nodes'];
        if (nodes is! List ||
            nodes.isEmpty ||
            nodes.length > AiMcpService.maxDelayNodes ||
            nodes.toSet().length != nodes.length ||
            nodes.any(
              (node) => node is! String || node.isEmpty || node.length > 256,
            )) {
          throw const AiMcpFailure('invalid_arguments');
        }
        final action = ref.read(proxiesActionProvider.notifier);
        final generation = action.delayTestGeneration;
        final profileId = ref.read(currentProfileIdProvider);
        void checkDelayRun() {
          checkPermission();
          if (!ref.mounted ||
              generation != action.delayTestGeneration ||
              ref.read(currentProfileIdProvider) != profileId ||
              ref.read(coreStatusProvider) != CoreStatus.connected) {
            throw const AiMcpFailure('delay_cancelled');
          }
        }
        checkDelayRun();
        final existing = (await _groups())
            .expand((group) => group.all)
            .map((node) => node.name)
            .toSet();
        checkDelayRun();
        if (nodes.any((node) => !existing.contains(node))) {
          throw const AiMcpFailure('unknown_node');
        }
        final url = ref.read(appSettingProvider).testUrl;
        final results = <Map<String, Object?>>[];
        for (var i = 0; i < nodes.length; i += 2) {
          checkDelayRun();
          final batch = nodes.skip(i).take(2);
          results.addAll(
            await Future.wait(
              batch.map((node) async {
                checkDelayRun();
                final delay = await ref
                    .read(coreHandlerProvider)
                    .getDelay(url, node as String);
                checkDelayRun();
                if (delay == null || delay.value == null) {
                  throw const AiMcpFailure('delay_backend_failure');
                }
                ref.read(proxiesActionProvider.notifier).setDelay(delay);
                return <String, Object?>{'node': node, 'delayMs': delay.value};
              }),
            ),
          );
        }
        return {'results': results};
      case 'set_mode':
        final mode = _name(arguments, 'mode');
        if (!Mode.values.any((value) => value.name == mode)) {
          throw const AiMcpFailure('invalid_arguments');
        }
        checkPermission();
        ref
            .read(setupActionProvider.notifier)
            .changeMode(Mode.values.byName(mode));
        return {'configuredMode': mode, 'coreApplication': 'requested'};
      case 'close_connections':
        if (ref.read(coreStatusProvider) != CoreStatus.connected) {
          throw const AiMcpFailure('core_unavailable');
        }
        checkPermission();
        final closed = await ref.read(coreHandlerProvider).closeConnections();
        if (!closed) throw const AiMcpFailure('close_failed');
        return {'closed': true};
      default:
        throw const AiMcpFailure('unknown_tool');
    }
  }
}

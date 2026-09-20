import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _Core extends Mock implements CoreHandlerInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => registerFallbackValue(
      const ChangeProxyParams(groupName: 'group', proxyName: 'one'),
    ),
  );
  for (final debounce in [false, true]) {
    for (final reverse in [false, true]) {
      for (final firstSuccess in [false, true]) {
        for (final secondSuccess in [false, true]) {
          test(
            'real database echoes preserve MCP/manual rollback debounce=$debounce reverse=$reverse first=$firstSuccess second=$secondSuccess',
            () async {
              final database = db.Database(NativeDatabase.memory());
              db.database = database;
              final core = _Core();
              final container = ProviderContainer(
                overrides: [
                  coreHandlerProvider.overrideWithValue(
                    CoreController.scoped(core),
                  ),
                  currentProfileIdProvider.overrideWithBuild((_, _) => 1),
                ],
              );
              addTearDown(() async {
                debouncer.cancel((FunctionTag.changeProxy, 'group'));
                debouncer.cancel(FunctionTag.updateGroups);
                container.dispose();
                await database.close();
              });
              container.listen(profilesProvider, (_, _) {});
              await container.read(profilesStreamProvider.future);
              container
                  .read(profilesProvider.notifier)
                  .put(
                    const Profile(
                      id: 1,
                      autoUpdateDuration: Duration.zero,
                      selectedMap: {'group': 'one'},
                    ),
                  );
              await pumpEventQueue();
              container.read(coreStatusProvider.notifier).value =
                  CoreStatus.connected;
              when(core.getProxies).thenAnswer(
                (_) async => const ProxiesData(
                  all: ['group'],
                  proxies: {
                    'group': {
                      'name': 'group',
                      'type': 'Selector',
                      'now': 'one',
                      'all': ['one', 'two', 'three'],
                    },
                    'one': {'name': 'one', 'type': 'ss'},
                    'two': {'name': 'two', 'type': 'ss'},
                    'three': {'name': 'three', 'type': 'ss'},
                  },
                ),
              );
              when(core.resetConnections).thenAnswer((_) async => true);
              when(core.closeConnections).thenAnswer((_) async => true);
              final entered = [Completer<void>(), Completer<void>()];
              final replies = [Completer<String>(), Completer<String>()];
              var calls = 0;
              when(() => core.changeProxy(any())).thenAnswer((_) {
                final index = calls++;
                entered[index].complete();
                return replies[index].future;
              });
              final backend = container.read(
                Provider((ref) => AppAiMcpBackend(ref)),
              );
              final first = backend.execute('select_proxy', {
                'group': 'group',
                'node': 'two',
              }, () {});
              final firstChecked = expectLater(
                first,
                throwsA(isA<AiMcpFailure>()),
              );
              await entered[0].future;
              await pumpEventQueue();
              expect(
                (await database.profilesDao.query().get())
                    .single
                    .selectedMap['group'],
                'two',
              );
              final action = container.read(proxiesActionProvider.notifier);
              Future<bool>? second;
              if (debounce) {
                action.changeProxyDebounce('group', 'three');
              } else {
                second = action.changeProxy(
                  groupName: 'group',
                  proxyName: 'three',
                  notifyFailure: false,
                  maintainConnections: false,
                );
              }
              await entered[1].future;
              await pumpEventQueue();
              expect(
                (await database.profilesDao.query().get())
                    .single
                    .selectedMap['group'],
                'three',
              );
              for (final index in reverse ? [1, 0] : [0, 1]) {
                replies[index].complete(
                  (index == 0 ? firstSuccess : secondSuccess) ? '' : 'rejected',
                );
                await pumpEventQueue();
              }
              await firstChecked;
              if (second != null) await second;
              await pumpEventQueue();
              final expected = secondSuccess
                  ? 'three'
                  : firstSuccess
                  ? 'two'
                  : 'one';
              expect(
                container.read(currentProfileProvider)!.selectedMap['group'],
                expected,
              );
              expect(
                (await database.profilesDao.query().get())
                    .single
                    .selectedMap['group'],
                expected,
              );
            },
          );
        }
      }
    }
  }
}

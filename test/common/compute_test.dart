import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('computeRealSelectedProxyState', () {
    test('returns state unchanged when proxyName is empty', () {
      final state = computeRealSelectedProxyState(
        '',
        groups: [],
        selectedMap: {},
      );
      expect(state.proxyName, '');
      expect(state.group, false);
    });

    test('resolves to leaf proxy not in any group', () {
      final state = computeRealSelectedProxyState(
        'proxy-a',
        groups: [],
        selectedMap: {},
      );
      expect(state.proxyName, 'proxy-a');
      expect(state.group, true);
    });

    test('resolves single-hop chain via selectedMap', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          all: [
            Proxy(name: 'proxy-a', type: 'ss'),
            Proxy(name: 'proxy-b', type: 'ss'),
          ],
        ),
      ];
      final selectedMap = {'auto': 'proxy-a'};
      final state = computeRealSelectedProxyState(
        'auto',
        groups: groups,
        selectedMap: selectedMap,
      );
      expect(state.proxyName, 'proxy-a');
      expect(state.group, true);
      expect(state.testUrl, isNull);
    });

    test('resolves multi-hop chain', () {
      final groups = [
        const Group(
          name: 'group-a',
          type: GroupType.Selector,
          testUrl: 'http://test-a.com',
          all: [
            Proxy(name: 'group-b', type: 'ss'),
            Proxy(name: 'proxy-x', type: 'ss'),
          ],
        ),
        const Group(
          name: 'group-b',
          type: GroupType.URLTest,
          testUrl: 'http://test-b.com',
          all: [Proxy(name: 'proxy-leaf', type: 'ss')],
        ),
      ];
      final selectedMap = {'group-a': 'group-b', 'group-b': 'proxy-leaf'};
      final state = computeRealSelectedProxyState(
        'group-a',
        groups: groups,
        selectedMap: selectedMap,
      );
      expect(state.proxyName, 'proxy-leaf');
      expect(state.group, true);
      expect(state.testUrl, 'http://test-b.com');
    });

    test('stops at group when selectedMap has no entry', () {
      final groups = [
        const Group(
          name: 'group-a',
          type: GroupType.Selector,
          all: [Proxy(name: 'proxy-a', type: 'ss')],
        ),
      ];
      final state = computeRealSelectedProxyState(
        'group-a',
        groups: groups,
        selectedMap: {},
      );
      expect(state.proxyName, 'group-a');
      expect(state.group, true);
    });

    test('URLTest group prefers realNow over selectedMap value', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          now: 'proxy-fast',
          all: [
            Proxy(name: 'proxy-fast', type: 'ss'),
            Proxy(name: 'proxy-slow', type: 'ss'),
          ],
        ),
      ];
      final state = computeRealSelectedProxyState(
        'auto',
        groups: groups,
        selectedMap: {'auto': 'proxy-slow'},
      );
      expect(state.proxyName, 'proxy-fast');
    });

    test('Selector group prefers selectedMap value over realNow', () {
      final groups = [
        const Group(
          name: 'selector',
          type: GroupType.Selector,
          now: 'proxy-a',
          all: [
            Proxy(name: 'proxy-a', type: 'ss'),
            Proxy(name: 'proxy-b', type: 'ss'),
          ],
        ),
      ];
      final state = computeRealSelectedProxyState(
        'selector',
        groups: groups,
        selectedMap: {'selector': 'proxy-b'},
      );
      expect(state.proxyName, 'proxy-b');
    });
  });

  group('computeProxyDelayState', () {
    test('returns delay from delayMap for resolved proxy', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          all: [Proxy(name: 'proxy-a', type: 'ss')],
        ),
      ];
      final delayMap = <String, Map<String, int?>>{
        'http://test.com': {'proxy-a': 120},
      };
      final state = computeProxyDelayState(
        proxyName: 'auto',
        testUrl: 'http://test.com',
        groups: groups,
        selectedMap: {'auto': 'proxy-a'},
        delayMap: delayMap,
      );
      expect(state.delay, 120);
      expect(state.group, true);
    });

    test('returns delay 0 when proxy not found in delayMap', () {
      final state = computeProxyDelayState(
        proxyName: 'proxy-x',
        testUrl: 'http://test.com',
        groups: [],
        selectedMap: {},
        delayMap: {},
      );
      expect(state.delay, 0);
    });

    test('uses group testUrl over default when available', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          testUrl: 'http://group-test.com',
          all: [Proxy(name: 'proxy-a', type: 'ss')],
        ),
      ];
      final delayMap = <String, Map<String, int?>>{
        'http://group-test.com': {'proxy-a': 50},
      };
      final state = computeProxyDelayState(
        proxyName: 'auto',
        testUrl: 'http://default.com',
        groups: groups,
        selectedMap: {'auto': 'proxy-a'},
        delayMap: delayMap,
      );
      expect(state.delay, 50);
    });

    test('falls back to default testUrl when group has no testUrl', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          all: [Proxy(name: 'proxy-a', type: 'ss')],
        ),
      ];
      final delayMap = <String, Map<String, int?>>{
        'http://default.com': {'proxy-a': 80},
      };
      final state = computeProxyDelayState(
        proxyName: 'auto',
        testUrl: 'http://default.com',
        groups: groups,
        selectedMap: {'auto': 'proxy-a'},
        delayMap: delayMap,
      );
      expect(state.delay, 80);
    });

    test('precomputes unique DelayState values before delay sorting', () {
      final groups = [
        const Group(
          name: 'auto',
          type: GroupType.URLTest,
          testUrl: 'http://group-test.com',
          all: [Proxy(name: 'proxy-a', type: 'ss')],
        ),
      ];
      final groupByName = {for (final group in groups) group.name: group};
      final states = computeProxyDelayStateMap(
        proxies: const [
          Proxy(name: 'auto', type: 'Selector'),
          Proxy(name: 'auto', type: 'Selector'),
          Proxy(name: 'proxy-b', type: 'ss'),
        ],
        testUrl: 'http://default.com',
        groupByName: groupByName,
        selectedMap: {'auto': 'proxy-a'},
        delayMap: {
          'http://group-test.com': {'proxy-a': 45},
          'http://default.com': {'proxy-b': 90},
        },
      );

      expect(states.keys, ['auto', 'proxy-b']);
      expect(states['auto']?.delay, 45);
      expect(states['auto']?.group, true);
      expect(states['proxy-b']?.delay, 90);
    });
  });

  group('computeSort', () {
    late List<Group> groups;
    late DelayMap delayMap;

    setUp(() {
      groups = [
        const Group(
          name: 'proxies',
          type: GroupType.Selector,
          all: [
            Proxy(name: 'proxy-c', type: 'ss'),
            Proxy(name: 'proxy-a', type: 'ss'),
            Proxy(name: 'proxy-b', type: 'ss'),
          ],
        ),
      ];
      delayMap = <String, Map<String, int?>>{
        'http://test.com': {'proxy-a': 100, 'proxy-b': 50, 'proxy-c': 0},
      };
    });

    test('identifies groups that must refresh after delay tests', () {
      expect(isDelaySortedGroupName('FREE-NODES'), true);
      expect(isDelaySortedGroupName('2026-06-19'), true);
      expect(isDelaySortedGroupName('日期 2026-06-19'), true);
      expect(isDelaySortedGroupName('2026-06-19T00:00:00Z'), true);
      expect(isDelaySortedGroupName('20260619'), true);
      expect(isDelaySortedGroupName('优选节点'), true);
      expect(isDelaySortedGroupName('宝藏积累'), true);
      expect(isDelaySortedGroupName('历史'), true);
      expect(isDelaySortedGroupName('Proxy'), false);
      expect(isDelaySortedGroupName('2026-6-19'), false);
    });

    test('ProxiesSortType.none preserves original order', () {
      final result = computeSort(
        groups: groups,
        sortType: ProxiesSortType.none,
        delayMap: delayMap,
        selectedMap: {},
        defaultTestUrl: 'http://test.com',
      );
      expect(result[0].all.map((p) => p.name).toList(), [
        'proxy-c',
        'proxy-a',
        'proxy-b',
      ]);
    });

    test('ProxiesSortType.name sorts alphabetically', () {
      final result = computeSort(
        groups: groups,
        sortType: ProxiesSortType.name,
        delayMap: delayMap,
        selectedMap: {},
        defaultTestUrl: 'http://test.com',
      );
      expect(result[0].all.map((p) => p.name).toList(), [
        'proxy-a',
        'proxy-b',
        'proxy-c',
      ]);
    });

    test('ProxiesSortType.delay sorts by delay value', () {
      final result = computeSort(
        groups: groups,
        sortType: ProxiesSortType.delay,
        delayMap: delayMap,
        selectedMap: {},
        defaultTestUrl: 'http://test.com',
      );
      final names = result[0].all.map((p) => p.name).toList();
      expect(names.indexOf('proxy-b'), lessThan(names.indexOf('proxy-a')));
    });

    test('FREE-NODES group always sorts by delay value', () {
      final result = computeSort(
        groups: [groups.first.copyWith(name: 'FREE-NODES')],
        sortType: ProxiesSortType.none,
        delayMap: delayMap,
        selectedMap: {},
        defaultTestUrl: 'http://test.com',
      );
      expect(result[0].all.map((p) => p.name).toList(), [
        'proxy-b',
        'proxy-a',
        'proxy-c',
      ]);
    });

    test('preserves group count in result', () {
      final multiGroups = [
        ...groups,
        const Group(
          name: 'other',
          type: GroupType.Selector,
          all: [Proxy(name: 'p1', type: 'ss')],
        ),
      ];
      final result = computeSort(
        groups: multiGroups,
        sortType: ProxiesSortType.none,
        delayMap: {},
        selectedMap: {},
        defaultTestUrl: '',
      );
      expect(result.length, 2);
    });
  });

  group('toGroupsTask', () {
    test('parses core group data with enum type names', () async {
      final result = await toGroupsTask(
        const ComputeGroupsState(
          proxiesData: ProxiesData(
            all: ['FREE-NODES'],
            proxies: {
              'FREE-NODES': {
                'name': 'FREE-NODES',
                'type': 'URLTest',
                'hidden': false,
                'all': ['proxy-fast', 'proxy-slow'],
              },
              'proxy-fast': {'name': 'proxy-fast', 'type': 'ss'},
              'proxy-slow': {'name': 'proxy-slow', 'type': 'ss'},
            },
          ),
          sortType: ProxiesSortType.none,
          delayMap: {
            'http://test.com': {'proxy-fast': 20, 'proxy-slow': 200},
          },
          selectedMap: {},
          defaultTestUrl: 'http://test.com',
        ),
      );

      expect(result, hasLength(1));
      expect(result.single.name, 'FREE-NODES');
      expect(result.single.type, GroupType.URLTest);
      expect(result.single.all.map((item) => item.name), [
        'proxy-fast',
        'proxy-slow',
      ]);
    });
  });

  group('Group.getCurrentSelectedName', () {
    test('URLTest group returns realNow when non-empty', () {
      const group = Group(
        name: 'auto',
        type: GroupType.URLTest,
        now: 'proxy-fast',
      );
      expect(group.getCurrentSelectedName('proxy-input'), 'proxy-fast');
    });

    test('URLTest group falls back to proxyName when now is null', () {
      const group = Group(name: 'auto', type: GroupType.URLTest);
      expect(group.getCurrentSelectedName('proxy-input'), 'proxy-input');
    });

    test('URLTest group returns empty when both now and proxyName empty', () {
      const group = Group(name: 'auto', type: GroupType.URLTest);
      expect(group.getCurrentSelectedName(''), '');
    });

    test('Selector group returns proxyName when non-empty', () {
      const group = Group(
        name: 'sel',
        type: GroupType.Selector,
        now: 'proxy-now',
      );
      expect(group.getCurrentSelectedName('proxy-selected'), 'proxy-selected');
    });

    test('Selector group falls back to realNow when proxyName empty', () {
      const group = Group(
        name: 'sel',
        type: GroupType.Selector,
        now: 'proxy-now',
      );
      expect(group.getCurrentSelectedName(''), 'proxy-now');
    });

    test('Selector group returns empty when both empty', () {
      const group = Group(name: 'sel', type: GroupType.Selector);
      expect(group.getCurrentSelectedName(''), '');
    });
  });
}

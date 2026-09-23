import 'package:fl_clash/common/compute.dart';
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

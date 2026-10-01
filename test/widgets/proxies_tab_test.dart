1 | import 'package:fl_clash/common/common.dart';
2 | import 'package:fl_clash/common/theme.dart';
3 | import 'package:fl_clash/enum/enum.dart';
4 | import 'package:fl_clash/l10n/l10n.dart';
5 | import 'package:fl_clash/models/models.dart';
6 | import 'package:fl_clash/providers/config.dart';
7 | import 'package:fl_clash/providers/database.dart';
8 | import 'package:fl_clash/providers/state.dart';
9 | import 'package:fl_clash/state.dart';
10 | import 'package:fl_clash/views/proxies/tab.dart';
11 | import 'package:flutter/material.dart';
12 | import 'package:flutter_localizations/flutter_localizations.dart';
13 | import 'package:flutter_riverpod/flutter_riverpod.dart';
14 | import 'package:flutter_test/flutter_test.dart';
15 | 
16 | void main() {
17 |   late ProviderContainer globalContainer;
18 |   late ProviderSubscription<Profile?> currentProfileSubscription;
19 | 
20 |   setUp(() {
21 |     final profile = Profile.normal().copyWith(currentGroupName: 'B');
22 |     globalContainer = ProviderContainer(
23 |       overrides: [
24 |         currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
25 |         profilesProvider.overrideWith(() => _TestProfiles([profile])),
26 |         currentGroupsStateProvider.overrideWithValue(
27 |           GroupsState(value: [_group('A'), _group('B'), _group('C')]),
28 |         ),
29 |       ],
30 |     );
31 |     globalState.container = globalContainer;
32 |     currentProfileSubscription = globalContainer.listen(
33 |       currentProfileProvider,
34 |       (_, _) {},
35 |     );
36 |   });
37 | 
38 |   tearDown(() {
39 |     currentProfileSubscription.close();
40 |     globalContainer.dispose();
41 |   });
42 | 
43 |   testWidgets('current group follows the rendered tab list', (tester) async {
44 |     final key = GlobalKey<ProxiesTabViewState>();
45 |     final renderedGroups = [_group('B'), _group('C')];
46 | 
47 |     final widgetContainer = ProviderContainer(
48 |       overrides: [
49 |         proxiesTabStateProvider.overrideWithValue(
50 |           ProxiesTabState(
51 |             groups: renderedGroups,
52 |             currentGroupName: 'B',
53 |             proxyCardType: ProxyCardType.expand,
54 |           ),
55 |         ),
56 |       ],
57 |     );
58 |     addTearDown(widgetContainer.dispose);
59 | 
60 |     await tester.pumpWidget(
61 |       UncontrolledProviderScope(
62 |         container: widgetContainer,
63 |         child: _TestApp(child: ProxiesTabView(key: key)),
64 |       ),
65 |     );
66 |     await tester.pump();
67 | 
68 |     expect(key.currentState?.currentGroup?.name, 'B');
69 | 
70 |     final tabBar = tester.widget<TabBar>(find.byType(TabBar));
71 |     tabBar.controller?.animateTo(1);
72 |     await tester.pumpAndSettle();
73 | 
74 |     expect(key.currentState?.currentGroup?.name, 'C');
75 |     expect(globalContainer.read(currentProfileProvider)?.currentGroupName, 'C');
76 |     await tester.pumpWidget(const SizedBox.shrink());
77 |     await tester.pump();
78 |   });
79 | }
80 | 
81 | Group _group(String name) {
82 |   return Group(type: GroupType.Selector, name: name);
83 | }
84 | 
85 | class _TestProfiles extends Profiles {
86 |   final List<Profile> initial;
87 | 
88 |   _TestProfiles(this.initial);
89 | 
90 |   @override
91 |   List<Profile> build() => initial;
92 | 
93 |   @override
94 |   void put(Profile profile) {
95 |     final next = List<Profile>.from(state);
96 |     final index = next.indexWhere((item) => item.id == profile.id);
97 |     if (index == -1) {
98 |       next.add(profile);
99 |     } else {
100 |       next[index] = profile;
101 |     }
102 |     state = next;
103 |   }
104 | }
105 | 
106 | class _TestApp extends StatelessWidget {
107 |   final Widget child;
108 | 
109 |   const _TestApp({required this.child});
110 | 
111 |   @override
112 |   Widget build(BuildContext context) {
113 |     return MaterialApp(
114 |       navigatorKey: globalState.navigatorKey,
115 |       localizationsDelegates: const [
116 |         AppLocalizations.delegate,
117 |         GlobalMaterialLocalizations.delegate,
118 |         GlobalCupertinoLocalizations.delegate,
119 |         GlobalWidgetsLocalizations.delegate,
120 |       ],
121 |       supportedLocales: AppLocalizations.delegate.supportedLocales,
122 |       builder: (context, child) {
123 |         globalState.measure = Measure.of(context, 1);
124 |         globalState.theme = CommonTheme.of(context, 1);
125 |         return child!;
126 |       },
127 |       home: Scaffold(body: child),
128 |     );
129 |   }
130 | }
1 | import 'package:fl_clash/common/common.dart';
2 | import 'package:fl_clash/common/theme.dart';
3 | import 'package:fl_clash/enum/enum.dart';
4 | import 'package:fl_clash/l10n/l10n.dart';
5 | import 'package:fl_clash/models/models.dart';
6 | import 'package:fl_clash/providers/providers.dart';
7 | import 'package:fl_clash/state.dart';
8 | import 'package:fl_clash/views/access.dart';
9 | import 'package:fl_clash/views/dashboard/dashboard.dart';
10 | import 'package:fl_clash/views/logs.dart';
11 | import 'package:fl_clash/widgets/widgets.dart';
12 | import 'package:flutter/material.dart';
13 | import 'package:flutter_localizations/flutter_localizations.dart';
14 | import 'package:flutter_riverpod/flutter_riverpod.dart';
15 | import 'package:flutter_test/flutter_test.dart';
16 | 
17 | void main() {
18 |   testWidgets('back layers are consumed from inner to outer', (tester) async {
19 |     var innerActive = true;
20 |     var outerActive = true;
21 |     var innerBackCount = 0;
22 |     var outerBackCount = 0;
23 |     var rootBackCount = 0;
24 | 
25 |     await tester.pumpWidget(
26 |       MaterialApp(
27 |         home: CommonPopScope(
28 |           onPop: (_) {
29 |             rootBackCount++;
30 |             return false;
31 |           },
32 |           child: StatefulBuilder(
33 |             builder: (context, setState) {
34 |               Widget child = const SizedBox();
35 |               if (innerActive) {
36 |                 child = BackLayerScope(
37 |                   onBack: () {
38 |                     innerBackCount++;
39 |                     setState(() {
40 |                       innerActive = false;
41 |                     });
42 |                   },
43 |                   child: child,
44 |                 );
45 |               }
46 |               if (outerActive) {
47 |                 child = BackLayerScope(
48 |                   onBack: () {
49 |                     outerBackCount++;
50 |                     setState(() {
51 |                       outerActive = false;
52 |                     });
53 |                   },
54 |                   child: child,
55 |                 );
56 |               }
57 |               return child;
58 |             },
59 |           ),
60 |         ),
61 |       ),
62 |     );
63 |     await tester.pumpAndSettle();
64 | 
65 |     await tester.binding.handlePopRoute();
66 |     await tester.pumpAndSettle();
67 |     expect((innerBackCount, outerBackCount, rootBackCount), (1, 0, 0));
68 | 
69 |     await tester.binding.handlePopRoute();
70 |     await tester.pumpAndSettle();
71 |     expect((innerBackCount, outerBackCount, rootBackCount), (1, 1, 0));
72 | 
73 |     await tester.binding.handlePopRoute();
74 |     await tester.pump();
75 |     expect((innerBackCount, outerBackCount, rootBackCount), (1, 1, 1));
76 |   });
77 | 
78 |   testWidgets(
79 |     'a pending inactive sync is cancelled when the page reactivates',
80 |     (tester) async {
81 |       final isActive = ValueNotifier(true);
82 |       addTearDown(isActive.dispose);
83 |       final pendingCallbacks = <void Function(Duration)>[];
84 |       var backCount = 0;
85 |       var rootBackCount = 0;
86 | 
87 |       await tester.pumpWidget(
88 |         MaterialApp(
89 |           home: CommonPopScope(
90 |             onPop: (_) {
91 |               rootBackCount++;
92 |               return false;
93 |             },
94 |             child: _PageActivityTestScope(
95 |               isActive: isActive,
96 |               child: BackLayerScope(
97 |                 onBack: () {
98 |                   backCount++;
99 |                 },
100 |                 schedulePostFrameCallback: pendingCallbacks.add,
101 |                 child: const SizedBox(),
102 |               ),
103 |             ),
104 |           ),
105 |         ),
106 |       );
107 |       await tester.pump();
108 | 
109 |       expect(pendingCallbacks, hasLength(1));
110 |       pendingCallbacks.removeAt(0)(Duration.zero);
111 |       await tester.pump();
112 | 
113 |       isActive.value = false;
114 |       await tester.pump();
115 |       isActive.value = true;
116 |       await tester.pump();
117 |       expect(pendingCallbacks, hasLength(2));
118 | 
119 |       for (final callback in pendingCallbacks.toList()) {
120 |         callback(Duration.zero);
121 |       }
122 |       pendingCallbacks.clear();
123 |       await tester.pump();
124 |       expect(backCount, 0);
125 | 
126 |       await tester.binding.handlePopRoute();
127 |       await tester.pump();
128 |       expect(backCount, 1);
129 |       expect(rootBackCount, 0);
130 | 
131 |       await tester.binding.handlePopRoute();
132 |       await tester.pump();
133 |       expect(backCount, 1);
134 |       expect(rootBackCount, 1);
135 |     },
136 |   );
137 | 
138 |   testWidgets('disposing a back layer does not invoke its callback', (
139 |     tester,
140 |   ) async {
141 |     final showLayer = ValueNotifier(true);
142 |     addTearDown(showLayer.dispose);
143 |     var backCount = 0;
144 | 
145 |     await tester.pumpWidget(
146 |       MaterialApp(
147 |         home: ValueListenableBuilder(
148 |           valueListenable: showLayer,
149 |           builder: (_, value, _) {
150 |             if (!value) {
151 |               return const SizedBox();
152 |             }
153 |             return BackLayerScope(
154 |               onBack: () {
155 |                 backCount++;
156 |               },
157 |               child: const SizedBox(),
158 |             );
159 |           },
160 |         ),
161 |       ),
162 |     );
163 |     await tester.pumpAndSettle();
164 | 
165 |     showLayer.value = false;
166 |     await tester.pumpAndSettle();
167 | 
168 |     expect(backCount, 0);
169 |   });
170 | 
171 |   testWidgets('system back exits search without reaching the root fallback', (
172 |     tester,
173 |   ) async {
174 |     final container = ProviderContainer();
175 |     addTearDown(container.dispose);
176 |     globalState.container = container;
177 |     var rootBackCount = 0;
178 | 
179 |     await tester.pumpWidget(
180 |       UncontrolledProviderScope(
181 |         container: container,
182 |         child: MaterialApp(
183 |           localizationsDelegates: const [
184 |             AppLocalizations.delegate,
185 |             GlobalMaterialLocalizations.delegate,
186 |             GlobalCupertinoLocalizations.delegate,
187 |             GlobalWidgetsLocalizations.delegate,
188 |           ],
189 |           supportedLocales: AppLocalizations.delegate.supportedLocales,
190 |           home: CommonPopScope(
191 |             onPop: (_) {
192 |               rootBackCount++;
193 |               return false;
194 |             },
195 |             child: CommonScaffold(
196 |               title: 'Logs',
197 |               searchState: AppBarSearchState(onSearch: (_) {}),
198 |               body: const SizedBox(),
199 |             ),
200 |           ),
201 |         ),
202 |       ),
203 |     );
204 | 
205 |     await tester.tap(find.byIcon(Icons.search));
206 |     await tester.pumpAndSettle();
207 |     expect(find.byType(TextField), findsOneWidget);
208 | 
209 |     await tester.binding.handlePopRoute();
210 |     await tester.pump();
211 | 
212 |     expect(find.byType(TextField), findsNothing);
213 |     expect(rootBackCount, 0);
214 |   });
215 | 
216 |   testWidgets('inactive page scope exits the kept search layer', (
217 |     tester,
218 |   ) async {
219 |     final container = ProviderContainer();
220 |     addTearDown(container.dispose);
221 |     globalState.container = container;
222 |     final isActive = ValueNotifier(true);
223 |     addTearDown(isActive.dispose);
224 | 
225 |     await tester.pumpWidget(
226 |       UncontrolledProviderScope(
227 |         container: container,
228 |         child: MaterialApp(
229 |           localizationsDelegates: const [
230 |             AppLocalizations.delegate,
231 |             GlobalMaterialLocalizations.delegate,
232 |             GlobalCupertinoLocalizations.delegate,
233 |             GlobalWidgetsLocalizations.delegate,
234 |           ],
235 |           supportedLocales: AppLocalizations.delegate.supportedLocales,
236 |           home: _PageActivityTestScope(
237 |             isActive: isActive,
238 |             child: const LogsView(),
239 |           ),
240 |         ),
241 |       ),
242 |     );
243 | 
244 |     await tester.tap(find.byIcon(Icons.search));
245 |     await tester.pumpAndSettle();
246 |     expect(find.byType(TextField), findsOneWidget);
247 | 
248 |     isActive.value = false;
249 |     await tester.pumpAndSettle();
250 | 
251 |     expect(find.byType(TextField), findsNothing);
252 |   });
253 | 
254 |   testWidgets('inactive page scope exits dashboard edit layer', (tester) async {
255 |     final container = ProviderContainer(
256 |       overrides: [
257 |         dashboardStateProvider.overrideWithValue(
258 |           const DashboardState(dashboardWidgets: []),
259 |         ),
260 |       ],
261 |     );
262 |     addTearDown(container.dispose);
263 |     globalState.container = container;
264 |     final isActive = ValueNotifier(true);
265 |     addTearDown(isActive.dispose);
266 | 
267 |     await tester.pumpWidget(
268 |       UncontrolledProviderScope(
269 |         container: container,
270 |         child: _DashboardTestApp(
271 |           child: _PageActivityTestScope(
272 |             isActive: isActive,
273 |             child: const DashboardView(),
274 |           ),
275 |         ),
276 |       ),
277 |     );
278 |     await tester.pump();
279 | 
280 |     await tester.tap(find.byKey(const ValueKey('edit-icon')));
281 |     await tester.pump(const Duration(milliseconds: 500));
282 |     expect(find.byKey(const ValueKey('save-icon')), findsOneWidget);
283 | 
284 |     isActive.value = false;
285 |     await tester.pump();
286 |     await tester.pump(const Duration(milliseconds: 500));
287 | 
288 |     expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
289 |   });
290 | 
291 |   testWidgets('inactive page scope exits access search layer', (tester) async {
292 |     final container = ProviderContainer();
293 |     addTearDown(container.dispose);
294 |     globalState.container = container;
295 |     final isActive = ValueNotifier(true);
296 |     addTearDown(isActive.dispose);
297 | 
298 |     await tester.pumpWidget(
299 |       UncontrolledProviderScope(
300 |         container: container,
301 |         child: _DashboardTestApp(
302 |           child: _PageActivityTestScope(
303 |             isActive: isActive,
304 |             child: const AccessView(),
305 |           ),
306 |         ),
307 |       ),
308 |     );
309 |     await tester.pump(const Duration(milliseconds: 301));
310 | 
311 |     await tester.tap(find.byIcon(Icons.more_vert));
312 |     await tester.pumpAndSettle();
313 |     await tester.tap(find.byIcon(Icons.search));
314 |     await tester.pumpAndSettle();
315 |     expect(find.byType(TextField), findsOneWidget);
316 | 
317 |     isActive.value = false;
318 |     await tester.pumpAndSettle();
319 | 
320 |     expect(find.byType(TextField), findsNothing);
321 |   });
322 | 
323 |   testWidgets('save and system back cannot re-enter dashboard edit mode', (
324 |     tester,
325 |   ) async {
326 |     final container = ProviderContainer(
327 |       overrides: [
328 |         dashboardStateProvider.overrideWithValue(
329 |           const DashboardState(dashboardWidgets: []),
330 |         ),
331 |       ],
332 |     );
333 |     addTearDown(container.dispose);
334 |     globalState.container = container;
335 | 
336 |     await tester.pumpWidget(
337 |       UncontrolledProviderScope(
338 |         container: container,
339 |         child: const _DashboardTestApp(),
340 |       ),
341 |     );
342 |     await tester.pump();
343 | 
344 |     await tester.tap(find.byKey(const ValueKey('edit-icon')));
345 |     await tester.pump(const Duration(milliseconds: 500));
346 |     expect(find.byKey(const ValueKey('save-icon')), findsOneWidget);
347 | 
348 |     tester.widget<IconButton>(find.byKey(const ValueKey(true))).onPressed!();
349 |     await tester.binding.handlePopRoute();
350 |     await tester.pump(const Duration(milliseconds: 500));
351 | 
352 |     expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
353 |   });
354 | 
355 |   testWidgets('system back preserves a pending dashboard deletion', (
356 |     tester,
357 |   ) async {
358 |     final container = ProviderContainer(
359 |       overrides: [
360 |         dashboardStateProvider.overrideWithValue(
361 |           const DashboardState(
362 |             dashboardWidgets: [
363 |               DashboardWidget.networkSpeed,
364 |               DashboardWidget.outboundModeV2,
365 |             ],
366 |           ),
367 |         ),
368 |       ],
369 |     );
370 |     addTearDown(container.dispose);
371 |     final appSettingSubscription = container.listen(
372 |       appSettingProvider,
373 |       (_, _) {},
374 |       fireImmediately: true,
375 |     );
376 |     addTearDown(appSettingSubscription.close);
377 |     globalState.container = container;
378 | 
379 |     await tester.pumpWidget(
380 |       UncontrolledProviderScope(
381 |         container: container,
382 |         child: const _DashboardTestApp(),
383 |       ),
384 |     );
385 |     await tester.pump();
386 | 
387 |     await tester.tap(find.byKey(const ValueKey('edit-icon')));
388 |     await tester.pump(const Duration(milliseconds: 500));
389 | 
390 |     final deleteButton = find.ancestor(
391 |       of: find.descendant(
392 |         of: find.byType(SuperGrid),
393 |         matching: find.byIcon(Icons.close),
394 |       ).first,
395 |       matching: find.byType(IconButton),
396 |     );
397 |     tester.widget<IconButton>(deleteButton).onPressed!();
398 |     await tester.pump();
399 |     await tester.pump(const Duration(milliseconds: 301));
400 |     await tester.pump();
401 |     expect(
402 |       tester.state<SuperGridState>(find.byType(SuperGrid)).snapshotChildren,
403 |       [
404 |         DashboardWidget.networkSpeed.widget,
405 |         DashboardWidget.outboundModeV2.widget,
406 |       ],
407 |     );
408 |     await tester.binding.handlePopRoute();
409 |     await tester.pump(const Duration(milliseconds: 500));
410 | 
411 |     expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
412 |     expect(container.read(appSettingProvider).dashboardWidgets, [
413 |       DashboardWidget.networkSpeed,
414 |       DashboardWidget.outboundModeV2,
415 |     ]);
416 |   });
417 | }
418 | 
419 | class _DashboardTestApp extends StatelessWidget {
420 |   final Widget child;
421 | 
422 |   const _DashboardTestApp({this.child = const DashboardView()});
423 | 
424 |   @override
425 |   Widget build(BuildContext context) {
426 |     return MaterialApp(
427 |       localizationsDelegates: const [
428 |         AppLocalizations.delegate,
429 |         GlobalMaterialLocalizations.delegate,
430 |         GlobalCupertinoLocalizations.delegate,
431 |         GlobalWidgetsLocalizations.delegate,
432 |       ],
433 |       supportedLocales: AppLocalizations.delegate.supportedLocales,
434 |       builder: (context, child) {
435 |         globalState.measure = Measure.of(context, 1);
436 |         globalState.theme = CommonTheme.of(context, 1);
437 |         return child!;
438 |       },
439 |       home: child,
440 |     );
441 |   }
442 | }
443 | 
444 | class _PageActivityTestScope extends StatelessWidget {
445 |   final ValueNotifier<bool> isActive;
446 |   final Widget child;
447 | 
448 |   const _PageActivityTestScope({required this.isActive, required this.child});
449 | 
450 |   @override
451 |   Widget build(BuildContext context) {
452 |     return ValueListenableBuilder(
453 |       valueListenable: isActive,
454 |       builder: (_, value, child) {
455 |         return PageActivityScope(isActive: value, child: child!);
456 |       },
457 |       child: child,
458 |     );
459 |   }
460 | }
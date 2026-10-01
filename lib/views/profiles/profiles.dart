1 | import 'dart:async';
2 | 
3 | import 'package:fl_clash/common/common.dart';
4 | import 'package:fl_clash/common/free_nodes.dart';
5 | import 'package:fl_clash/enum/enum.dart';
6 | import 'package:fl_clash/models/models.dart';
7 | import 'package:fl_clash/providers/providers.dart';
8 | import 'package:fl_clash/state.dart';
9 | import 'package:fl_clash/views/profiles/overwrite/overwrite.dart';
10 | import 'package:fl_clash/widgets/widgets.dart';
11 | import 'package:flutter/material.dart';
12 | import 'package:flutter/services.dart';
13 | import 'package:flutter_riverpod/flutter_riverpod.dart';
14 | 
15 | import 'add.dart';
16 | import 'edit.dart';
17 | import 'free_node_stability.dart';
18 | import 'preview.dart';
19 | 
20 | @visibleForTesting
21 | Widget buildProfilesTitleBarForTesting() => const _ProfilesTitleBar();
22 | 
23 | class ProfilesView extends StatefulWidget {
24 |   const ProfilesView({super.key});
25 | 
26 |   @override
27 |   State<ProfilesView> createState() => _ProfilesViewState();
28 | }
29 | 
30 | class _ProfilesViewState extends State<ProfilesView> {
31 |   Function? applyConfigDebounce;
32 |   bool _isUpdating = false;
33 | 
34 |   // final GlobalKey _targetKey = GlobalKey();
35 | 
36 |   @override
37 |   void initState() {
38 |     super.initState();
39 |     // WidgetsBinding.instance.addPostFrameCallback((_) {
40 |     //   final context = _targetKey.currentContext;
41 |     //   if (context == null) {
42 |     //     return;
43 |     //   }
44 |     //   Scrollable.ensureVisible(
45 |     //     context,
46 |     //     duration: commonDuration,
47 |     //     alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
48 |     //   );
49 |     // });
50 |   }
51 | 
52 |   void _handleShowAddExtendPage() {
53 |     showExtend(
54 |       globalState.navigatorKey.currentState!.context,
55 |       builder: (_) {
56 |         return AdaptiveSheetScaffold(
57 |           body: AddProfileView(
58 |             context: globalState.navigatorKey.currentState!.context,
59 |           ),
60 |           title: context.appLocalizations.addProfile,
61 |         );
62 |       },
63 |     );
64 |   }
65 | 
66 |   Future<void> _updateProfiles(List<Profile> profiles) async {
67 |     if (_isUpdating == true) {
68 |       return;
69 |     }
70 |     _isUpdating = true;
71 |     final List<UpdatingMessage> messages = [];
72 |     final updateProfiles = profiles.map<Future>((profile) async {
73 |       if (profile.type == ProfileType.file) return;
74 |       if (profile.isFreeNodesProfile) return;
75 |       try {
76 |         final action = globalState.container.read(
77 |           profilesActionProvider.notifier,
78 |         );
79 |         await action.updateProfile(profile, showLoading: true);
80 |       } catch (e) {
81 |         messages.add(
82 |           UpdatingMessage(label: profile.realLabel, message: e.toString()),
83 |         );
84 |       }
85 |     });
86 |     await Future.wait(updateProfiles);
87 |     if (messages.isNotEmpty) {
88 |       globalState.showAllUpdatingMessagesDialog(messages);
89 |     }
90 |     _isUpdating = false;
91 |   }
92 | 
93 |   List<Widget> _buildActions(List<Profile> profiles) {
94 |     return profiles.isNotEmpty
95 |         ? [
96 |             IconButton(
97 |               onPressed: () {
98 |                 _updateProfiles(profiles);
99 |               },
100 |               icon: const Icon(Icons.sync),
101 |             ),
102 |             IconButton(
103 |               onPressed: () {
104 |                 showSheet(
105 |                   context: context,
106 |                   builder: (_) {
107 |                     return ReorderableProfilesSheet(profiles: profiles);
108 |                   },
109 |                 );
110 |               },
111 |               icon: const Icon(Icons.sort),
112 |               iconSize: 26,
113 |             ),
114 |           ]
115 |         : [];
116 |   }
117 | 
118 |   Widget _buildFAB() {
119 |     return CommonFloatingActionButton(
120 |       onPressed: _handleShowAddExtendPage,
121 |       icon: const Icon(Icons.add),
122 |       label: context.appLocalizations.addProfile,
123 |     );
124 |   }
125 | 
126 |   @override
127 |   Widget build(BuildContext context) {
128 |     return Consumer(
129 |       builder: (_, ref, _) {
130 |         final appLocalizations = context.appLocalizations;
131 |         final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
132 |         final state = ref.watch(profilesStateProvider);
133 |         final spacing = 14.mAp;
134 |         return CommonScaffold(
135 |           isLoading: isLoading,
136 |           appBar: AppBar(
137 |             centerTitle: false,
138 |             titleSpacing: 24,
139 |             toolbarHeight: 68,
140 |             title: const _ProfilesTitleBar(),
141 |             actions: genActions(_buildActions(state.profiles)),
142 |           ),
143 |           floatingActionButton: _buildFAB(),
144 |           body: state.profiles.isEmpty
145 |               ? NullStatus(
146 |                   label: appLocalizations.nullProfileDesc,
147 |                   illustration: const ProfileEmptyIllustration(),
148 |                 )
149 |               : Align(
150 |                   alignment: Alignment.topCenter,
151 |                   child: SingleChildScrollView(
152 |                     key: profilesStoreKey,
153 |                     padding: const EdgeInsets.only(
154 |                       left: 16,
155 |                       right: 16,
156 |                       top: 16,
157 |                       bottom: 88,
158 |                     ),
159 |                     child: Column(
160 |                       crossAxisAlignment: CrossAxisAlignment.stretch,
161 |                       children: [
162 |                         Grid(
163 |                           mainAxisSpacing: spacing,
164 |                           crossAxisSpacing: spacing,
165 |                           crossAxisCount: utils.getProfilesColumns(
166 |                             MediaQuery.sizeOf(context).width - 32,
167 |                           ),
168 |                           children: [
169 |                             for (int i = 0; i < state.profiles.length; i++)
170 |                               GridItem(
171 |                                 child: ProfileItem(
172 |                                   profile: state.profiles[i],
173 |                                   groupValue: state.currentProfileId,
174 |                                   onChanged: (profileId) {
175 |                                     if (profileId == null) return;
176 |                                     unawaited(
177 |                                       ref
178 |                                           .read(profilesActionProvider.notifier)
179 |                                           .selectProfile(profileId),
180 |                                     );
181 |                                   },
182 |                                 ),
183 |                               ),
184 |                           ],
185 |                         ),
186 |                       ],
187 |                     ),
188 |                   ),
189 |                 ),
190 |         );
191 |       },
192 |     );
193 |   }
194 | }
195 | 
196 | class _ProfilesTitleBar extends StatelessWidget {
197 |   const _ProfilesTitleBar();
198 | 
199 |   Widget _buildLink(
200 |     BuildContext context,
201 |     String text,
202 |     String url, {
203 |     required Key key,
204 |   }) {
205 |     return InkWell(
206 |       key: key,
207 |       borderRadius: BorderRadius.circular(8),
208 |       onTap: () => globalState.openUrl(url),
209 |       child: Container(
210 |         width: double.infinity,
211 |         constraints: const BoxConstraints(minHeight: 40),
212 |         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
213 |         decoration: BoxDecoration(
214 |           borderRadius: BorderRadius.circular(8),
215 |           border: Border.all(color: context.colorScheme.outlineVariant),
216 |           color: context.colorScheme.surfaceContainerHighest.opacity80,
217 |         ),
218 |         child: Text(
219 |           text,
220 |           textAlign: TextAlign.center,
221 |           style: context.textTheme.labelMedium?.copyWith(
222 |             fontSize: 15,
223 |             fontWeight: FontWeight.w700,
224 |           ),
225 |           maxLines: 1,
226 |           overflow: TextOverflow.ellipsis,
227 |         ),
228 |       ),
229 |     );
230 |   }
231 | 
232 |   @override
233 |   Widget build(BuildContext context) {
234 |     return SizedBox(
235 |       width: double.infinity,
236 |       child: Column(
237 |         mainAxisSize: MainAxisSize.min,
238 |         crossAxisAlignment: CrossAxisAlignment.stretch,
239 |         children: [
240 |           Row(
241 |             crossAxisAlignment: CrossAxisAlignment.start,
242 |             children: [
243 |               ConstrainedBox(
244 |                 constraints: const BoxConstraints(maxWidth: 64),
245 |                 child: Text(
246 |                   '配置',
247 |                   key: const Key('profiles_title_label'),
248 |                   style: context.textTheme.titleLarge,
249 |                   maxLines: 1,
250 |                   overflow: TextOverflow.ellipsis,
251 |                 ),
252 |               ),
253 |               const SizedBox(width: 8),
254 |               Expanded(
255 |                 child: Row(
256 |                   children: [
257 |                     Expanded(
258 |                       child: _buildLink(
259 |                         context,
260 |                         '优质机场',
261 |                         'https://jichangtuijian.com/ssr-v2ray%E4%B8%93%E7%BA%BF%E6%9C%BA%E5%9C%BA%E6%8E%A8%E8%8D%90.html',
262 |                         key: const Key('profiles_title_quality_airport_link'),
263 |                       ),
264 |                     ),
265 |                     const SizedBox(width: 8),
266 |                     Expanded(
267 |                       child: _buildLink(
268 |                         context,
269 |                         '便宜机场',
270 |                         'https://maomeng.cc/2021/06/11/ji-chang-tui-jian-chang-qi-geng-xin/',
271 |                         key: const Key('profiles_title_budget_airport_link'),
272 |                       ),
273 |                     ),
274 |                   ],
275 |                 ),
276 |               ),
277 |             ],
278 |           ),
279 |           Padding(
280 |             padding: const EdgeInsets.only(left: 72, top: 12),
281 |             child: Text(
282 |               '不要轻易购买小于0.05元/G的机场',
283 |               maxLines: 1,
284 |               overflow: TextOverflow.ellipsis,
285 |               style: context.textTheme.labelSmall?.copyWith(
286 |                 color: context.colorScheme.error,
287 |                 fontSize: 13,
288 |                 height: 1.15,
289 |               ),
290 |             ),
291 |           ),
292 |         ],
293 |       ),
294 |     );
295 |   }
296 | }
297 | 
298 | class ProfileItem extends StatelessWidget {
299 |   final Profile profile;
300 |   final int? groupValue;
301 |   final void Function(int? value) onChanged;
302 |   final Future<void> Function(BuildContext context, String url)?
303 |   sourceUrlOpener;
304 | 
305 |   const ProfileItem({
306 |     super.key,
307 |     required this.profile,
308 |     required this.groupValue,
309 |     required this.onChanged,
310 |     this.sourceUrlOpener,
311 |   });
312 | 
313 |   Future<void> _handleDeleteProfile(BuildContext context) async {
314 |     final appLocalizations = context.appLocalizations;
315 |     final isFreeNodesProfile = profile.isFreeNodesProfile;
316 |     final res = await globalState.showMessage(
317 |       title: isFreeNodesProfile ? '重置免费节点' : appLocalizations.tip,
318 |       message: TextSpan(
319 |         text: isFreeNodesProfile
320 |             ? '重新获取免费节点并恢复为当前配置，入口不会被永久删除。'
321 |             : appLocalizations.deleteTip(appLocalizations.profile),
322 |       ),
323 |       confirmText: isFreeNodesProfile ? '重置' : null,
324 |     );
325 |     if (res != true) {
326 |       return;
327 |     }
328 |     final action = globalState.container.read(profilesActionProvider.notifier);
329 |     if (isFreeNodesProfile) {
330 |       await action.removeFreeNodesProfile();
331 |     } else {
332 |       await action.deleteProfile(profile.id);
333 |     }
334 |   }
335 | 
336 |   Future<void> _handlePreview(BuildContext context) async {
337 |     BaseNavigator.push<String>(context, PreviewProfileView(profile: profile));
338 |   }
339 | 
340 |   Future updateProfile() async {
341 |     if (profile.type == ProfileType.file) return;
342 |     await globalState.loadingRun(() async {
343 |       final action = globalState.container.read(
344 |         profilesActionProvider.notifier,
345 |       );
346 |       if (profile.isFreeNodesProfile) {
347 |         await action.updateFreeNodesProfile(showLoading: true);
348 |       } else {
349 |         await action.updateProfile(profile, showLoading: true);
350 |       }
351 |     }, tag: LoadingTag.profiles);
352 |   }
353 | 
354 |   void _handleShowEditExtendPage(BuildContext context) {
355 |     showExtend(
356 |       context,
357 |       builder: (_) {
358 |         return AdaptiveSheetScaffold(
359 |           body: EditProfileView(profile: profile, context: context),
360 |           title: context.appLocalizations.edit,
361 |         );
362 |       },
363 |     );
364 |   }
365 | 
366 |   List<Widget> _buildUrlProfileInfo(BuildContext context) {
367 |     final subscriptionInfo = profile.subscriptionInfo;
368 |     return [
369 |       const SizedBox(height: 8),
370 |       if (subscriptionInfo != null && !profile.isFreeNodesProfile)
371 |         SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
372 |       _buildProfileTimeAndSourceLink(
373 |         context,
374 |         style: context.textTheme.labelMedium?.toLighter,
375 |       ),
376 |     ];
377 |   }
378 | 
379 |   Widget _buildProfileTimeAndSourceLink(
380 |     BuildContext context, {
381 |     TextStyle? style,
382 |   }) {
383 |     final sourceUrl = profile.sourceUrl.trim();
384 |     final createdAt = Snowflake.dateTimeFromId(profile.id);
385 |     return Row(
386 |       mainAxisSize: MainAxisSize.max,
387 |       children: [
388 |         Flexible(
389 |           child: ProfileTimeText(
390 |             dateTime: createdAt ?? profile.lastUpdateDate,
391 |             prefix: '添加时间：',
392 |             style: style,
393 |           ),
394 |         ),
395 |         if (!profile.isFreeNodesProfile && sourceUrl.isNotEmpty) ...[
396 |           const SizedBox(width: 8),
397 |           Expanded(
398 |             child: _SourceUrlChip(
399 |               sourceUrl: sourceUrl,
400 |               onTap: () => _handleOpenSourceUrl(context),
401 |             ),
402 |           ),
403 |         ],
404 |       ],
405 |     );
406 |   }
407 | 
408 |   Widget _buildFreeNodesProgressView(
409 |     BuildContext context,
410 |     FreeNodesProgress? progress,
411 |   ) {
412 |     if (progress == null) return const SizedBox.shrink();
413 |     final colorScheme = context.colorScheme;
414 |     final textStyle = context.textTheme.labelMedium;
415 |     final color = progress.error
416 |         ? colorScheme.error
417 |         : progress.done
418 |         ? Colors.green
419 |         : colorScheme.primary;
420 |     final statusText = progress.done
421 |         ? '${progress.operation.takeFirstValid(['已完成'])} · ${progress.proxyCount} 个节点'
422 |         : progress.error
423 |         ? progress.operation
424 |         : '获取中 · ${progress.proxyCount} 个节点';
425 |     final timingText = _buildFreeNodesProgressTimingText(progress);
426 |     return Padding(
427 |       padding: const EdgeInsets.only(top: 8),
428 |       child: Column(
429 |         crossAxisAlignment: CrossAxisAlignment.start,
430 |         children: [
431 |           Row(
432 |             children: [
433 |               if (progress.done)
434 |                 Icon(Icons.check_circle_outline, size: 16, color: color)
435 |               else if (progress.error)
436 |                 Icon(Icons.error_outline, size: 16, color: color),
437 |               if (progress.done || progress.error) const SizedBox(width: 4),
438 |               Expanded(
439 |                 child: Text(
440 |                   statusText,
441 |                   style: textStyle?.copyWith(color: color),
442 |                   maxLines: 2,
443 |                   overflow: TextOverflow.ellipsis,
444 |                 ),
445 |               ),
446 |             ],
447 |           ),
448 |           if (timingText != null) ...[
449 |             const SizedBox(height: 4),
450 |             Text(
451 |               timingText,
452 |               style: context.textTheme.labelSmall?.copyWith(
453 |                 color: progress.done || progress.error
454 |                     ? colorScheme.onSurfaceVariant
455 |                     : colorScheme.primary,
456 |               ),
457 |               maxLines: 1,
458 |               overflow: TextOverflow.ellipsis,
459 |             ),
460 |           ],
461 |           if (!progress.done && !progress.error) ...[
462 |             const SizedBox(height: 6),
463 |             LinearProgressIndicator(value: progress.value),
464 |           ],
465 |         ],
466 |       ),
467 |     );
468 |   }
469 | 
470 |   String? _buildFreeNodesProgressTimingText(FreeNodesProgress progress) {
471 |     final startedAt = progress.startedAt;
472 |     if (startedAt == null) return null;
473 |     final current = DateTime.now();
474 |     final elapsed = current.difference(startedAt);
475 |     if (!progress.done && !progress.error) {
476 |       final completed = progress.completed;
477 |       final total = progress.total;
478 |       if (completed > 0 && total > completed && elapsed > Duration.zero) {
479 |         final remaining = Duration(
480 |           milliseconds:
481 |               (elapsed.inMilliseconds / completed * (total - completed))
482 |                   .round(),
483 |         );
484 |         return '预计剩余 ${_formatFreeNodesProgressDuration(remaining)} · 已用 ${_formatFreeNodesProgressDuration(elapsed)}';
485 |       }
486 |       return '已用 ${_formatFreeNodesProgressDuration(elapsed)}';
487 |     }
488 |     final finishedAt = progress.finishedAt ?? current;
489 |     final used = finishedAt.difference(startedAt);
490 |     if (progress.error) {
491 |       return '失败前用时 ${_formatFreeNodesProgressDuration(used)}';
492 |     }
493 |     return '本次用时 ${_formatFreeNodesProgressDuration(used)}';
494 |   }
495 | 
496 |   String _formatFreeNodesProgressDuration(Duration duration) {
497 |     final seconds = duration.inSeconds;
498 |     if (seconds <= 0) return '<1秒';
499 |     final minutes = seconds ~/ 60;
500 |     final remainSeconds = seconds % 60;
501 |     if (minutes <= 0) return '$remainSeconds秒';
502 |     if (minutes < 60) {
503 |       return remainSeconds == 0 ? '$minutes分' : '$minutes分$remainSeconds秒';
504 |     }
505 |     final hours = minutes ~/ 60;
506 |     final remainMinutes = minutes % 60;
507 |     return remainMinutes == 0 ? '$hours小时' : '$hours小时$remainMinutes分';
508 |   }
509 | 
510 |   List<Widget> _buildFileProfileInfo(BuildContext context) {
511 |     return [
512 |       const SizedBox(height: 8),
513 |       _buildProfileTimeAndSourceLink(
514 |         context,
515 |         style: context.textTheme.labelMedium?.toLight,
516 |       ),
517 |     ];
518 |   }
519 | 
520 |   Future<void> _handleCopyLink(BuildContext context) async {
521 |     await Clipboard.setData(ClipboardData(text: profile.url));
522 |     if (context.mounted) {
523 |       context.showNotifier(context.appLocalizations.copySuccess);
524 |     }
525 |   }
526 | 
527 |   Future<void> _handleOpenSourceUrl(BuildContext context) async {
528 |     final sourceUrl = profile.sourceUrl.trim();
529 |     if (sourceUrl.isEmpty) return;
530 |     if (!context.mounted) return;
531 |     final opener = sourceUrlOpener;
532 |     if (opener != null) {
533 |       await opener(context, sourceUrl);
534 |       return;
535 |     }
536 |     await globalState.openUrl(sourceUrl);
537 |   }
538 | 
539 |   Future<void> _handleExportFile(BuildContext context) async {
540 |     final appLocalizations = context.appLocalizations;
541 |     final res = await globalState.safeRun<bool>(() async {
542 |       final mFile = await profile.file;
543 |       final value = await picker.saveFile(
544 |         profile.realLabel,
545 |         mFile.readAsBytesSync(),
546 |       );
547 |       if (value == null) return false;
548 |       return true;
549 |     }, title: appLocalizations.tip);
550 |     if (res == true && context.mounted) {
551 |       context.showNotifier(appLocalizations.exportSuccess);
552 |     }
553 |   }
554 | 
555 |   void _handlePushGenProfilePage(BuildContext context, int id) {
556 |     BaseNavigator.push(context, OverwriteView(profileId: id));
557 |   }
558 | 
559 |   void _handleShowFreeNodeStability(BuildContext context) {
560 |     showSheet(
561 |       context: context,
562 |       builder: (_) => FreeNodeStabilitySheet(profile: profile),
563 |     );
564 |   }
565 | 
566 |   Future<void> _handlePreferFreeNodes(BuildContext context) async {
567 |     final res = await globalState.showMessage(
568 |       title: '优选节点',
569 |       message: const TextSpan(text: '整合优选节点？如已开启删除旧日期分类，会同时删除超时分类。'),
570 |       confirmText: '优选',
571 |     );
572 |     if (res != true) return;
573 |     await globalState.safeRun(() async {
574 |       final result = await globalState.container
575 |           .read(profilesActionProvider.notifier)
576 |           .preferFreeNodesProfile(profile);
577 |       globalState.showNotifier(
578 |         result.removedCount > 0
579 |             ? '已删除 ${result.removedCount} 个超时节点'
580 |             : '已整合优选节点',
581 |       );
582 |     }, title: '优选节点');
583 |   }
584 | 
585 |   List<PopupMenuItemData> _buildMenuItems(BuildContext context) {
586 |     final appLocalizations = context.appLocalizations;
587 |     return [
588 |       PopupMenuItemData(
589 |         icon: Icons.edit_outlined,
590 |         label: appLocalizations.edit,
591 |         onPressed: () {
592 |           _handleShowEditExtendPage(context);
593 |         },
594 |       ),
595 |       PopupMenuItemData(
596 |         icon: Icons.visibility_outlined,
597 |         label: appLocalizations.preview,
598 |         onPressed: () {
599 |           _handlePreview(context);
600 |         },
601 |       ),
602 |       if (profile.isFreeNodesProfile)
603 |         PopupMenuItemData(
604 |           icon: Icons.sync_alt_sharp,
605 |           label: '\u624b\u52a8\u66f4\u65b0',
606 |           onPressed: () {
607 |             updateProfile();
608 |           },
609 |         )
610 |       else if (profile.type == ProfileType.url)
611 |         PopupMenuItemData(
612 |           icon: Icons.sync_alt_sharp,
613 |           label: appLocalizations.sync,
614 |           onPressed: () {
615 |             updateProfile();
616 |           },
617 |         ),
618 |       if (profile.isFreeNodesProfile)
619 |         PopupMenuItemData(
620 |           icon: Icons.monitor_heart_outlined,
621 |           label: '\u7a33\u5b9a\u6027\u6d4b\u8bd5',
622 |           onPressed: () {
623 |             _handleShowFreeNodeStability(context);
624 |           },
625 |         ),
626 |       if (!profile.isFreeNodesProfile && profile.sourceUrl.trim().isNotEmpty)
627 |         PopupMenuItemData(
628 |           icon: Icons.travel_explore_outlined,
629 |           label: '源订阅网站',
630 |           onPressed: () {
631 |             _handleOpenSourceUrl(context);
632 |           },
633 |         ),
634 |       if (profile.isFreeNodesProfile)
635 |         PopupMenuItemData(
636 |           icon: Icons.auto_awesome_outlined,
637 |           label: '优选节点',
638 |           onPressed: () {
639 |             _handlePreferFreeNodes(context);
640 |           },
641 |         ),
642 |       PopupMenuItemData(
643 |         icon: Icons.emergency_outlined,
644 |         label: appLocalizations.more,
645 |         subItems: [
646 |           PopupMenuItemData(
647 |             icon: Icons.extension_outlined,
648 |             label: appLocalizations.override,
649 |             onPressed: () {
650 |               _handlePushGenProfilePage(context, profile.id);
651 |             },
652 |           ),
653 |           if (profile.type == ProfileType.url)
654 |             PopupMenuItemData(
655 |               icon: Icons.copy,
656 |               label: appLocalizations.copyLink,
657 |               onPressed: () {
658 |                 _handleCopyLink(context);
659 |               },
660 |             ),
661 |           PopupMenuItemData(
662 |             icon: Icons.file_copy_outlined,
663 |             label: appLocalizations.exportFile,
664 |             onPressed: () {
665 |               _handleExportFile(context);
666 |             },
667 |           ),
668 |         ],
669 |       ),
670 |       PopupMenuItemData(
671 |         danger: true,
672 |         icon: profile.isFreeNodesProfile
673 |             ? Icons.restore_outlined
674 |             : Icons.delete_outlined,
675 |         label: profile.isFreeNodesProfile ? '重置节点' : appLocalizations.delete,
676 |         onPressed: () {
677 |           _handleDeleteProfile(context);
678 |         },
679 |       ),
680 |     ];
681 |   }
682 | 
683 |   void _handleShowProfileMenu(BuildContext context) {
684 |     showSheet(
685 |       context: context,
686 |       builder: (_) => AdaptiveSheetScaffold(
687 |         title: profile.realLabel,
688 |         body: Align(
689 |           alignment: Alignment.topCenter,
690 |           child: Padding(
691 |             padding: const EdgeInsets.all(16),
692 |             child: CommonPopupMenu(items: _buildMenuItems(context)),
693 |           ),
694 |         ),
695 |       ),
696 |     );
697 |   }
698 | 
699 |   @override
700 |   Widget build(BuildContext context) {
701 |     final hasSourceUrl =
702 |         !profile.isFreeNodesProfile && profile.sourceUrl.trim().isNotEmpty;
703 |     final showProfileMenu = profile.isFreeNodesProfile || hasSourceUrl;
704 |     final card = CommonCard(
705 |       enterActionsOnRight: true,
706 |       isSelected: profile.id == groupValue,
707 |       onPressed: () {
708 |         onChanged(profile.id);
709 |       },
710 |       onLongPress: showProfileMenu
711 |           ? () {
712 |               _handleShowProfileMenu(context);
713 |             }
714 |           : null,
715 |       child: ListItem(
716 |         key: Key(profile.id.toString()),
717 |         horizontalTitleGap: 16,
718 |         padding: const EdgeInsets.symmetric(horizontal: 16),
719 |         trailing: SizedBox(
720 |           height: 40,
721 |           width: 40,
722 |           child: Consumer(
723 |             builder: (_, ref, _) {
724 |               final isUpdating = ref.watch(
725 |                 isUpdatingProvider(profile.updatingKey),
726 |               );
727 |               return FadeThroughBox(
728 |                 child: isUpdating
729 |                     ? const Padding(
730 |                         key: ValueKey('loading'),
731 |                         padding: EdgeInsets.all(8),
732 |                         child: CircularProgressIndicator(),
733 |                       )
734 |                     : CommonPopupBox(
735 |                         key: const ValueKey('menu'),
736 |                         popup: CommonPopupMenu(items: _buildMenuItems(context)),
737 |                         targetBuilder: (open) {
738 |                           return IconButton(
739 |                             onPressed: () {
740 |                               open();
741 |                             },
742 |                             icon: const Icon(Icons.more_vert),
743 |                           );
744 |                         },
745 |                       ),
746 |               );
747 |             },
748 |           ),
749 |         ),
750 |         title: Container(
751 |           padding: const EdgeInsets.symmetric(vertical: 4),
752 |           child: Column(
753 |             crossAxisAlignment: CrossAxisAlignment.start,
754 |             mainAxisAlignment: MainAxisAlignment.center,
755 |             children: [
756 |               Text(
757 |                 profile.realLabel,
758 |                 style: context.textTheme.titleMedium,
759 |                 maxLines: 1,
760 |                 overflow: TextOverflow.ellipsis,
761 |               ),
762 |               Column(
763 |                 mainAxisSize: MainAxisSize.min,
764 |                 crossAxisAlignment: CrossAxisAlignment.start,
765 |                 mainAxisAlignment: MainAxisAlignment.center,
766 |                 children: [
767 |                   ...switch (profile.type) {
768 |                     ProfileType.file => _buildFileProfileInfo(context),
769 |                     ProfileType.url => _buildUrlProfileInfo(context),
770 |                   },
771 |                   if (profile.isFreeNodesProfile)
772 |                     Consumer(
773 |                       builder: (_, ref, _) {
774 |                         final progress = ref.watch(
775 |                           freeNodesFetchProgressProvider,
776 |                         );
777 |                         final fallbackProgress =
778 |                             profile.subscriptionInfo != null
779 |                             ? FreeNodesProgress(
780 |                                 operation: '\u5df2\u5b8c\u6210',
781 |                                 proxyCount:
782 |                                     profile.subscriptionInfo?.total ?? 0,
783 |                                 done: true,
784 |                               )
785 |                             : null;
786 |                         return _buildFreeNodesProgressView(
787 |                           context,
788 |                           progress is FreeNodesProgress
789 |                               ? progress
790 |                               : fallbackProgress,
791 |                         );
792 |                       },
793 |                     ),
794 |                 ],
795 |               ),
796 |             ],
797 |           ),
798 |         ),
799 |         tileTitleAlignment: ListTileTitleAlignment.titleHeight,
800 |       ),
801 |     );
802 |     return GestureDetector(
803 |       behavior: HitTestBehavior.translucent,
804 |       onSecondaryTap: hasSourceUrl
805 |           ? () {
806 |               _handleOpenSourceUrl(context);
807 |             }
808 |           : profile.isFreeNodesProfile
809 |           ? () {
810 |               _handleShowProfileMenu(context);
811 |             }
812 |           : null,
813 |       child: card,
814 |     );
815 |   }
816 | }
817 | 
818 | class _SourceUrlChip extends StatelessWidget {
819 |   final String sourceUrl;
820 |   final VoidCallback onTap;
821 | 
822 |   const _SourceUrlChip({required this.sourceUrl, required this.onTap});
823 | 
824 |   @override
825 |   Widget build(BuildContext context) {
826 |     final colorScheme = context.colorScheme;
827 |     return Semantics(
828 |       button: true,
829 |       label: '打开原订阅网站 $sourceUrl',
830 |       child: Tooltip(
831 |         message: sourceUrl,
832 |         child: InkWell(
833 |           key: const Key('profile_source_url_link'),
834 |           borderRadius: BorderRadius.circular(8),
835 |           onTap: onTap,
836 |           child: Container(
837 |             constraints: const BoxConstraints(minHeight: 24),
838 |             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
839 |             decoration: BoxDecoration(
840 |               color: colorScheme.primaryContainer.opacity50,
841 |               borderRadius: BorderRadius.circular(8),
842 |               border: Border.all(color: colorScheme.primary.opacity60),
843 |             ),
844 |             child: Text(
845 |               sourceUrl,
846 |               style: context.textTheme.labelMedium?.copyWith(
847 |                 color: colorScheme.primary,
848 |                 fontWeight: FontWeight.w700,
849 |               ),
850 |               maxLines: 1,
851 |               overflow: TextOverflow.ellipsis,
852 |             ),
853 |           ),
854 |         ),
855 |       ),
856 |     );
857 |   }
858 | }
859 | 
860 | class ProfileTimeText extends StatelessWidget {
861 |   final DateTime? dateTime;
862 |   final String prefix;
863 |   final TextStyle? style;
864 | 
865 |   const ProfileTimeText({
866 |     super.key,
867 |     required this.dateTime,
868 |     this.prefix = '',
869 |     this.style,
870 |   });
871 | 
872 |   @override
873 |   Widget build(BuildContext context) {
874 |     if (dateTime == null) {
875 |       return Text('$prefix--', style: style);
876 |     }
877 |     return TickBuilder(
878 |       duration: const Duration(minutes: 1),
879 |       builder: (context, _) {
880 |         return Text(
881 |           '$prefix${dateTime!.getLastUpdateTimeDesc(context)}',
882 |           style: style,
883 |           maxLines: 1,
884 |           overflow: TextOverflow.ellipsis,
885 |         );
886 |       },
887 |     );
888 |   }
889 | }
890 | 
891 | class ReorderableProfilesSheet extends StatefulWidget {
892 |   final List<Profile> profiles;
893 | 
894 |   const ReorderableProfilesSheet({super.key, required this.profiles});
895 | 
896 |   @override
897 |   State<ReorderableProfilesSheet> createState() =>
898 |       _ReorderableProfilesSheetState();
899 | }
900 | 
901 | class _ReorderableProfilesSheetState extends State<ReorderableProfilesSheet> {
902 |   late List<Profile> profiles;
903 | 
904 |   @override
905 |   void initState() {
906 |     super.initState();
907 |     profiles = List.from(widget.profiles);
908 |   }
909 | 
910 |   Widget _buildItem(int index) {
911 |     final position = ItemPosition.get(index, profiles.length);
912 |     final profile = profiles[index];
913 |     return ItemPositionProvider(
914 |       key: Key(profile.id.toString()),
915 |       position: position,
916 |       child: DecorationListItem(
917 |         trailing: ReorderableDelayedDragStartListener(
918 |           index: index,
919 |           child: const Icon(Icons.drag_handle),
920 |         ),
921 |         title: Text(profile.realLabel),
922 |       ),
923 |     );
924 |   }
925 | 
926 |   void _handleSave() {
927 |     Navigator.of(context).pop();
928 |     globalState.container.read(profilesProvider.notifier).reorder(profiles);
929 |   }
930 | 
931 |   @override
932 |   Widget build(BuildContext context) {
933 |     final appLocalizations = context.appLocalizations;
934 |     return AdaptiveSheetScaffold(
935 |       sheetTransparentToolBar: true,
936 |       actions: [IconButtonData(icon: Icons.check, onPressed: _handleSave)],
937 |       body: Padding(
938 |         padding: const EdgeInsets.only(bottom: 32),
939 |         child: ReorderableListView.builder(
940 |           buildDefaultDragHandles: false,
941 |           padding: const EdgeInsets.symmetric(
942 |             horizontal: 16,
943 |           ).copyWith(top: context.sheetTopPadding),
944 |           proxyDecorator: (child, index, animation) {
945 |             return commonProxyDecorator(_buildItem(index), index, animation);
946 |           },
947 |           onReorderItem: (oldIndex, newIndex) {
948 |             setState(() {
949 |               profiles = profiles.copyAndReorder(oldIndex, newIndex);
950 |             });
951 |           },
952 |           itemBuilder: (_, index) {
953 |             return _buildItem(index);
954 |           },
955 |           itemCount: profiles.length,
956 |         ),
957 |       ),
958 |       title: appLocalizations.profilesSort,
959 |     );
960 |   }
961 | }
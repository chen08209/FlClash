import 'dart:ui' show ImageFilter;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/widgets/start_button.dart';
import 'package:fl_clash/widgets/miuix_navigation_bar.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OnSelected = void Function(int index);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasViewSize = ref.watch(
      viewSizeProvider.select((size) => !size.isEmpty),
    );
    if (!hasViewSize) {
      return const SizedBox.shrink();
    }
    return HomeBackScopeContainer(
      child: AppSidebarContainer(
        child: _HomeShell(
          child: Consumer(
            builder: (_, ref, _) {
              final navigationItems = ref
                  .watch(currentNavigationItemsStateProvider)
                  .value;
              final isMobile = ref.watch(isMobileViewProvider);
              final floating = ref.watch(
                appSettingProvider.select(
                  (state) => state.floatingNavigationBar,
                ),
              );
              return _HomePageView(
                navigationItems: navigationItems,
                pageBuilder: (_, index) {
                  final navigationItem = navigationItems[index];
                  return _NavigationPage(
                    key: ValueKey(navigationItem.label),
                    item: navigationItem,
                    isMobile: isMobile,
                    docked: isMobile && floating,
                    view: navigationItem.builder(context),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.child});

  final Widget child;

  void _handleToPage(PageLabel pageLabel, WidgetRef ref) {
    ref.read(currentPageLabelProvider.notifier).toPage(pageLabel);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(navigationStateProvider);
    final isMobile = state.viewMode == ViewMode.mobile;
    final navigationItems = state.navigationItems;
    final floating = ref.watch(
      appSettingProvider.select((state) => state.floatingNavigationBar),
    );
    final hasProfile = ref.watch(
      profilesProvider.select((profiles) => profiles.isNotEmpty),
    );
    final isDashboard = ref.watch(
      currentPageLabelProvider.select((label) => label == PageLabel.dashboard),
    );
    final barBlur = context.interfaceStyle.barBlur;
    final dockedBar = _DockedBar(
      navigationItems: navigationItems,
      selectedIndex: state.currentIndex,
      onSelected: (index) {
        _handleToPage(navigationItems[index].label, ref);
      },
    );
    return Material(
      color: context.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FocusTraversalGroup(
                    policy: PageTraversalPolicy(),
                    child: BottomInsetScope(
                      inset: !isMobile
                          ? 0
                          : floating
                          ? NavigationDock.insetOf(context)
                          : barBlur
                          ? _DockedBar.heightOf(context)
                          : 0,
                      child: _BodyPadding(isMobile: isMobile, child: child),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: AnimatedVisibility.bottomNavigation(
                    visible: isMobile && floating,
                    fade: !context.interfaceStyle.liquidGlass,
                    child: _NavigationPadding(
                      child: NavigationDock(
                        destinations: [
                          for (final item in navigationItems)
                            NavigationDockDestination(
                              glyph: item.glyph,
                              label: item.label.label,
                            ),
                        ],
                        selectedIndex: state.currentIndex,
                        onSelected: (index) {
                          _handleToPage(navigationItems[index].label, ref);
                        },
                        trailing: hasProfile && isDashboard
                            ? const StartButton()
                            : null,
                      ),
                    ),
                  ),
                ),
                if (barBlur)
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: AnimatedVisibility.bottomNavigation(
                      visible: isMobile && !floating,
                      child: _NavigationPadding(child: dockedBar),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedVisibility.bottomNavigation(
            visible: isMobile && !floating && !barBlur,
            child: _NavigationPadding(child: dockedBar),
          ),
        ],
      ),
    );
  }
}

/// The bar that holds the foot of a phone's window when the dock does not
/// float; with bar blur it lies over the page, which scrolls on under it.
class _DockedBar extends StatelessWidget {
  const _DockedBar({
    required this.navigationItems,
    required this.selectedIndex,
    required this.onSelected,
  });

  // miuix's 25dp texture blur, whose sigma is 0.45 of its radius.
  static const double _blurSigma = 0.45 * 25;
  static const double _blurTintAlpha = 0.87;
  static const double _materialHeight = 80;

  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static double heightOf(BuildContext context) {
    if (context.interfaceStyle.isMiuix) {
      return MiuixNavigationBar.heightOf(context);
    }
    return (NavigationBarTheme.of(context).height ?? _materialHeight) +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.interfaceStyle;
    final colorScheme = context.colorScheme;
    final background = style.barBlur ? Colors.transparent : null;
    final bar = style.isMiuix
        ? MiuixNavigationBar(
            destinations: [
              for (final item in navigationItems)
                NavigationDockDestination(
                  glyph: item.glyph,
                  label: item.label.label,
                ),
            ],
            selectedIndex: selectedIndex,
            onSelected: onSelected,
            color: background,
          )
        : NavigationBar(
            backgroundColor: background,
            destinations: [
              for (final (index, item) in navigationItems.indexed)
                NavigationDestination(
                  icon: AnimatedGlyph(
                    glyph: item.glyph,
                    filled: index == selectedIndex,
                  ),
                  label: item.label.label,
                ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
          );
    if (!style.barBlur) {
      return bar;
    }
    final tint = style.isMiuix
        ? colorScheme.surface
        : colorScheme.surfaceContainer;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _blurSigma,
          sigmaY: _blurSigma,
          tileMode: TileMode.clamp,
        ),
        child: ColoredBox(
          color: tint.withValues(alpha: _blurTintAlpha),
          child: bar,
        ),
      ),
    );
  }
}

class _BodyPadding extends StatelessWidget {
  const _BodyPadding({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: false,
      removeBottom: isMobile,
      removeLeft: isMobile,
      removeRight: isMobile,
      context: context,
      child: child,
    );
  }
}

class _NavigationPadding extends StatelessWidget {
  const _NavigationPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: false,
      removeLeft: true,
      removeRight: true,
      context: context,
      child: child,
    );
  }
}

class _NavigationPage extends StatelessWidget {
  const _NavigationPage({
    super.key,
    required this.item,
    required this.isMobile,
    required this.docked,
    required this.view,
  });

  final NavigationItem item;
  final bool isMobile;
  final bool docked;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    final scopedView = PageFocusScope(
      child: DockedPageScope(docked: docked, child: view),
    );
    final keptView = KeepScope(
      key: ValueKey(item.label),
      keep: item.keep,
      child: isMobile
          ? scopedView
          : Navigator(
              key: ValueKey('${item.label.name}_navigator'),
              pages: [MaterialPage(child: scopedView)],
              onDidRemovePage: (_) {},
            ),
    );
    return Consumer(
      builder: (_, ref, child) {
        final isActive = ref.watch(
          currentPageLabelProvider.select((label) => label == item.label),
        );
        // A kept-alive page off screen still ticks its animations, and
        // each tick asks for a frame.
        return PageActivityScope(
          isActive: isActive,
          child: TickerMode(
            enabled: isActive,
            child: ExcludeFocus(
              excluding: !isActive,
              child: KeyboardInsetHold(child: child!),
            ),
          ),
        );
      },
      child: keptView,
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
  });

  @override
  ConsumerState createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<_HomePageView> {
  late PageController _pageController;

  List<int>? _order;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    ref.listenManual(currentPageLabelProvider, (prev, next) {
      if (prev != next) {
        _toPage(next);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationItems.length != widget.navigationItems.length) {
      _order = null;
      _updatePageController();
    }
  }

  int get _pageIndex {
    final pageLabel = ref.read(currentPageLabelProvider);
    return widget.navigationItems.indexWhere((item) => item.label == pageLabel);
  }

  Future<void> _toPage(
    PageLabel pageLabel, [
    bool ignoreAnimateTo = false,
  ]) async {
    if (!mounted) {
      return;
    }
    final index = widget.navigationItems.indexWhere(
      (item) => item.label == pageLabel,
    );
    if (index == -1) {
      return;
    }
    final tabAnimation = ref.read(appSettingProvider).tabAnimation;
    final isMobile = ref.read(isMobileViewProvider);
    final slide = ++_slide;
    final page = _pageController.hasClients
        ? _pageController.page?.round() ?? index
        : index;
    final current = _order?[page] ?? page;
    if (_order != null) {
      setState(() => _order = null);
      _pageController.jumpToPage(current);
    }
    if (!isMobile || ignoreAnimateTo) {
      _pageController.jumpToPage(index);
      return;
    }
    // As TabBarView does, so no page between is built and painted on the way.
    if ((index - current).abs() > 1) {
      final adjacent = index > current ? index - 1 : index + 1;
      setState(() {
        _order = List.generate(widget.navigationItems.length, (item) => item)
          ..[adjacent] = current
          ..[current] = adjacent;
      });
      _pageController.jumpToPage(adjacent);
    }
    final fade = tabAnimation == TabAnimation.fade;
    await _pageController.animateToPage(
      index,
      duration: fade ? fadeTabDuration : kTabScrollDuration,
      curve: fade ? fadeTabCurve : Curves.easeOut,
    );
    if (mounted && slide == _slide && _order != null) {
      setState(() => _order = null);
    }
  }

  void _updatePageController() {
    final pageLabel = ref.read(currentPageLabelProvider);
    _toPage(pageLabel, true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ref.watch(
      currentNavigationItemsStateProvider.select((state) => state.value.length),
    );
    final fade = ref.watch(
      appSettingProvider.select(
        (state) => state.tabAnimation == TabAnimation.fade,
      ),
    );
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<PageLabel>) {
          return null;
        }
        final index = widget.navigationItems.indexWhere(
          (item) => item.label == key.value,
        );
        if (index == -1) {
          return null;
        }
        return _order?.indexOf(index) ?? index;
      },
      itemBuilder: (context, index) {
        final page = widget.pageBuilder(context, _order?[index] ?? index);
        return _FadeTabPage(
          key: page.key,
          controller: _pageController,
          position: index,
          enabled: fade,
          child: page,
        );
      },
    );
  }
}

/// Cancels the page view's slide so a tab switch cross-fades in place, and
/// wraps every page even when off so switching the setting keeps their state.
class _FadeTabPage extends StatelessWidget {
  const _FadeTabPage({
    super.key,
    required this.controller,
    required this.position,
    required this.enabled,
    required this.child,
  });

  final PageController controller;
  final int position;
  final bool enabled;
  final Widget child;

  double get _delta {
    if (!controller.hasClients || !controller.position.hasContentDimensions) {
      return 0;
    }
    final page = controller.page ?? position.toDouble();
    return (position - page).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final delta = enabled ? _delta : 0.0;
        return FractionalTranslation(
          translation: Offset(-delta, 0),
          child: Opacity(opacity: 1 - delta.abs(), child: child),
        );
      },
      child: child,
    );
  }
}

// Below Android 13 back still reaches Flutter, which finishes a root activity.
const _systemBackSdk = 33;

class HomeBackScopeContainer extends ConsumerWidget {
  final Widget child;

  const HomeBackScopeContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context, ref) {
    final systemBack =
        context.interfaceStyle.predictiveBack &&
        !system.isTV &&
        ref.watch(versionProvider) >= _systemBackSdk &&
        ref.watch(isMobileViewProvider) &&
        ref.watch(appSettingProvider.select((state) => state.minimizeOnExit));
    return CommonPopScope(
      onPop: systemBack
          ? null
          : (context) async {
              final pageLabel = ref.read(currentPageLabelProvider);
              final realContext =
                  GlobalObjectKey(pageLabel).currentContext ?? context;
              final canPop = Navigator.canPop(realContext);
              if (canPop) {
                Navigator.of(realContext).pop();
              } else if (system.isTV && pageLabel != PageLabel.dashboard) {
                ref
                    .read(currentPageLabelProvider.notifier)
                    .toPage(PageLabel.dashboard);
              } else {
                await ref.read(systemActionProvider.notifier).handleClose();
              }
              return false;
            },
      child: child,
    );
  }
}

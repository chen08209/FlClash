import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

typedef OnSelected = void Function(int index);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScope(
      child: Consumer(
        builder: (_, ref, child) {
          final state = ref.watch(homeStateProvider);
          final viewMode = state.viewMode;
          final navigationItems = state.navigationItems;
          final pageLabel = state.pageLabel;
          final index = navigationItems.lastIndexWhere(
            (element) => element.label == pageLabel,
          );
          final currentIndex = index == -1 ? 0 : index;
          final navigationBar = CommonNavigationBar(
            viewMode: viewMode,
            navigationItems: navigationItems,
            currentIndex: currentIndex,
          );
          final bottomNavigationBar =
              viewMode == ViewMode.mobile ? navigationBar : null;
          final sideNavigationBar =
              viewMode != ViewMode.mobile ? navigationBar : null;
          return CommonScaffold(
            key: globalState.homeScaffoldKey,
            title: Intl.message(
              pageLabel.name,
            ),
            sideNavigationBar: sideNavigationBar,
            body: child!,
            bottomNavigationBar: bottomNavigationBar,
          );
        },
        child: _HomePageView(),
      ),
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  const _HomePageView();

  @override
  ConsumerState createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<_HomePageView> {
  _updatePageController(List<NavigationItem> navigationItems) {
    final pageLabel = globalState.appState.pageLabel;
    final index = navigationItems.lastIndexWhere(
      (element) => element.label == pageLabel,
    );
    final pageIndex = index == -1 ? 0 : index;
    if (globalState.pageController != null) {
      Future.delayed(Duration(milliseconds: 200), () {
        globalState.appController.toPage(
          pageIndex,
          hasAnimate: true,
        );
      });
    } else {
      globalState.pageController = PageController(
        initialPage: pageIndex,
        keepPage: true,
      );
    }
  }

  // _handlePageChanged(PageLabel next) {
  //   debouncer.call(DebounceTag.pageChange, () {
  //     if (_prevPageLabel == next) {
  //       return;
  //     }
  //     if (_prevPageLabel != null) {
  //       final prevTabPageKey = GlobalObjectKey(_prevPageLabel!);
  //       if (prevTabPageKey.currentState is PageMixin) {
  //         (prevTabPageKey.currentState as PageMixin).onPageHidden();
  //       }
  //     }
  //     final nextTabPageKey = GlobalObjectKey(next);
  //     if (nextTabPageKey.currentState is PageMixin) {
  //       (nextTabPageKey.currentState as PageMixin).onPageShow();
  //     }
  //     _prevPageLabel = next;
  //   }, duration: commonDuration);
  // }

  @override
  Widget build(BuildContext context) {
    final navigationItems = ref.watch(currentNavigationsStateProvider).value;
    _updatePageController(navigationItems);
    return PageView.builder(
      controller: globalState.pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: navigationItems.length,
      // onPageChanged: (index) {
      //   _handlePageChanged(navigationItems[index].label);
      // },
      itemBuilder: (_, index) {
        final navigationItem = navigationItems[index];
        return KeepScope(
          keep: navigationItem.keep,
          key: Key(navigationItem.label.name),
          child: navigationItem.fragment,
        );
      },
    );
  }
}

class CommonNavigationBar extends ConsumerWidget {
  final ViewMode viewMode;
  final List<NavigationItem> navigationItems;
  final int currentIndex;

  const CommonNavigationBar({
    super.key,
    required this.viewMode,
    required this.navigationItems,
    required this.currentIndex,
  });

  _updateSafeMessageOffset(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (viewMode == ViewMode.mobile) {
        globalState.safeMessageOffsetNotifier.value = Offset(
          0,
          -(size?.height ?? 0),
        );
      } else {
        globalState.safeMessageOffsetNotifier.value = Offset(
          size?.width ?? 0,
          0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, ref) {
    _updateSafeMessageOffset(context);
    if (viewMode == ViewMode.mobile) {
      return NavigationBarTheme(
        data: _NavigationBarDefaultsM3(context),
        child: NavigationBar(
          destinations: navigationItems
              .map(
                (e) => NavigationDestination(
                  icon: e.icon,
                  label: Intl.message(e.label.name),
                ),
              )
              .toList(),
          onDestinationSelected: globalState.appController.toPage,
          selectedIndex: currentIndex,
        ),
      );
    }
    final showLabel = ref.watch(appSettingProvider).showLabel;
    return Material(
      color: context.colorScheme.surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: NavigationRail(
                  backgroundColor: context.colorScheme.surfaceContainer,
                  selectedIconTheme: IconThemeData(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  selectedLabelTextStyle:
                      context.textTheme.labelLarge!.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  unselectedLabelTextStyle:
                      context.textTheme.labelLarge!.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  destinations: navigationItems
                      .map(
                        (e) => NavigationRailDestination(
                          icon: e.icon,
                          label: Text(
                            Intl.message(e.label.name),
                          ),
                        ),
                      )
                      .toList(),
                  onDestinationSelected: globalState.appController.toPage,
                  extended: false,
                  selectedIndex: currentIndex,
                  labelType: showLabel
                      ? NavigationRailLabelType.all
                      : NavigationRailLabelType.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          IconButton(
            onPressed: () {
              ref.read(appSettingProvider.notifier).updateState(
                    (state) => state.copyWith(
                      showLabel: !state.showLabel,
                    ),
                  );
            },
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

class _NavigationBarDefaultsM3 extends NavigationBarThemeData {
  _NavigationBarDefaultsM3(this.context)
      : super(
          height: 80.0,
          elevation: 3.0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainer;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withOpacity(0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelMedium!;
      return style.apply(
          overflow: TextOverflow.ellipsis,
          color: states.contains(WidgetState.disabled)
              ? _colors.onSurfaceVariant.withOpacity(0.38)
              : states.contains(WidgetState.selected)
                  ? _colors.onSurface
                  : _colors.onSurfaceVariant);
    });
  }
}

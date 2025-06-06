import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/widgets/transparent_macos_sidebar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(layoutChangeProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (prev != next) {
          globalState.computeHeightMapCache = {};
        }
      });
    });
    ref.listenManual(
      checkIpProvider,
      (prev, next) {
        if (prev != next && next.b) {
          detectionState.startCheck();
        }
      },
      fireImmediately: true,
    );
    ref.listenManual(configStateProvider, (prev, next) {
      if (prev != next) {
        globalState.appController.savePreferencesDebounce();
      }
    });
    if (window == null) {
      return;
    }
    ref.listenManual(
      autoSetSystemDnsStateProvider,
      (prev, next) async {
        if (prev == next) {
          return;
        }
        if (next.a == true && next.b == true) {
          macOS?.updateDns(false);
        } else {
          macOS?.updateDns(true);
        }
      },
    );
    ref.listenManual(
      currentBrightnessProvider,
      (prev, next) {
        if (prev == next) {
          return;
        }
        window?.updateMacOSBrightness(next);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      globalState.appController.savePreferences();
    } else {
      render?.resume();
    }
    if (state == AppLifecycleState.inactive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        detectionState.tryStartCheck();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    globalState.appController.updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (_) {
        render?.resume();
      },
      child: widget.child,
    );
  }
}

class AppEnvManager extends StatelessWidget {
  final Widget child;

  const AppEnvManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      if (globalState.isPre) {
        return Banner(
          message: 'DEBUG',
          location: BannerLocation.topEnd,
          child: child,
        );
      }
    }
    if (globalState.isPre) {
      return Banner(
        message: 'PRE',
        location: BannerLocation.topEnd,
        child: child,
      );
    }
    return child;
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({
    super.key,
    required this.child,
  });

  Widget _buildLoading() {
    return Consumer(
      builder: (_, ref, __) {
        final loading = ref.watch(loadingProvider);
        final isMobileView = ref.watch(isMobileViewProvider);
        return loading && !isMobileView
            ? RotatedBox(
                quarterTurns: 1,
                child: const LinearProgressIndicator(),
              )
            : Container();
      },
    );
  }

  Widget _buildBackground({
    required BuildContext context,
    required Widget child,
  }) {
    if (!system.isMacOS) {
      return Material(
        color: context.colorScheme.surfaceContainer,
        child: child,
      );
    }
    return TransparentMacOSSidebar(
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = navigationState.navigationItems;
    final isMobileView = navigationState.viewMode == ViewMode.mobile;
    if (isMobileView) {
      return child;
    }
    final currentIndex = navigationState.currentIndex;
    final showLabel = ref.watch(appSettingProvider).showLabel;
    return Row(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            _buildBackground(
              context: context,
              child: Column(
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  if (!system.isMacOS) ...[
                    AppIcon(),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: HiddenBarScrollBehavior(),
                      child: SingleChildScrollView(
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            backgroundColor: Colors.transparent,
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
                            onDestinationSelected: (index) {
                              globalState.appController
                                  .toPage(navigationItems[index].label);
                            },
                            extended: false,
                            selectedIndex: currentIndex,
                            labelType: showLabel
                                ? NavigationRailLabelType.all
                                : NavigationRailLabelType.none,
                          ),
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
                    icon: Icon(
                      Icons.menu,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            _buildLoading(),
          ],
        ),
        Expanded(
          flex: 1,
          child: ClipRect(
            child: child,
          ),
        )
      ],
    );
  }
}

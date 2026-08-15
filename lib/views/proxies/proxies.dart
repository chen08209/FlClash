import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'setting.dart';
import 'tab.dart';

@visibleForTesting
bool shouldRefreshGroupsOnProxiesEnter({
  required bool isProxiesPage,
  required bool hasGroups,
}) {
  return isProxiesPage && !hasGroups;
}

@visibleForTesting
bool shouldApplyProfileOnProxiesEnter({
  required bool isProxiesPage,
  required bool hasGroups,
  required bool isFreeNodesProfile,
}) {
  return isProxiesPage && !hasGroups && isFreeNodesProfile;
}

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  List<Widget> _buildActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      if (_isTab)
        IconButton(
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          icon: const Icon(Icons.adjust, weight: 1),
        ),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              final isMobile = ref.read(isMobileViewProvider);
              open(offset: Offset(0, isMobile ? 0 : 20));
            },
            icon: const Icon(Icons.more_vert),
          );
        },
        popup: CommonPopupMenu(
          items: [
            PopupMenuItemData(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: () {
                showSheet(
                  context: context,
                  props: const SheetProps(isScrollControlled: true),
                  builder: (_) {
                    return AdaptiveSheetScaffold(
                      body: const ProxiesSetting(),
                      title: appLocalizations.settings,
                    );
                  },
                );
              },
            ),
            if (_hasProviders)
              PopupMenuItemData(
                icon: Icons.poll_outlined,
                label: appLocalizations.providers,
                onPressed: () {
                  showExtend(
                    context,
                    builder: (_) {
                      return const ProvidersView();
                    },
                  );
                },
              ),
          ],
        ),
      ),
    ];
  }

  Widget? _buildFAB() {
    return _isTab
        ? DelayTestButton(
            onClick: () async {
              await _proxiesTabKey.currentState?.delayTestCurrentGroup();
            },
          )
        : null;
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  void _refreshGroupsIfNeededOnEnter(bool isProxiesPage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasGroups = ref.read(currentGroupsStateProvider).value.isNotEmpty;
      if (!shouldRefreshGroupsOnProxiesEnter(
        isProxiesPage: isProxiesPage,
        hasGroups: hasGroups,
      )) {
        return;
      }
      final currentProfile = ref.read(currentProfileProvider);
      if (shouldApplyProfileOnProxiesEnter(
        isProxiesPage: isProxiesPage,
        hasGroups: hasGroups,
        isFreeNodesProfile: currentProfile?.isFreeNodesProfile == true,
      )) {
        unawaited(
          ref
              .read(setupActionProvider.notifier)
              .applyProfile(silence: true, force: true),
        );
        return;
      }
      ref
          .read(proxiesActionProvider.notifier)
          .updateGroupsDebounce(Duration.zero);
    });
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      currentPageLabelProvider.select((state) => state == PageLabel.proxies),
      (prev, next) {
        if (prev != next && next) {
          _refreshGroupsIfNeededOnEnter(true);
        }
      },
      fireImmediately: true,
    );
    ref.listenManual(providersProvider.select((state) => state.isNotEmpty), (
      prev,
      next,
    ) {
      if (prev != next) {
        setState(() {
          _hasProviders = next;
        });
      }
    }, fireImmediately: true);
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final proxiesType = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.type),
    );
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    return CommonScaffold(
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildFAB(),
      actions: _buildActions(context),
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (proxiesType) {
        ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

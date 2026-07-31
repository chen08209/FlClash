import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'setting.dart';
import 'tab.dart';
import 'chain_proxy.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;
  bool _isUpdatingChainProxy = false;

  Future<void> _openChainProxy() async {
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId == null) {
      globalState.showNotifier(context.appLocalizations.nullProfileDesc);
      return;
    }
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => ChainProxyManagerView(profileId: profileId),
    );
  }

  Future<void> _toggleChainProxy() async {
    if (_isUpdatingChainProxy) return;
    final enabled = ref.read(chainProxyEnabledProvider);
    await globalState.safeRun(
      () async {
        final profileId = ref.read(currentProfileIdProvider);
        final nextEnabled = !enabled;
        if (profileId != null) {
          await ref
              .read(setupActionProvider.notifier)
              .validateChainProxyProfile(
                profileId: profileId,
                enabled: nextEnabled,
              );
        }
        ref.read(chainProxyEnabledProvider.notifier).value = nextEnabled;
        try {
          await preferences.saveConfig(ref.read(configProvider));
          if (profileId == null) return;
          ref.invalidate(setupStateProvider(profileId));
          await ref
              .read(setupActionProvider.notifier)
              .applyProfile(force: true);
        } catch (error, stackTrace) {
          ref.read(chainProxyEnabledProvider.notifier).value = enabled;
          await preferences.saveConfig(ref.read(configProvider));
          if (profileId != null) {
            ref.invalidate(setupStateProvider(profileId));
            try {
              await ref
                  .read(setupActionProvider.notifier)
                  .applyProfile(force: true, silence: true);
            } catch (rollbackError) {
              commonPrint.log('Unable to restore proxy config: $rollbackError');
            }
          }
          Error.throwWithStackTrace(error, stackTrace);
        }
      },
      onStart: () => setState(() => _isUpdatingChainProxy = true),
      onEnd: () {
        if (mounted) setState(() => _isUpdatingChainProxy = false);
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, bool chainProxyEnabled) {
    final appLocalizations = context.appLocalizations;
    return [
      IconButton(
        tooltip: chainProxyEnabled
            ? appLocalizations.disableChainProxy
            : appLocalizations.enableChainProxy,
        isSelected: chainProxyEnabled,
        onPressed: _isUpdatingChainProxy ? null : _toggleChainProxy,
        icon: const Icon(Icons.account_tree_outlined),
        selectedIcon: const Icon(Icons.account_tree),
      ),
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

  Widget? _buildFAB(bool showChainProxyManager) {
    if (!_isTab) return null;
    final delayButton = DelayTestButton(
      onClick: () async {
        await _proxiesTabKey.currentState?.delayTestCurrentGroup();
      },
    );
    if (!showChainProxyManager) return delayButton;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox.square(
          dimension: 56,
          child: FloatingActionButton(
            heroTag: null,
            tooltip: context.appLocalizations.chainProxyConfig,
            onPressed: _openChainProxy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 12),
        delayButton,
      ],
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
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
    final chainProxyEnabled = ref.watch(chainProxyEnabledProvider);
    final showChainProxyManager =
        chainProxyEnabled &&
        ref.watch(
          proxiesTabStateProvider.select(
            (state) => state.currentGroupName == chainProxyGroupInternalName,
          ),
        );
    return CommonScaffold(
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildFAB(showChainProxyManager),
      actions: _buildActions(context, chainProxyEnabled),
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (proxiesType) {
        ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/list.dart';
import 'package:fl_clash/fragments/proxies/providers.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common.dart';
import 'setting.dart';
import 'tab.dart';

class ProxiesFragment extends ConsumerStatefulWidget {
  const ProxiesFragment({super.key});

  @override
  ConsumerState<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends ConsumerState<ProxiesFragment>
    with PageMixin {
  final GlobalKey<ProxiesTabFragmentState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  @override
  get actions => [
        if (_hasProviders)
          IconButton(
            onPressed: () {
              showExtendPage(
                isScaffold: true,
                extendPageWidth: 360,
                context,
                body: const ProvidersView(),
                title: appLocalizations.providers,
              );
            },
            icon: const Icon(
              Icons.poll_outlined,
            ),
          ),
        _isTab
            ? IconButton(
                onPressed: () {
                  _proxiesTabKey.currentState?.scrollToGroupSelected();
                },
                icon: const Icon(
                  Icons.adjust_outlined,
                ),
              )
            : IconButton(
                onPressed: () {
                  showExtendPage(
                    context,
                    extendPageWidth: 360,
                    title: appLocalizations.iconConfiguration,
                    body: _IconConfigView(),
                  );
                },
                icon: const Icon(
                  Icons.style_outlined,
                ),
              ),
        IconButton(
          onPressed: () {
            showSheet(
              title: appLocalizations.proxiesSetting,
              context: context,
              body: const ProxiesSetting(),
            );
          },
          icon: const Icon(
            Icons.tune,
          ),
        )
      ];

  @override
  get floatingActionButton => _isTab
      ? DelayTestButton(
          onClick: () async {
            await delayTest(
              currentTabProxies,
              currentTabTestUrl,
            );
          },
        )
      : null;

  @override
  void initState() {
    ref.listenManual(
      proxiesActionsStateProvider,
      fireImmediately: true,
      (prev, next) {
        if (prev == next) {
          return;
        }
        if (next.pageLabel == PageLabel.proxies) {
          _hasProviders = next.hasProviders;
          _isTab = next.type == ProxiesType.tab;
          initPageState();
          return;
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final proxiesType =
        ref.watch(proxiesStyleSettingProvider.select((state) => state.type));
    return switch (proxiesType) {
      ProxiesType.tab => ProxiesTabFragment(
          key: _proxiesTabKey,
        ),
      ProxiesType.list => const ProxiesListFragment(),
    };
  }
}

class _IconConfigView extends ConsumerWidget {
  const _IconConfigView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconMap =
        ref.watch(proxiesStyleSettingProvider.select((state) => state.iconMap));
    final entries = iconMap.entries.toList();
    return ListPage(
      title: appLocalizations.iconConfiguration,
      items: entries,
      keyLabel: appLocalizations.regExp,
      valueLabel: appLocalizations.icon,
      keyBuilder: (item) => Key(item.key),
      titleBuilder: (item) => Text(item.key),
      leadingBuilder: (item) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: CommonTargetIcon(
          src: item.value,
          size: 42,
        ),
      ),
      subtitleBuilder: (item) => Text(
        item.value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onChange: (entries) {
        ref.read(proxiesStyleSettingProvider.notifier).updateState(
              (state) => state.copyWith(
                iconMap: Map.fromEntries(entries),
              ),
            );
      },
    );
  }
}

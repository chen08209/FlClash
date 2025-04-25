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
              showExtend(
                context,
                builder: (_, type) {
                  return ProvidersView(
                    type: type,
                  );
                },
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
                  showExtend(
                    context,
                    builder: (_, type) {
                      return AdaptiveSheetScaffold(
                        type: type,
                        body: const _IconConfigView(),
                        title: appLocalizations.iconConfiguration,
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.style_outlined,
                ),
              ),
        IconButton(
          onPressed: () {
            showSheet(
              context: context,
              props: SheetProps(
                isScrollControlled: true,
              ),
              builder: (_, type) {
                return AdaptiveSheetScaffold(
                  type: type,
                  body: const ProxiesSetting(),
                  title: appLocalizations.settings,
                );
              },
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
    final proxiesType = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => state.type,
      ),
    );

    ref.watch(themeSettingProvider.select((state) => state.textScale));
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
    return MapInputPage(
      title: appLocalizations.iconConfiguration,
      map: iconMap,
      keyLabel: appLocalizations.regExp,
      valueLabel: appLocalizations.icon,
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
      onChange: (value) {
        ref.read(proxiesStyleSettingProvider.notifier).updateState(
              (state) => state.copyWith(
                iconMap: value,
              ),
            );
      },
    );
  }
}

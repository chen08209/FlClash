import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'setting.dart';
import 'tab.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> with PageMixin {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  @override
  get actions => [
        if (_isTab)
          IconButton(
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            icon: Icon(
              Icons.adjust,
              weight: 1,
            ),
          ),
        CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              onPressed: () {
                open(
                  offset: Offset(0, 20),
                );
              },
              icon: Icon(
                Icons.more_vert,
              ),
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
              ),
              if (_hasProviders)
                PopupMenuItemData(
                  icon: Icons.poll_outlined,
                  label: appLocalizations.providers,
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
                ),
              if (!_isTab)
                PopupMenuItemData(
                  icon: Icons.style_outlined,
                  label: appLocalizations.iconConfiguration,
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
                ),
            ],
          ),
        )
      ];

  @override
  get onSearch => (value) {
        ref.read(proxiesQueryProvider.notifier).value = value;
      };

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(proxiesQueryProvider.notifier).value = "";
      }
    });
  }

  @override
  get floatingActionButton => _isTab
      ? DelayTestButton(
          onClick: () async {
            await _proxiesTabKey.currentState?.delayTestCurrentGroup();
          },
        )
      : null;

  @override
  void initState() {
    [
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
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(proxiesQueryProvider.notifier).value = "";
            }
          });
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
    return switch (proxiesType) {
      ProxiesType.tab => ProxiesTabView(
          key: _proxiesTabKey,
        ),
      ProxiesType.list => const ProxiesListView(),
    };
  }
}

class _IconConfigView extends ConsumerWidget {
  const _IconConfigView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconMap = ref.watch(proxiesStyleSettingProvider.select(
      (state) => state.iconMap,
    ));
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

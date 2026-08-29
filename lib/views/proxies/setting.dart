import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProxiesSetting extends StatelessWidget {
  const ProxiesSetting({super.key});

  IconData _getIconWithProxiesType(ProxiesType type) {
    return switch (type) {
      ProxiesType.tab => Icons.view_carousel,
      ProxiesType.list => Icons.view_list,
    };
  }

  IconData _getIconWithProxiesSortType(ProxiesSortType type) {
    return switch (type) {
      ProxiesSortType.none => Icons.sort,
      ProxiesSortType.delay => Icons.network_ping,
      ProxiesSortType.name => Icons.sort_by_alpha,
    };
  }

  String _getStringProxiesSortType(BuildContext context, ProxiesSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      ProxiesSortType.none => appLocalizations.defaultText,
      ProxiesSortType.delay => appLocalizations.delay,
      ProxiesSortType.name => appLocalizations.name,
    };
  }

  String getTextForProxiesLayout(
    BuildContext context,
    ProxiesLayout proxiesLayout,
  ) {
    final appLocalizations = context.appLocalizations;
    return switch (proxiesLayout) {
      ProxiesLayout.tight => appLocalizations.tight,
      ProxiesLayout.standard => appLocalizations.standard,
      ProxiesLayout.loose => appLocalizations.loose,
    };
  }

  String _getTextWithProxiesIconStyle(
    BuildContext context,
    ProxiesIconStyle style,
  ) {
    final appLocalizations = context.appLocalizations;
    return switch (style) {
      ProxiesIconStyle.standard => appLocalizations.standard,
      ProxiesIconStyle.none => appLocalizations.none,
      ProxiesIconStyle.icon => appLocalizations.onlyIcon,
    };
  }

  List<Widget> _buildStyleSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      isFirst: true,
      title: appLocalizations.style,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final proxiesType = ref.watch(
                proxiesStyleSettingProvider.select((state) => state.type),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesType.values)
                    SettingInfoCard(
                      Info(
                        label: Intl.message(item.name),
                        iconData: _getIconWithProxiesType(item),
                      ),
                      isSelected: proxiesType == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state.copyWith(type: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.sort,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final sortType = ref.watch(
                proxiesStyleSettingProvider.select((state) => state.sortType),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getStringProxiesSortType(context, item),
                        iconData: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: sortType == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state.copyWith(sortType: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSizeSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.size,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final cardType = ref.watch(
                proxiesStyleSettingProvider.select((state) => state.cardType),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxyCardType.values)
                    SettingTextCard(
                      Intl.message(item.name),
                      isSelected: item == cardType,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state.copyWith(cardType: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLayoutSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.layout,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final layout = ref.watch(
                proxiesStyleSettingProvider.select((state) => state.layout),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesLayout.values)
                    SettingTextCard(
                      getTextForProxiesLayout(context, item),
                      isSelected: item == layout,
                      onPressed: () {
                        ref.watch(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state.copyWith(layout: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupStyleSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.iconStyle,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final iconStyle = ref.watch(
                proxiesStyleSettingProvider.select((state) => state.iconStyle),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesIconStyle.values)
                    SettingTextCard(
                      _getTextWithProxiesIconStyle(context, item),
                      isSelected: iconStyle == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state.copyWith(iconStyle: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildStyleSetting(context),
          ..._buildSortSetting(context),
          ..._buildLayoutSetting(context),
          ..._buildSizeSetting(context),
          Consumer(
            builder: (_, ref, child) {
              final isList = ref.watch(
                proxiesStyleSettingProvider.select(
                  (state) => state.type == ProxiesType.list,
                ),
              );
              if (isList) {
                return child!;
              }
              return Container();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [..._buildGroupStyleSetting(context)],
            ),
          ),
        ],
      ),
    );
  }
}

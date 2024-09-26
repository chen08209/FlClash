import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  String _getStringProxiesSortType(ProxiesSortType type) {
    return switch (type) {
      ProxiesSortType.none => appLocalizations.defaultText,
      ProxiesSortType.delay => appLocalizations.delay,
      ProxiesSortType.name => appLocalizations.name,
    };
  }

  String getTextForProxiesLayout(ProxiesLayout proxiesLayout) {
    return switch (proxiesLayout) {
      ProxiesLayout.tight => appLocalizations.tight,
      ProxiesLayout.standard => appLocalizations.standard,
      ProxiesLayout.loose => appLocalizations.loose,
    };
  }

  String _getTextWithProxiesIconStyle(ProxiesIconStyle style) {
    return switch (style) {
      ProxiesIconStyle.standard => appLocalizations.standard,
      ProxiesIconStyle.none => appLocalizations.noIcon,
      ProxiesIconStyle.icon => appLocalizations.onlyIcon,
    };
  }

  List<Widget> _buildStyleSetting() {
    return generateSection(
      title: appLocalizations.style,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxiesType>(
            selector: (_, config) => config.proxiesStyle.type,
            builder: (_, proxiesType, __) {
              final config = globalState.appController.config;
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
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          type: item,
                        );
                      },
                    )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  List<Widget> _buildSortSetting() {
    return generateSection(
      title: appLocalizations.sort,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxiesSortType>(
            selector: (_, config) => config.proxiesStyle.sortType,
            builder: (_, proxiesSortType, __) {
              final config = globalState.appController.config;
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getStringProxiesSortType(item),
                        iconData: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: proxiesSortType == item,
                      onPressed: () {
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          sortType: item,
                        );
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

  List<Widget> _buildSizeSetting() {
    return generateSection(
      title: appLocalizations.size,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxyCardType>(
            selector: (_, config) => config.proxiesStyle.cardType,
            builder: (_, proxyCardType, __) {
              final config = globalState.appController.config;
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxyCardType.values)
                    SettingTextCard(
                      Intl.message(item.name),
                      isSelected: item == proxyCardType,
                      onPressed: () {
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          cardType: item,
                        );
                      },
                    )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  List<Widget> _buildLayoutSetting() {
    return generateSection(
      title: appLocalizations.layout,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxiesLayout>(
            selector: (_, config) => config.proxiesStyle.layout,
            builder: (_, proxiesLayout, __) {
              final config = globalState.appController.config;
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesLayout.values)
                    SettingTextCard(
                      getTextForProxiesLayout(item),
                      isSelected: item == proxiesLayout,
                      onPressed: () {
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          layout: item,
                        );
                      },
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  _buildGroupStyleSetting() {
    return generateSection(
      title: "图标样式",
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxiesIconStyle>(
            selector: (_, config) => config.proxiesStyle.iconStyle,
            builder: (_, iconStyle, __) {
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in ProxiesIconStyle.values)
                    SettingTextCard(
                      _getTextWithProxiesIconStyle(item),
                      isSelected: iconStyle == item,
                      onPressed: () {
                        final config = globalState.appController.config;
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          iconStyle: item,
                        );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildStyleSetting(),
          ..._buildSortSetting(),
          ..._buildLayoutSetting(),
          ..._buildSizeSetting(),
          Selector<Config, bool>(
            selector: (_, config) =>
                config.proxiesStyle.type == ProxiesType.list,
            builder: (_, value, child) {
              if (value) {
                return child!;
              }
              return Container();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildGroupStyleSetting(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

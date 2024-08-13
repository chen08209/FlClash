import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProxiesSettingWidget extends StatelessWidget {
  const ProxiesSettingWidget({super.key});

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

  List<Widget> _buildStyleSetting() {
    return generateSection(
      title: appLocalizations.style,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Selector<Config, ProxiesType>(
            selector: (_, config) => config.proxiesType,
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
                        config.proxiesType = item;
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
            selector: (_, config) => config.proxiesSortType,
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
                        config.proxiesSortType = item;
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
            selector: (_, config) => config.proxyCardType,
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
                        config.proxyCardType = item;
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
          child: Selector< Config, ProxiesLayout>(
            selector: (_, config) => config.proxiesLayout,
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
                        config.proxiesLayout = item;
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
        ],
      ),
    );
  }
}

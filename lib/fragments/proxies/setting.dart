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

  List<Widget> _buildColumnsSetting() {
    return generateSection(
      title: appLocalizations.columns,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          scrollDirection: Axis.horizontal,
          child: Selector2<AppState, Config, ColumnsSelectorState>(
            selector: (_, appState, config) => ColumnsSelectorState(
              columns: config.proxiesColumns,
              viewMode: appState.viewMode,
            ),
            builder: (_, state, __) {
              final config = globalState.appController.config;
              final targetColumnsArray = viewModeColumnsMap[state.viewMode]!;
              final currentColumns = other.getColumns(
                state.viewMode,
                state.columns,
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in targetColumnsArray)
                    SettingTextCard(
                      other.getColumnsTextForInt(item),
                      isSelected: item == currentColumns,
                      onPressed: () {
                        config.proxiesColumns = item;
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
          ..._buildColumnsSetting(),
          ..._buildSizeSetting(),
        ],
      ),
    );
  }
}

class SettingInfoCard extends StatelessWidget {
  final Info info;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingInfoCard(
    this.info, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: isSelected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Icon(info.iconData),
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              child: Text(
                info.label,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onPressed: onPressed,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: context.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

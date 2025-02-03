import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/about.dart';
import 'package:fl_clash/fragments/access.dart';
import 'package:fl_clash/fragments/application_setting.dart';
import 'package:fl_clash/fragments/config/config.dart';
import 'package:fl_clash/fragments/hotkey.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'backup_and_recovery.dart';
import 'theme.dart';
import 'package:path/path.dart' show dirname, join;

class ToolsFragment extends StatefulWidget {
  const ToolsFragment({super.key});

  @override
  State<ToolsFragment> createState() => _ToolboxFragmentState();
}

class _ToolboxFragmentState extends State<ToolsFragment> {
  _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: OpenDelegate(
        title: Intl.message(navigationItem.label),
        widget: navigationItem.fragment,
        extendPageWidth: 360,
      ),
    );
  }

  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return Column(
      children: [
        for (final navigationItem in navigationItems) ...[
          _buildNavigationMenuItem(navigationItem),
          navigationItems.last != navigationItem
              ? const Divider(
                  height: 0,
                )
              : Container(),
        ]
      ],
    );
  }

  String _getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  List<Widget> _getOtherList() {
    return generateSection(
      title: appLocalizations.other,
      items: [
        ListItem(
          leading: const Icon(Icons.gavel),
          title: Text(appLocalizations.disclaimer),
          onTap: () async {
            final isDisclaimerAccepted =
                await globalState.appController.showDisclaimer();
            if (!isDisclaimerAccepted) {
              globalState.appController.handleExit();
            }
          },
        ),
        ListItem.open(
          leading: const Icon(Icons.info),
          title: Text(appLocalizations.about),
          delegate: OpenDelegate(
            title: appLocalizations.about,
            widget: const AboutFragment(),
          ),
        ),
      ],
    );
  }

  List<Widget> _getSettingList() {
    return generateSection(
      title: appLocalizations.settings,
      items: [
        Selector<Config, String?>(
          selector: (_, config) => config.appSetting.locale,
          builder: (_, localeString, __) {
            final subTitle = localeString ?? appLocalizations.defaultText;
            final currentLocale = other.getLocaleForString(localeString);
            return ListItem<Locale?>.options(
              leading: const Icon(Icons.language_outlined),
              title: Text(appLocalizations.language),
              subtitle: Text(Intl.message(subTitle)),
              delegate: OptionsDelegate(
                title: appLocalizations.language,
                options: [null, ...AppLocalizations.delegate.supportedLocales],
                onChanged: (Locale? value) {
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    locale: value?.toString(),
                  );
                },
                textBuilder: (locale) => _getLocaleString(locale),
                value: currentLocale,
              ),
            );
          },
        ),
        ListItem.open(
          leading: const Icon(Icons.style),
          title: Text(appLocalizations.theme),
          subtitle: Text(appLocalizations.themeDesc),
          delegate: OpenDelegate(
            title: appLocalizations.theme,
            widget: const ThemeFragment(),
            extendPageWidth: 360,
          ),
        ),
        ListItem.open(
          leading: const Icon(Icons.cloud_sync),
          title: Text(appLocalizations.backupAndRecovery),
          subtitle: Text(appLocalizations.backupAndRecoveryDesc),
          delegate: OpenDelegate(
            title: appLocalizations.backupAndRecovery,
            widget: const BackupAndRecovery(),
          ),
        ),
        if (system.isDesktop)
          ListItem.open(
            leading: const Icon(Icons.keyboard),
            title: Text(appLocalizations.hotkeyManagement),
            subtitle: Text(appLocalizations.hotkeyManagementDesc),
            delegate: OpenDelegate(
              title: appLocalizations.hotkeyManagement,
              widget: const HotKeyFragment(),
            ),
          ),
        if (Platform.isWindows)
          ListItem(
            leading: const Icon(Icons.lock),
            title: Text(appLocalizations.loopback),
            subtitle: Text(appLocalizations.loopbackDesc),
            onTap: () {
              windows?.runas(
                '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
                "",
              );
            },
          ),
        if (Platform.isAndroid)
          ListItem.open(
            leading: const Icon(Icons.view_list),
            title: Text(appLocalizations.accessControl),
            subtitle: Text(appLocalizations.accessControlDesc),
            delegate: OpenDelegate(
              title: appLocalizations.appAccessControl,
              widget: const AccessFragment(),
            ),
          ),
        ListItem.open(
          leading: const Icon(Icons.edit),
          title: Text(appLocalizations.override),
          subtitle: Text(appLocalizations.overrideDesc),
          delegate: OpenDelegate(
            title: appLocalizations.override,
            widget: const ConfigFragment(),
          ),
        ),
        ListItem.open(
          leading: const Icon(Icons.settings),
          title: Text(appLocalizations.application),
          subtitle: Text(appLocalizations.applicationDesc),
          delegate: OpenDelegate(
            title: appLocalizations.application,
            widget: const ApplicationSettingFragment(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (_) {
        final items = [
          Selector<AppState, MoreToolsSelectorState>(
            selector: (_, appState) {
              return MoreToolsSelectorState(
                navigationItems: appState.navigationItems.where((element) {
                  final isMore =
                      element.modes.contains(NavigationItemMode.more);
                  final isDesktop =
                      element.modes.contains(NavigationItemMode.desktop);
                  if (isMore && !isDesktop) return true;
                  if (appState.viewMode != ViewMode.mobile || !isMore) {
                    return false;
                  }
                  return true;
                }).toList(),
              );
            },
            builder: (_, state, __) {
              if (state.navigationItems.isEmpty) {
                return Container();
              }
              return Column(
                children: [
                  ListHeader(title: appLocalizations.more),
                  _buildNavigationMenu(state.navigationItems)
                ],
              );
            },
          ),
          ..._getSettingList(),
          ..._getOtherList(),
        ];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) => items[index],
          padding: const EdgeInsets.only(bottom: 20),
        );
      },
    );
  }
}

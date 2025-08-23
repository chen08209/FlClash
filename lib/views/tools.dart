import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/pages/login_page.dart';

import 'backup_and_recovery.dart';
import 'developer.dart';
import 'theme.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolboxViewState();
}

class _ToolboxViewState extends ConsumerState<ToolsView> {
  _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: OpenDelegate(
        title: Intl.message(navigationItem.label.name),
        widget: navigationItem.view,
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

  List<Widget> _getOtherList(bool enableDeveloperMode) {
    return [
      Text(
        appLocalizations.other,
        style: TechTheme.techTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TechTheme.primaryCyan,
        ),
      ),
      const SizedBox(height: 16),
      TechSettingItem(
        icon: Icons.gavel,
        title: appLocalizations.disclaimer,
        onTap: () async {
          final isDisclaimerAccepted =
              await globalState.appController.showDisclaimer();
          if (!isDisclaimerAccepted) {
            globalState.appController.handleExit();
          }
        },
        accentColor: TechTheme.neonOrange,
      ),
      if (enableDeveloperMode)
        TechSettingItem(
          icon: Icons.developer_board,
          title: appLocalizations.developerMode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(appLocalizations.developerMode)),
                  body: const DeveloperView(),
                ),
              ),
            );
          },
          accentColor: TechTheme.neonPink,
        ),
      TechSettingItem(
        icon: Icons.info,
        title: appLocalizations.about,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(appLocalizations.about)),
                body: const AboutView(),
              ),
            ),
          );
        },
        accentColor: TechTheme.primaryBlue,
      ),
    ];
  }

  List<Widget> _getSettingList() {
    return [
      Text(
        appLocalizations.settings,
        style: TechTheme.techTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TechTheme.primaryCyan,
        ),
      ),
      const SizedBox(height: 16),
      TechSettingItem(
        icon: Icons.cloud_sync,
        title: appLocalizations.backupAndRecovery,
        subtitle: appLocalizations.backupAndRecoveryDesc,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(appLocalizations.backupAndRecovery)),
                body: const BackupAndRecovery(),
              ),
            ),
          );
        },
        accentColor: TechTheme.neonGreen,
      ),
      if (system.isDesktop)
        TechSettingItem(
          icon: Icons.keyboard,
          title: appLocalizations.hotkeyManagement,
          subtitle: appLocalizations.hotkeyManagementDesc,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(appLocalizations.hotkeyManagement)),
                  body: const HotKeyView(),
                ),
              ),
            );
          },
          accentColor: TechTheme.primaryBlue,
        ),
      if (Platform.isWindows)
        TechSettingItem(
          icon: Icons.lock,
          title: appLocalizations.loopback,
          subtitle: appLocalizations.loopbackDesc,
          onTap: () {
            windows?.runas(
              '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
              "",
            );
          },
          accentColor: TechTheme.neonYellow,
        ),
      TechSettingItem(
        icon: Icons.edit,
        title: appLocalizations.basicConfig,
        subtitle: appLocalizations.basicConfigDesc,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(appLocalizations.override)),
                body: const ConfigView(),
              ),
            ),
          );
        },
        accentColor: TechTheme.primaryPurple,
      ),
      TechSettingItem(
        icon: Icons.settings,
        title: appLocalizations.application,
        subtitle: appLocalizations.applicationDesc,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(appLocalizations.application)),
                body: const ApplicationSettingView(),
              ),
            ),
          );
        },
        accentColor: TechTheme.primaryCyan,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(a: state.locale, b: state.developerMode),
      ),
    );

    return TechPageWrapper(
      showAppBar: false,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 账户信息区域
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
                    ),
                  );
                }
                final prefs = snapshot.data!;
                final email = prefs.getString('user_email') ?? '未知邮箱';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '账户信息',
                      style: TechTheme.techTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TechTheme.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TechTheme.techCard(
                      animated: true,
                      accentColor: TechTheme.primaryPurple,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: TechTheme.primaryPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: TechTheme.primaryPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email,
                                      style: TechTheme.techTextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '当前登录账户',
                                      style: TechTheme.techTextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TechTheme.techButton(
                                  text: '客服中心',
                                  onPressed: () {},
                                  color: TechTheme.primaryBlue,
                                  height: 36,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TechTheme.techButton(
                                  text: '注销登录',
                                  onPressed: () async {
                                    await prefs.clear();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const LoginPage()),
                                      (route) => false,
                                    );
                                  },
                                  color: TechTheme.neonOrange,
                                  height: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // 更多工具区域
            Consumer(
              builder: (_, ref, __) {
                final state = ref.watch(moreToolsSelectorStateProvider);
                if (state.navigationItems.isEmpty) {
                  return Container();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.more,
                      style: TechTheme.techTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TechTheme.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.navigationItems.map((item) => 
                      TechSettingItem(
                        icon: (item.icon as Icon).icon!,
                        title: Intl.message(item.label.name),
                        subtitle: item.description != null ? Intl.message(item.description!) : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(title: Text(Intl.message(item.label.name))),
                                body: item.view,
                              ),
                            ),
                          );
                        },
                        accentColor: TechTheme.primaryCyan,
                      ),
                    ).toList(),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
            
            // 设置区域
            ..._getSettingList(),
            
            const SizedBox(height: 24),
            
            // 其他区域
            ..._getOtherList(vm2.b),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  String _getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale =
        ref.watch(appSettingProvider.select((state) => state.locale));
    final subTitle = locale ?? appLocalizations.defaultText;
    final currentLocale = utils.getLocaleForString(locale);
    return ListItem<Locale?>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(appLocalizations.language),
      subtitle: Text(Intl.message(subTitle)),
      delegate: OptionsDelegate(
        title: appLocalizations.language,
        options: [null, ...AppLocalizations.delegate.supportedLocales],
        onChanged: (Locale? locale) {
          ref.read(appSettingProvider.notifier).updateState(
                (state) => state.copyWith(locale: locale?.toString()),
              );
        },
        textBuilder: (locale) => _getLocaleString(locale),
        value: currentLocale,
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.style),
      title: Text(appLocalizations.theme),
      subtitle: Text(appLocalizations.themeDesc),
      delegate: OpenDelegate(
        title: appLocalizations.theme,
        widget: const ThemeView(),
      ),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.cloud_sync),
      title: Text(appLocalizations.backupAndRecovery),
      subtitle: Text(appLocalizations.backupAndRecoveryDesc),
      delegate: OpenDelegate(
        title: appLocalizations.backupAndRecovery,
        widget: const BackupAndRecovery(),
      ),
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.keyboard),
      title: Text(appLocalizations.hotkeyManagement),
      subtitle: Text(appLocalizations.hotkeyManagementDesc),
      delegate: OpenDelegate(
        title: appLocalizations.hotkeyManagement,
        widget: const HotKeyView(),
      ),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.lock),
      title: Text(appLocalizations.loopback),
      subtitle: Text(appLocalizations.loopbackDesc),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          "",
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.view_list),
      title: Text(appLocalizations.accessControl),
      subtitle: Text(appLocalizations.accessControlDesc),
      delegate: OpenDelegate(
        title: appLocalizations.appAccessControl,
        widget: const AccessView(),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.edit),
      title: Text(appLocalizations.basicConfig),
      subtitle: Text(appLocalizations.basicConfigDesc),
      delegate: OpenDelegate(
        title: appLocalizations.override,
        widget: const ConfigView(),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.settings),
      title: Text(appLocalizations.application),
      subtitle: Text(appLocalizations.applicationDesc),
      delegate: OpenDelegate(
        title: appLocalizations.application,
        widget: const ApplicationSettingView(),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.gavel),
      title: Text(appLocalizations.disclaimer),
      onTap: () async {
        final isDisclaimerAccepted =
            await globalState.appController.showDisclaimer();
        if (!isDisclaimerAccepted) {
          globalState.appController.handleExit();
        }
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.info),
      title: Text(appLocalizations.about),
      delegate: OpenDelegate(
        title: appLocalizations.about,
        widget: const AboutView(),
      ),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.developer_board),
      title: Text(appLocalizations.developerMode),
      delegate: OpenDelegate(
        title: appLocalizations.developerMode,
        widget: const DeveloperView(),
      ),
    );
  }
}

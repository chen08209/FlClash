import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/copy_button.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'pages/pages.dart';

class Application extends ConsumerStatefulWidget {
  const Application({
    super.key,
  });

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  Timer? _autoUpdateGroupTaskTimer;
  Timer? _autoUpdateProfilesTaskTimer;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CommonPageTransitionsBuilder(),
      TargetPlatform.windows: CommonPageTransitionsBuilder(),
      TargetPlatform.linux: CommonPageTransitionsBuilder(),
      TargetPlatform.macOS: CommonPageTransitionsBuilder(),
    },
  );

  ColorScheme _getAppColorScheme({
    required Brightness brightness,
    int? primaryColor,
  }) {
    return ref.read(genColorSchemeProvider(brightness));
  }

  @override
  void initState() {
    super.initState();
    _autoUpdateGroupTask();
    _autoUpdateProfilesTask();
    globalState.appController = AppController(context, ref);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        globalState.appController = AppController(currentContext, ref);
      }
      
      await _checkLinuxDependencies(currentContext ?? context);
      
      await globalState.appController.init();
      globalState.appController.initLink();
      app?.initShortcuts();
    });
  }

  Future<void> _checkLinuxDependencies(BuildContext context) async {
    if (!Platform.isLinux) return;

    final shouldNotRemind = globalState.config.appSetting.linuxDepsNotRemind;
    if (shouldNotRemind) return;

    final appindicatorCheck = await Process.run('pkg-config', ['--exists', 'ayatana-appindicator3-0.1']);
    
    final keybinderCheck = await Process.run('pkg-config', ['--exists', 'keybinder-3.0']);
    
    if (appindicatorCheck.exitCode != 0 || keybinderCheck.exitCode != 0) {
      if (context.mounted) {
        await _showLinuxDependenciesWarning(context);
      }
    } else {
      final updatedConfig = globalState.config.copyWith(
        appSetting: globalState.config.appSetting.copyWith(
          linuxDepsNotRemind: true,
        ),
      );
      globalState.config = updatedConfig;
    }
  }

  Future<void> _showLinuxDependenciesWarning(BuildContext context) async {
    final linuxDepsInstallCommand = await _getLinuxDepsInstallCommand();
    return globalState.showCommonDialog<void>(
      child: CommonDialog(
          title: appLocalizations.tip,
          actions: [
            TextButton(
              onPressed: () async {
                final updatedConfig = globalState.config.copyWith(
                  appSetting: globalState.config.appSetting.copyWith(
                    linuxDepsNotRemind: true,
                  ),
                );
                globalState.config = updatedConfig;
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(appLocalizations.dontRemindMeAgain),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.confirm),
            ),
          ],
          child: SizedBox(
            width: dialogCommonWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLocalizations.linuxDepsHelp),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          "bash",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CopyButton(
                          data: linuxDepsInstallCommand, 
                          recoverDuration: const Duration(seconds: 2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: SelectableText(
                          linuxDepsInstallCommand,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<String> _getLinuxDepsInstallCommand() async {
    try {
      final result = await Process.run('cat', ['/etc/os-release']);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        
        final idRegex = RegExp(r'^ID=(.*)$', multiLine: true);
        final match = idRegex.firstMatch(output);
        
        if (match != null) {
          final distroId = match.group(1)?.replaceAll('"', '').toLowerCase().trim();
          
          switch (distroId) {
            case 'ubuntu':
            case 'debian':
            case 'linuxmint':
            case 'pop':
              return 'sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev';
            
            case 'fedora':
            case 'rhel':
            case 'centos':
              return 'sudo dnf install libayatana-appindicator-gtk3-devel keybinder3-devel';
            
            case 'arch':
            case 'manjaro':
              return 'sudo pacman -S libayatana-appindicator libkeybinder3';
            
            case 'opensuse':
            case 'opensuse-leap':
            case 'opensuse-tumbleweed':
              return 'sudo zypper install ayatana-appindicator3-devel keybinder-3.0-devel';
          }
        }
      }
      
      return 'sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev';
    } catch (e) {
      return 'sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev';
    }
  }

  _autoUpdateGroupTask() {
    _autoUpdateGroupTaskTimer = Timer(const Duration(milliseconds: 20000), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        globalState.appController.updateGroupsDebounce();
        _autoUpdateGroupTask();
      });
    });
  }

  _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await globalState.appController.autoUpdateProfiles();
      _autoUpdateProfilesTask();
    });
  }

  _buildPlatformState(Widget child) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(
            child: ProxyManager(
              child: child,
            ),
          ),
        ),
      );
    }
    return AndroidManager(
      child: TileManager(
        child: child,
      ),
    );
  }

  _buildState(Widget child) {
    return AppStateManager(
      child: ClashManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            if (!results.contains(ConnectivityResult.vpn)) {
              await clashCore.closeConnections();
            }
            globalState.appController.updateLocalIp();
            globalState.appController.addCheckIpNumDebounce();
          },
          child: child,
        ),
      ),
    );
  }

  _buildPlatformApp(Widget child) {
    if (system.isDesktop) {
      return WindowHeaderContainer(
        child: child,
      );
    }
    return VpnManager(
      child: child,
    );
  }

  _buildApp(Widget child) {
    return MessageManager(
      child: ThemeManager(
        child: child,
      ),
    );
  }

  @override
  Widget build(context) {
    return _buildPlatformState(
      _buildState(
        Consumer(
          builder: (_, ref, child) {
            final locale =
                ref.watch(appSettingProvider.select((state) => state.locale));
            final themeProps = ref.watch(themeSettingProvider);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: globalState.navigatorKey,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              builder: (_, child) {
                return AppEnvManager(
                  child: _buildPlatformApp(
                    _buildApp(child!),
                  ),
                );
              },
              scrollBehavior: BaseScrollBehavior(),
              title: appName,
              locale: utils.getLocaleForString(locale),
              supportedLocales: AppLocalizations.delegate.supportedLocales,
              themeMode: themeProps.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.light,
                  primaryColor: themeProps.primaryColor,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.dark,
                  primaryColor: themeProps.primaryColor,
                ).toPureBlack(themeProps.pureBlack),
              ),
              home: child,
            );
          },
          child: const HomePage(),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    linkManager.destroy();
    _autoUpdateGroupTaskTimer?.cancel();
    _autoUpdateProfilesTaskTimer?.cancel();
    await clashCore.destroy();
    await globalState.appController.savePreferences();
    await globalState.appController.handleExit();
    super.dispose();
  }
}

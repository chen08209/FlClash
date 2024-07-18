import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'models/models.dart';
import 'pages/pages.dart';

runAppWithPreferences(
  Widget child, {
  required AppState appState,
  required Config config,
  required ClashConfig clashConfig,
}) {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ClashConfig>(
        create: (_) => clashConfig,
      ),
      ChangeNotifierProvider<Config>(
        create: (_) => config,
      ),
      ChangeNotifierProxyProvider2<Config, ClashConfig, AppState>(
        create: (_) => appState,
        update: (_, config, clashConfig, appState) {
          appState?.mode = clashConfig.mode;
          appState?.isCompatible = config.isCompatible;
          appState?.selectedMap = config.currentSelectedMap;
          return appState!;
        },
      )
    ],
    child: child,
  ));
}

class Application extends StatefulWidget {
  const Application({
    super.key,
  });

  @override
  State<Application> createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  late SystemColorSchemes systemColorSchemes;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  ColorScheme _getAppColorScheme({
    required Brightness brightness,
    int? primaryColor,
    required SystemColorSchemes systemColorSchemes,
  }) {
    if (primaryColor != null) {
      return ColorScheme.fromSeed(
        seedColor: Color(primaryColor),
        brightness: brightness,
      );
    } else {
      return systemColorSchemes.getSystemColorSchemeForBrightness(brightness);
    }
  }

  @override
  void initState() {
    super.initState();
    globalState.appController = AppController(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        globalState.appController = AppController(currentContext);
      }
      await globalState.appController.init();
      globalState.appController.initLink();
      _updateGroups();
    });
  }

  _buildApp(Widget app) {
    if (system.isDesktop) {
      return WindowContainer(
        child: TrayContainer(
          child: app,
        ),
      );
    }
    return AndroidContainer(
      child: TileContainer(
        child: app,
      ),
    );
  }

  _updateSystemColorSchemes(
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  ) {
    systemColorSchemes = SystemColorSchemes(
      lightColorScheme: lightDynamic,
      darkColorScheme: darkDynamic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.appController.updateSystemColorSchemes(systemColorSchemes);
    });
  }

  _updateGroups() {
    if (globalState.groupsUpdateTimer != null) {
      globalState.groupsUpdateTimer?.cancel();
      globalState.groupsUpdateTimer = null;
    }
    globalState.groupsUpdateTimer ??= Timer.periodic(
      httpTimeoutDuration,
      (timer) async {
        await globalState.appController.updateGroups();
      },
    );
  }

  @override
  Widget build(context) {
    return AppStateContainer(
      child: ClashMessageContainer(
        child: Selector2<AppState, Config, ApplicationSelectorState>(
          selector: (_, appState, config) => ApplicationSelectorState(
            locale: config.locale,
            themeMode: config.themeMode,
            primaryColor: config.primaryColor,
          ),
          builder: (_, state, child) {
            return DynamicColorBuilder(
              builder: (lightDynamic, darkDynamic) {
                _updateSystemColorSchemes(lightDynamic, darkDynamic);
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
                    return PopContainer(
                      child: _buildApp(child!),
                    );
                  },
                  scrollBehavior: BaseScrollBehavior(),
                  title: appName,
                  locale: other.getLocaleForString(state.locale),
                  supportedLocales: AppLocalizations.delegate.supportedLocales,
                  themeMode: state.themeMode,
                  theme: ThemeData(
                    useMaterial3: true,
                    pageTransitionsTheme: _pageTransitionsTheme,
                    colorScheme: _getAppColorScheme(
                      brightness: Brightness.light,
                      systemColorSchemes: systemColorSchemes,
                      primaryColor: state.primaryColor,
                    ),
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    pageTransitionsTheme: _pageTransitionsTheme,
                    colorScheme: _getAppColorScheme(
                      brightness: Brightness.dark,
                      systemColorSchemes: systemColorSchemes,
                      primaryColor: state.primaryColor,
                    ),
                  ),
                  home: child,
                );
              },
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
    await globalState.appController.savePreferences();
    super.dispose();
  }
}

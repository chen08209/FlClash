import 'dart:async';
import 'package:animations/animations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/state.dart';
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
  required AppFlowingState appFlowingState,
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
      ChangeNotifierProvider<AppFlowingState>(
        create: (_) => appFlowingState,
      ),
      ChangeNotifierProxyProvider2<Config, ClashConfig, AppState>(
        create: (_) => appState,
        update: (_, config, clashConfig, appState) {
          appState?.mode = clashConfig.mode;
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
  Timer? timer;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
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
    _initTimer();
    globalState.appController = AppController(context);
    globalState.measure = Measure.of(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        globalState.appController = AppController(currentContext);
      }
      await globalState.appController.init();
      globalState.appController.initLink();
      app?.initShortcuts();
    });
  }

  _initTimer() {
    _cancelTimer();
    timer = Timer.periodic(const Duration(milliseconds: 20000), (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        globalState.appController.updateGroupDebounce();
      });
    });
  }

  _cancelTimer() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
  }

  _buildApp(Widget app) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(
            child: ProxyManager(
              child: app,
            ),
          ),
        ),
      );
    }
    return AndroidManager(
      child: TileManager(
        child: app,
      ),
    );
  }

  _buildPage(Widget page) {
    if (system.isDesktop) {
      return WindowHeaderContainer(
        child: page,
      );
    }
    return VpnManager(
      child: page,
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

  @override
  Widget build(context) {
    return _buildApp(
      AppStateManager(
        child: ClashManager(
          child: Selector2<AppState, Config, ApplicationSelectorState>(
            selector: (_, appState, config) => ApplicationSelectorState(
              locale: config.appSetting.locale,
              themeMode: config.themeProps.themeMode,
              primaryColor: config.themeProps.primaryColor,
              prueBlack: config.themeProps.prueBlack,
              fontFamily: config.themeProps.fontFamily,
            ),
            builder: (_, state, child) {
              return DynamicColorBuilder(
                builder: (lightDynamic, darkDynamic) {
                  _updateSystemColorSchemes(lightDynamic, darkDynamic);
                  return MaterialApp(
                    navigatorKey: globalState.navigatorKey,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate
                    ],
                    builder: (_, child) {
                      return LayoutBuilder(
                        builder: (_, container) {
                          final appController = globalState.appController;
                          final maxWidth = container.maxWidth;
                          if (appController.appState.viewWidth != maxWidth) {
                            globalState.appController.updateViewWidth(maxWidth);
                          }
                          return _buildPage(child!);
                        },
                      );
                    },
                    scrollBehavior: BaseScrollBehavior(),
                    title: appName,
                    locale: other.getLocaleForString(state.locale),
                    supportedLocales:
                        AppLocalizations.delegate.supportedLocales,
                    themeMode: state.themeMode,
                    theme: ThemeData(
                      useMaterial3: true,
                      fontFamily: state.fontFamily.value,
                      pageTransitionsTheme: _pageTransitionsTheme,
                      colorScheme: _getAppColorScheme(
                        brightness: Brightness.light,
                        systemColorSchemes: systemColorSchemes,
                        primaryColor: state.primaryColor,
                      ),
                    ),
                    darkTheme: ThemeData(
                      useMaterial3: true,
                      fontFamily: state.fontFamily.value,
                      pageTransitionsTheme: _pageTransitionsTheme,
                      colorScheme: _getAppColorScheme(
                        brightness: Brightness.dark,
                        systemColorSchemes: systemColorSchemes,
                        primaryColor: state.primaryColor,
                      ).toPrueBlack(state.prueBlack),
                    ),
                    home: child,
                  );
                },
              );
            },
            child: const HomePage(),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    linkManager.destroy();
    await globalState.appController.savePreferences();
    super.dispose();
    _cancelTimer();
  }
}

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller.dart';
import 'pages/pages.dart';
import 'models/models.dart';

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
  bool? _isLoggedIn;
  bool _isCheckingAuth = true;

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
    _checkLoginStatus();
    _autoUpdateGroupTask();
    _autoUpdateProfilesTask();
    globalState.appController = AppController(context, ref);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        globalState.appController = AppController(currentContext, ref);
      }
      await globalState.appController.init();
      globalState.appController.initLink();
      app?.initShortcuts();
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isCheckingAuth = false;
    });
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
              home: _isCheckingAuth 
                  ? const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : (_isLoggedIn == true ? child! : LoginPage()),
              routes: {
                '/home': (context) => child!,
                '/register': (context) => const RegisterPage(),
                '/forgot_password': (context) => const ForgotPasswordPage(),
                '/subscription_store': (context) => const SubscriptionStorePage(),
                '/order_center': (context) => const OrderCenterPage(),
                '/ticket_list': (context) => const TicketListPage(),
                '/create_ticket': (context) => const CreateTicketPage(),
                '/traffic_log': (context) => const TrafficLogPage(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/checkout') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  if (args != null) {
                    final plan = args['plan'] as SubscriptionPlan;
                    final initialPeriod = args['initialPeriod'] as SubscriptionPeriod? ?? 
                                        SubscriptionPeriod.getAvailablePeriods(plan).first;
                    return MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        plan: plan,
                        initialPeriod: initialPeriod,
                      ),
                    );
                  }
                } else if (settings.name == '/payment') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  if (args != null) {
                    return MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        order: args['order'] as Order,
                        plan: args['plan'] as SubscriptionPlan,
                        discountAmount: args['discountAmount'] as int?,
                      ),
                    );
                  }
                } else if (settings.name == '/ticket_detail') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  if (args != null) {
                    return MaterialPageRoute(
                      builder: (context) => TicketDetailPage(
                        ticketId: args['ticketId'] as int,
                      ),
                    );
                  }
                }
                return null;
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
    _autoUpdateGroupTaskTimer?.cancel();
    _autoUpdateProfilesTaskTimer?.cancel();
    await clashCore.destroy();
    await globalState.appController.savePreferences();
    await globalState.appController.handleExit();
    super.dispose();
  }
}

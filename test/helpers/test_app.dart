import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final bool includeNavigatorKey;
  final bool wrapInProviderScope;
  final List<Override> overrides;
  final Widget Function(Widget child) homeBuilder;
  final Locale? locale;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final bool remoteFocus;
  final LiquidGlassQuality? liquidGlass;

  const TestApp({
    super.key,
    required this.child,
    this.includeNavigatorKey = true,
    this.wrapInProviderScope = false,
    this.overrides = const [],
    this.homeBuilder = _identity,
    this.locale,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.remoteFocus = false,
    this.liquidGlass,
  });

  static Widget _identity(Widget child) => child;

  @override
  Widget build(BuildContext context) {
    final app = PrismApp(
      navigatorKey: includeNavigatorKey ? globalState.navigatorKey : null,
      locale: locale,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode ?? ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        AppUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      emojiFont: (family: FontFamily.twEmoji.value, pattern: emojiPattern),
      remoteFocus: remoteFocus,
      liquidGlass: liquidGlass,
      builder: (context, child) => wrapViewScopes(context, child!),
      home: homeBuilder(child),
    );
    return overrides.isNotEmpty || wrapInProviderScope
        ? ProviderScope(overrides: overrides, child: app)
        : app;
  }
}

/// The scopes ThemeManager adds under PrismApp's.
Widget wrapViewScopes(BuildContext context, Widget child) {
  globalState.measure = MeasureScope.of(context);
  final hasProviders =
      context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
      null;
  return hasProviders ? AppViewScope(child: child) : child;
}

/// The scopes PrismApp and ThemeManager provide, for a test with its own
/// HostApp.
Widget wrapAppScopes(BuildContext context, Widget child) {
  return MeasureScope(
    measure: Measure.of(context, 1),
    child: EmojiFont(
      family: FontFamily.twEmoji.value,
      pattern: emojiPattern,
      child: Builder(builder: (context) => wrapViewScopes(context, child)),
    ),
  );
}

/// An app with only what a widget test asks of it, on the real PrismApp.
class HostApp extends StatelessWidget {
  const HostApp({
    super.key,
    this.navigatorKey,
    this.home,
    this.onGenerateRoute,
    this.builder,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.remoteFocus = false,
    this.debugShowCheckedModeBanner = false,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? home;
  final RouteFactory? onGenerateRoute;
  final TransitionBuilder? builder;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final Locale? locale;
  final bool remoteFocus;
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    return PrismApp(
      navigatorKey: navigatorKey,
      home: home,
      onGenerateRoute: onGenerateRoute,
      builder: builder,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      remoteFocus: remoteFocus,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        AppUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}

/// A plain page route with a fade, for a test about what is under or over it.
class HostPageRoute<T> extends PageRoute<T> {
  HostPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
  });

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}

/// A plain modal with a dim, for a test about what lies under one.
Future<T?> showDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  barrierLabel: 'dismiss',
  barrierColor: const Color(0x8A000000),
  transitionDuration: const Duration(milliseconds: 150),
  pageBuilder: (context, _, _) => builder(context),
  transitionBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final bool includeNavigatorKey;
  final bool wrapInProviderScope;
  final bool withStatusManager;
  final List<Override> overrides;
  final Widget Function(Widget child) homeBuilder;
  final Locale? locale;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const TestApp({
    super.key,
    required this.child,
    this.includeNavigatorKey = true,
    this.wrapInProviderScope = false,
    this.withStatusManager = false,
    this.overrides = const [],
    this.homeBuilder = _identity,
    this.locale,
    this.theme,
    this.darkTheme,
    this.themeMode,
  });

  static Widget _identity(Widget child) => child;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      navigatorKey: includeNavigatorKey ? globalState.navigatorKey : null,
      locale: locale,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        AppUiLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        return wrapAppScopes(
          context,
          withStatusManager ? StatusManager(child: child!) : child!,
        );
      },
      home: homeBuilder(child),
    );
    return overrides.isNotEmpty || wrapInProviderScope
        ? ProviderScope(overrides: overrides, child: app)
        : app;
  }
}

/// The scopes ThemeManager provides, for a test with its own MaterialApp.
Widget wrapAppScopes(BuildContext context, Widget child) {
  final measure = Measure.of(context, 1);
  globalState.measure = measure;
  final hasProviders =
      context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
      null;
  return MeasureScope(
    measure: measure,
    child: hasProviders ? AppViewScope(child: child) : child,
  );
}

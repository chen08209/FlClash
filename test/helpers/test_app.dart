import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final bool includeNavigatorKey;
  final bool setTheme;
  final bool wrapInProviderScope;
  final List<Override> overrides;
  final Widget Function(Widget child) homeBuilder;
  final Locale? locale;

  const TestApp({
    super.key,
    required this.child,
    this.includeNavigatorKey = true,
    this.setTheme = true,
    this.wrapInProviderScope = false,
    this.overrides = const [],
    this.homeBuilder = _identity,
    this.locale,
  });

  static Widget _identity(Widget child) => child;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      navigatorKey: includeNavigatorKey ? globalState.navigatorKey : null,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        if (setTheme) {
          globalState.theme = CommonTheme.of(context, 1);
        }
        return child!;
      },
      home: homeBuilder(child),
    );
    return overrides.isNotEmpty || wrapInProviderScope
        ? ProviderScope(overrides: overrides, child: app)
        : app;
  }
}

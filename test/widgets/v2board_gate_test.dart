import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/v2board/v2board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requires login before rendering the application', (
    tester,
  ) async {
    final authenticator = _FakeAuthenticator();
    final repository = _FakeSessionRepository();
    V2BoardSession? authenticatedSession;

    await tester.pumpWidget(
      _TestApp(
        child: V2BoardGate(
          authenticator: authenticator,
          sessionRepository: repository,
          onAuthenticated: (session) async {
            authenticatedSession = session;
          },
          child: const Text('application-home'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('application-home'), findsNothing);

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(authenticator.loginEmail, 'user@example.com');
    expect(authenticator.loginPassword, 'secret');
    expect(repository.authData, 'new-token');
    expect(authenticatedSession?.subscribeUrl, 'https://sub.example/profile');
    expect(find.text('application-home'), findsOneWidget);
  });

  testWidgets('restores a saved session before rendering the application', (
    tester,
  ) async {
    final authenticator = _FakeAuthenticator();
    final repository = _FakeSessionRepository()..authData = 'saved-token';

    await tester.pumpWidget(
      _TestApp(
        child: V2BoardGate(
          authenticator: authenticator,
          sessionRepository: repository,
          onAuthenticated: (_) async {},
          child: const Text('application-home'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(authenticator.restoredAuthData, 'saved-token');
    expect(find.text('application-home'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsNothing);
  });

  testWidgets('clears an expired session and returns to login', (tester) async {
    final authenticator = _FakeAuthenticator()
      ..restoreError = const V2BoardException(
        'Session expired',
        kind: V2BoardExceptionKind.unauthorized,
      );
    final repository = _FakeSessionRepository()..authData = 'expired-token';

    await tester.pumpWidget(
      _TestApp(
        child: V2BoardGate(
          authenticator: authenticator,
          sessionRepository: repository,
          onAuthenticated: (_) async {},
          child: const Text('application-home'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.authData, isNull);
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('application-home'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: child,
    );
  }
}

class _FakeAuthenticator implements V2BoardAuthenticator {
  String? loginEmail;
  String? loginPassword;
  String? restoredAuthData;
  Object? loginError;
  Object? restoreError;

  @override
  Future<V2BoardSession> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    loginPassword = password;
    if (loginError case final error?) throw error;
    return const V2BoardSession(
      authData: 'new-token',
      email: 'user@example.com',
      subscribeUrl: 'https://sub.example/profile',
    );
  }

  @override
  Future<V2BoardSession> restore(String authData) async {
    restoredAuthData = authData;
    if (restoreError case final error?) throw error;
    return V2BoardSession(
      authData: authData,
      email: 'user@example.com',
      subscribeUrl: 'https://sub.example/profile',
    );
  }
}

class _FakeSessionRepository implements V2BoardSessionRepository {
  String? authData;

  @override
  Future<void> clearAuthData() async {
    authData = null;
  }

  @override
  Future<String?> readAuthData() async => authData;

  @override
  Future<void> saveAuthData(String authData) async {
    this.authData = authData;
  }
}

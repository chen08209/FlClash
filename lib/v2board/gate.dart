import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

import 'client.dart';
import 'models.dart';
import 'session_store.dart';

typedef V2BoardAuthenticatedCallback =
    Future<void> Function(V2BoardSession session);

class V2BoardGate extends StatefulWidget {
  final V2BoardAuthenticator authenticator;
  final V2BoardSessionRepository sessionRepository;
  final V2BoardAuthenticatedCallback onAuthenticated;
  final Widget child;

  const V2BoardGate({
    super.key,
    required this.authenticator,
    required this.sessionRepository,
    required this.onAuthenticated,
    required this.child,
  });

  @override
  State<V2BoardGate> createState() => _V2BoardGateState();
}

enum _V2BoardGateStage { loading, login, authenticated }

class _V2BoardGateState extends State<V2BoardGate> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _V2BoardGateStage _stage = _V2BoardGateStage.loading;
  bool _submitting = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    final authData = await widget.sessionRepository.readAuthData();
    if (!mounted) return;
    if (authData == null || authData.isEmpty) {
      setState(() => _stage = _V2BoardGateStage.login);
      return;
    }
    try {
      final session = await widget.authenticator.restore(authData);
      await _completeAuthentication(session);
    } on V2BoardException catch (error) {
      if (error.kind == V2BoardExceptionKind.unauthorized) {
        await widget.sessionRepository.clearAuthData();
      }
      _showLogin(error.message);
    } on Object catch (error) {
      _showLogin(error.toString());
    }
  }

  Future<void> _login() async {
    if (_submitting || _formKey.currentState?.validate() != true) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await widget.authenticator.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await widget.sessionRepository.saveAuthData(session.authData);
      await _completeAuthentication(session);
    } on Object catch (error) {
      _showLogin(error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _completeAuthentication(V2BoardSession session) async {
    await widget.onAuthenticated(session);
    if (!mounted) return;
    setState(() {
      _error = null;
      _stage = _V2BoardGateStage.authenticated;
    });
  }

  void _showLogin(String error) {
    if (!mounted) return;
    setState(() {
      _error = error;
      _stage = _V2BoardGateStage.login;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _V2BoardGateStage.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _V2BoardGateStage.login => _buildLogin(context),
      _V2BoardGateStage.authenticated => widget.child,
    };
  }

  Widget _buildLogin(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: context.colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            child: Image.asset(
                              'assets/images/icon.png',
                              width: 64,
                              height: 64,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            appLocalizations.v2boardLoginTitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appLocalizations.v2boardLoginDesc,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_submitting,
                            autofillHints: const [AutofillHints.username],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: appLocalizations.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return appLocalizations.emailRequired;
                              }
                              if (!email.contains('@')) {
                                return appLocalizations.emailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_submitting,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: appLocalizations.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: _submitting
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? appLocalizations.passwordRequired
                                : null,
                          ),
                          if (_error case final error?) ...[
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _submitting ? null : _login,
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(appLocalizations.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

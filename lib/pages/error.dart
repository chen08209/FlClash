import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class InitErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stack;
  final AsyncCallback onClearData;
  final AsyncCallback onExit;

  const InitErrorApp({
    super.key,
    required this.error,
    required this.stack,
    required this.onClearData,
    required this.onExit,
  });

  ThemeData _theme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: seededColorScheme(
        seedColor: const Color(defaultPrimaryColor),
        brightness: brightness,
      ),
    ).withAppShapes.withAppSurfaces;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: InitErrorScreen(
        error: error,
        stack: stack,
        onClearData: onClearData,
        onExit: onExit,
      ),
    );
  }
}

class InitErrorScreen extends StatefulWidget {
  final Object error;
  final StackTrace stack;
  final AsyncCallback onClearData;
  final AsyncCallback onExit;

  const InitErrorScreen({
    super.key,
    required this.error,
    required this.stack,
    required this.onClearData,
    required this.onExit,
  });

  @override
  State<InitErrorScreen> createState() => _InitErrorScreenState();
}

class _InitErrorScreenState extends State<InitErrorScreen> {
  static const _maxContentWidth = 720.0;

  bool _isExiting = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _copyDetails() async {
    final text =
        '=== ERROR ===\n${widget.error}\n\n'
        '=== STACK TRACE ===\n${widget.stack}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    _showSnackBar(context.appLocalizations.copySuccess);
  }

  Future<bool> _confirmClearData() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<bool>(
      context: context,
      child: Builder(
        builder: (context) {
          return CommonDialog(
            title: appLocalizations.clearData,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(appLocalizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
            child: Text(appLocalizations.clearDataAndExitTip),
          );
        },
      ),
    );
    return res == true;
  }

  Future<void> _clearData() async {
    if (!await _confirmClearData() || !mounted) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    setState(() {
      _isExiting = true;
    });
    try {
      await widget.onClearData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isExiting = false;
      });
      _showSnackBar(appLocalizations.clearDataFailed('$error'));
      return;
    }
    await widget.onExit();
  }

  Future<void> _exit() async {
    setState(() {
      _isExiting = true;
    });
    await widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: colorScheme.errorContainer,
                            shape: AppShape.full,
                          ),
                          child: SizedBox.square(
                            dimension: 56,
                            child: Center(
                              child: GlyphIcon(
                                AppGlyphs.warning,
                                size: 28,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          appLocalizations.initFailed,
                          style: AppTextStyle.title2.of(
                            context,
                            emphasized: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appLocalizations.initFailedTip,
                          style: AppTextStyle.subheadline
                              .of(context)
                              .copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 28),
                        _ErrorSection(
                          label: appLocalizations.errorDetails,
                          text: widget.error.toString(),
                          backgroundColor: colorScheme.errorContainer,
                          style: AppTextStyle.subheadline
                              .of(context, emphasized: true)
                              .copyWith(color: colorScheme.onErrorContainer),
                        ),
                        const SizedBox(height: 20),
                        _ErrorSection(
                          label: appLocalizations.stackTrace,
                          text: widget.stack.toString(),
                          backgroundColor: context.raisedSurfaceLevel.colorOf(
                            colorScheme,
                          ),
                          style: AppTextStyle.footnote
                              .of(context)
                              .copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _ErrorActionBar(
              maxWidth: _maxContentWidth,
              children: [
                ElasticButton(
                  child: TextButton.icon(
                    onPressed: _isExiting ? null : _clearData,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    icon: const GlyphIcon(AppGlyphs.broom, size: 18),
                    label: Text(appLocalizations.clearData),
                  ),
                ),
                ElasticButton(
                  child: OutlinedButton.icon(
                    onPressed: _copyDetails,
                    icon: const GlyphIcon(AppGlyphs.copy, size: 18),
                    label: Text(appLocalizations.copy),
                  ),
                ),
                ElasticButton(
                  child: FilledButton(
                    onPressed: _isExiting ? null : _exit,
                    child: Text(appLocalizations.exit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String label;
  final String text;
  final Color backgroundColor;
  final TextStyle? style;

  const _ErrorSection({
    required this.label,
    required this.text,
    required this.backgroundColor,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyle.subheadline.of(context, emphasized: true),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: AppShape.xl,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(text, style: style),
          ),
        ),
      ],
    );
  }
}

class _ErrorActionBar extends StatelessWidget {
  final double maxWidth;
  final List<Widget> children;

  const _ErrorActionBar({required this.maxWidth, required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SurfaceLevel.page.colorOf(context.colorScheme),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                overflowAlignment: OverflowBarAlignment.end,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

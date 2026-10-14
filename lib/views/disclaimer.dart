import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True only after "Agree" and the restatement; any other way out declines.
Future<bool> requestDisclaimerConsent() async {
  return await BaseNavigator.push<bool>(
        rootNavigatorKey.currentContext!,
        const DisclaimerView(requireConsent: true),
      ) ??
      false;
}

class DisclaimerView extends StatelessWidget {
  final bool requireConsent;

  const DisclaimerView({super.key, this.requireConsent = false});

  static const _googlePrivacyUrl = 'https://policies.google.com/privacy';
  static const _firebasePrivacyUrl =
      'https://firebase.google.com/support/privacy';
  static const _maxContentWidth = 720.0;

  List<({String title, String content})> _leadingTerms(AppLocalizations l) => [
    (
      title: l.disclaimerSoftwareTitle,
      content:
          '${l.disclaimerSoftwareContent}\n\n${l.disclaimerNoServiceStatement}',
    ),
    (title: l.disclaimerUsageTitle, content: l.disclaimerUsageContent),
    (
      title: l.disclaimerResponsibilityTitle,
      content: l.disclaimerResponsibilityContent,
    ),
    (
      title: l.disclaimerThirdPartyTitle,
      content: l.disclaimerThirdPartyContent,
    ),
    (title: l.disclaimerWarrantyTitle, content: l.disclaimerWarrantyContent),
    (title: l.disclaimerLiabilityTitle, content: l.disclaimerLiabilityContent),
  ];

  List<({String title, String content})> _trailingTerms(AppLocalizations l) => [
    (title: l.disclaimerLicenseTitle, content: l.disclaimerLicenseContent),
    (title: l.disclaimerChangesTitle, content: l.disclaimerChangesContent),
    (title: l.disclaimerAcceptTitle, content: l.disclaimerAcceptContent),
  ];

  static const _mobileGutter = 16.0;
  static const _desktopGutter = 24.0;
  static const _desktopTopPadding = 48.0;

  ListView _buildBody({
    required EdgeInsets padding,
    required List<Widget> children,
  }) {
    return ListView(
      padding: padding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final terms = _buildTerms(appLocalizations);
    final body = _buildBody(
      padding: const EdgeInsets.symmetric(
        horizontal: _mobileGutter,
      ).copyWith(top: context.contentTopPadding, bottom: 32),
      children: terms,
    );
    if (!requireConsent) {
      return CommonScaffold(title: appLocalizations.disclaimer, body: body);
    }
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(isMobileViewProvider)) {
          return CommonScaffold(
            title: appLocalizations.disclaimer,
            body: _ConsentLayout(
              maxWidth: _maxContentWidth,
              gutter: _mobileGutter,
              compact: true,
              child: body,
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: _ConsentLayout(
              maxWidth: _maxContentWidth,
              gutter: _desktopGutter,
              compact: false,
              child: _buildBody(
                padding: const EdgeInsets.fromLTRB(
                  _desktopGutter,
                  _desktopTopPadding,
                  _desktopGutter,
                  32,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      appLocalizations.disclaimer,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...terms,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTerms(AppLocalizations appLocalizations) {
    final leadingTerms = _leadingTerms(appLocalizations);
    final trailingTerms = _trailingTerms(appLocalizations);
    final privacyIndex = leadingTerms.length + 1;
    return [
      _DisclaimerIntro(text: appLocalizations.disclaimerDesc),
      for (final (index, term) in leadingTerms.indexed)
        _DisclaimerTerm(
          index: index + 1,
          title: term.title,
          content: term.content,
        ),
      _DisclaimerTerm(
        index: privacyIndex,
        title: appLocalizations.disclaimerPrivacyTitle,
        content: appLocalizations.disclaimerPrivacyContent,
        children: [
          _DataServiceCard(
            glyph: AppGlyphs.error,
            title: appLocalizations.disclaimerCrashlyticsTitle,
            content: appLocalizations.disclaimerCrashlyticsContent,
          ),
          _DataServiceCard(
            glyph: AppGlyphs.dataUsage,
            title: appLocalizations.disclaimerAnalyticsTitle,
            content: appLocalizations.disclaimerAnalyticsContent,
          ),
          _TermParagraphs(appLocalizations.disclaimerDataProcessingContent),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PolicyLink(
                label: appLocalizations.disclaimerGooglePrivacy,
                url: _googlePrivacyUrl,
              ),
              _PolicyLink(
                label: appLocalizations.disclaimerFirebasePrivacy,
                url: _firebasePrivacyUrl,
              ),
            ],
          ),
        ],
      ),
      for (final (index, term) in trailingTerms.indexed)
        _DisclaimerTerm(
          index: privacyIndex + index + 1,
          title: term.title,
          content: term.content,
        ),
    ];
  }
}

class _DisclaimerIntro extends StatelessWidget {
  final String text;

  const _DisclaimerIntro({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(
              AppGlyphs.gavel,
              size: 28,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerTerm extends StatelessWidget {
  final int index;
  final String title;
  final String content;
  final List<Widget> children;

  const _DisclaimerTerm({
    required this.index,
    required this.title,
    required this.content,
    this.children = const [],
  });

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: AppShape.full,
                ),
                child: SizedBox.square(
                  dimension: _badgeSize,
                  child: Center(
                    child: Text(
                      '$index',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TermParagraphs(content),
          for (final child in children)
            Padding(padding: const EdgeInsets.only(top: 12), child: child),
        ],
      ),
    );
  }
}

class _TermParagraphs extends StatelessWidget {
  final String text;

  const _TermParagraphs(this.text);

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      height: 1.6,
    );
    final paragraphs = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, paragraph) in paragraphs.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
            child: Text(paragraph, style: style),
          ),
      ],
    );
  }
}

class _DataServiceCard extends StatelessWidget {
  final Glyph glyph;
  final String title;
  final String content;

  const _DataServiceCard({
    required this.glyph,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GlyphIcon(glyph, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.tertiaryContainer,
                    shape: AppShape.full,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    child: Text(
                      context.appLocalizations.disclaimerAndroidOnly,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TermParagraphs(content),
          ],
        ),
      ),
    );
  }
}

class _PolicyLink extends StatelessWidget {
  final String label;
  final String url;

  const _PolicyLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return ElasticButton(
      child: TextButton.icon(
        onPressed: () {
          dialogs.openUrl(url);
        },
        icon: const GlyphIcon(AppGlyphs.openExternal, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _ConsentLayout extends StatefulWidget {
  final double maxWidth;
  final double gutter;
  final bool compact;
  final Widget child;

  const _ConsentLayout({
    required this.maxWidth,
    required this.gutter,
    required this.compact,
    required this.child,
  });

  @override
  State<_ConsentLayout> createState() => _ConsentLayoutState();
}

class _ConsentLayoutState extends State<_ConsentLayout> {
  static const _endTolerance = 1.0;

  bool _readToEnd = false;

  bool _handleNotification(Notification notification) {
    if (_readToEnd) {
      return false;
    }
    final metrics = switch (notification) {
      ScrollNotification(depth: 0, :final metrics) ||
      ScrollMetricsNotification(depth: 0, :final metrics) => metrics,
      _ => null,
    };
    if (metrics != null && metrics.extentAfter <= _endTolerance) {
      setState(() {
        _readToEnd = true;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<Notification>(
            onNotification: _handleNotification,
            child: widget.child,
          ),
        ),
        _ConsentBar(
          maxWidth: widget.maxWidth,
          gutter: widget.gutter,
          compact: widget.compact,
          readToEnd: _readToEnd,
        ),
      ],
    );
  }
}

class _ConsentBar extends StatelessWidget {
  final double maxWidth;
  final double gutter;
  final bool compact;
  final bool readToEnd;

  const _ConsentBar({
    required this.maxWidth,
    required this.gutter,
    required this.compact,
    required this.readToEnd,
  });

  Widget _buildExitButton(BuildContext context) {
    return ElasticButton(
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(context.appLocalizations.exit),
      ),
    );
  }

  Future<void> _handleAgree(BuildContext context) async {
    final restated = await dialogs.showCommonDialog<bool>(
      context: context,
      dismissible: false,
      child: const _RestateDialog(),
    );
    if (restated == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildAgreeButton(BuildContext context, {required String label}) {
    return ElasticButton(
      child: FilledButton(
        onPressed: readToEnd ? () => _handleAgree(context) : null,
        child: Text(label),
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        Expanded(child: _buildExitButton(context)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAgreeButton(
            context,
            label: readToEnd
                ? appLocalizations.agree
                : appLocalizations.disclaimerReadToEnd,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        Expanded(
          child: readToEnd
              ? const SizedBox.shrink()
              : Text(
                  appLocalizations.disclaimerReadToEnd,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        _buildExitButton(context),
        const SizedBox(width: 12),
        _buildAgreeButton(context, label: appLocalizations.agree),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 12),
              child: compact
                  ? _buildCompactActions(context)
                  : _buildActions(context),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Restatement {
  partial,
  diverged,
  complete;

  static _Restatement of(TextEditingValue value, String statement) {
    if (value.text.trim() == statement) {
      return complete;
    }
    // Pinyin or kana still being composed is not part of the restatement yet.
    final composing = value.composing;
    final committed = value.isComposingRangeValid
        ? composing.textBefore(value.text) + composing.textAfter(value.text)
        : value.text;
    return statement.startsWith(committed.trimLeft()) ? partial : diverged;
  }
}

class _RestateDialog extends StatefulWidget {
  const _RestateDialog();

  @override
  State<_RestateDialog> createState() => _RestateDialogState();
}

class _RestateDialogState extends State<_RestateDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatement(String statement) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: AppShape.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SelectableText(
          statement,
          style: context.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final statement = appLocalizations.disclaimerNoServiceStatement;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final restatement = _Restatement.of(value, statement);
        return CommonDialog(
          title: appLocalizations.disclaimerRestateTitle,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(appLocalizations.cancel),
            ),
            TextButton(
              onPressed: restatement == _Restatement.complete
                  ? () {
                      Navigator.of(context).pop(true);
                    }
                  : null,
              child: Text(appLocalizations.confirm),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appLocalizations.disclaimerRestateTip,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatement(statement),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: appLocalizations.disclaimerRestateHint,
                  errorText: restatement == _Restatement.diverged
                      ? appLocalizations.disclaimerRestateMismatch
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

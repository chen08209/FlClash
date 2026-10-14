import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class DisclaimerView extends StatelessWidget {
  const DisclaimerView({super.key});

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
    return CommonScaffold(title: appLocalizations.disclaimer, body: body);
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

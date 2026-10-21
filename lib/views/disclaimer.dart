import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
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

  static const _maxContentWidth = 720.0;

  List<({String title, String content})> _terms(AppLocalizations l) => [
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
    (title: l.disclaimerPrivacyTitle, content: l.disclaimerPrivacyContent),
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
      padding: const EdgeInsets.symmetric(horizontal: _mobileGutter).copyWith(
        top: context.contentTopPadding,
        // Below the terms the consent bar takes the system bar itself.
        bottom: 32 + (requireConsent ? 0 : context.bottomInset),
      ),
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
                      style: AppTextStyle.title2.of(context, emphasized: true),
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
    return [
      _DisclaimerIntro(text: appLocalizations.disclaimerDesc),
      for (final (index, term) in _terms(appLocalizations).indexed)
        _DisclaimerTerm(
          index: index + 1,
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
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(AppGlyphs.gavel, size: 28, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant, height: 1.6),
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

  const _DisclaimerTerm({
    required this.index,
    required this.title,
    required this.content,
  });

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(colorScheme),
                  shape: AppShape.full,
                ),
                child: SizedBox.square(
                  dimension: _badgeSize,
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTextStyle.caption1
                          .of(context, emphasized: true)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: AppTextStyle.headline.of(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TermParagraphs(content),
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
    final style = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant, height: 1.6);
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

class _ConsentLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        _ConsentBar(maxWidth: maxWidth, gutter: gutter, compact: compact),
      ],
    );
  }
}

class _ConsentBar extends StatelessWidget {
  final double maxWidth;
  final double gutter;
  final bool compact;

  const _ConsentBar({
    required this.maxWidth,
    required this.gutter,
    required this.compact,
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

  Widget _buildAgreeButton(BuildContext context) {
    return ElasticButton(
      child: FilledButton(
        onPressed: () => _handleAgree(context),
        child: Text(context.appLocalizations.agree),
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildExitButton(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildAgreeButton(context)),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        _buildExitButton(context),
        const SizedBox(width: 12),
        _buildAgreeButton(context),
      ],
    );
  }

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
  bool _acknowledged = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatement(String statement) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
        shape: AppShape.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SelectableText(
          statement,
          style: AppTextStyle.subheadline.of(context).copyWith(height: 1.6),
        ),
      ),
    );
  }

  Widget _buildDialog({
    required String title,
    required String tip,
    required String statement,
    required bool canConfirm,
    required Widget confirmation,
  }) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: title,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: canConfirm
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
            tip,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _buildStatement(statement),
          const SizedBox(height: 16),
          confirmation,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final statement = appLocalizations.disclaimerNoServiceStatement;
    // Typing the statement out takes hundreds of presses on a remote.
    if (RemoteFocusAdapter.isEnabledOf(context)) {
      return _buildDialog(
        title: appLocalizations.disclaimerAcknowledgeTitle,
        tip: appLocalizations.disclaimerAcknowledgeTip,
        statement: statement,
        canConfirm: _acknowledged,
        confirmation: generateGroup([
          ListItem.checkbox(
            title: Text(appLocalizations.disclaimerAcknowledgeLabel),
            value: _acknowledged,
            onChanged: (value) {
              setState(() => _acknowledged = value ?? false);
            },
          ),
        ]),
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final restatement = _Restatement.of(value, statement);
        return _buildDialog(
          title: appLocalizations.disclaimerRestateTitle,
          tip: appLocalizations.disclaimerRestateTip,
          statement: statement,
          canConfirm: restatement == _Restatement.complete,
          confirmation: FilledInputTheme(
            borderRadius: AppRadius.lg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: TextField(
              controller: _controller,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(
                hintText: appLocalizations.disclaimerRestateHint,
                errorText: restatement == _Restatement.diverged
                    ? appLocalizations.disclaimerRestateMismatch
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

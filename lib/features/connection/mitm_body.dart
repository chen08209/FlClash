import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/widgets.dart';

const _imageMaxHeight = 240.0;
const _hexMaxPerLine = 16;
const _hexPerLineStep = 4;
const _hexLineGap = 4.0;
const _codeBlockVerticalPadding = 12.0;

class MitmBodySection extends StatelessWidget {
  final String title;
  final MitmBodyContent content;

  /// The body's size as it went over the wire, before any decoding.
  final int size;
  final String contentType;
  final bool atTop;
  final bool last;

  const MitmBodySection({
    super.key,
    required this.title,
    required this.content,
    required this.size,
    this.contentType = '',
    this.atTop = false,
    this.last = false,
  });

  void _open(BuildContext context) {
    BaseNavigator.push(
      context,
      EditorPage(
        title: title,
        content: content.text,
        language: content.language,
      ),
    );
  }

  String? _footer(AppLocalizations appLocalizations) {
    final lines = [
      if (content.encoding.isNotEmpty)
        appLocalizations.httpBodyUndecoded(content.encoding)
      else if (content.truncated)
        appLocalizations.httpBodyTruncated,
      if (content.format == MitmBodyFormat.protobuf)
        appLocalizations.httpBodyProtobufGuess,
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  String _typeLabel(AppLocalizations appLocalizations) {
    if (content.format == MitmBodyFormat.protobuf) {
      return 'Protobuf';
    }
    return switch (content.kind) {
      MitmBodyKind.image => appLocalizations.httpBodyImage,
      MitmBodyKind.binary => appLocalizations.binaryData,
      MitmBodyKind.text => switch (content.language) {
        Language.json => 'JSON',
        Language.javaScript => 'JavaScript',
        Language.xml when contentType.toLowerCase().contains('html') => 'HTML',
        Language.xml => 'XML',
        _ => appLocalizations.httpBodyText,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (content.bytes.isEmpty) {
      return generateSection(
        title: title,
        atTop: atTop,
        items: [ListItem(title: Text(appLocalizations.httpBodyNotKept))],
      );
    }
    const chevron = GlyphIcon(AppGlyphs.chevronForward);
    final keptSize = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          content.bytes.length.traffic.show,
          style: context.listValueStyle.toTabular,
        ),
        chevron,
      ],
    );
    final hex = _MitmHexView(title: title, content: content);
    final footer = _footer(appLocalizations);
    final items = switch (content.kind) {
      MitmBodyKind.text => [
        DecorationListItem(
          onPressed: () => _open(context),
          minVerticalPadding: _codeBlockVerticalPadding,
          title: Text(
            content.preview,
            style: AppTextStyle.footnote.of(context).toJetBrainsMono,
          ),
        ),
        if (content.isCut)
          DecorationListItem(
            onPressed: () => _open(context),
            contentPadding: ListItem.chevronPaddingOf(context),
            title: Text(appLocalizations.viewAll),
            trailing: chevron,
          ),
        ListItem.open(
          title: Text(appLocalizations.hex),
          trailing: keptSize,
          widget: hex,
        ),
      ],
      MitmBodyKind.image => [
        DecorationListItem(
          title: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _imageMaxHeight),
              child: Image.memory(
                content.bytes,
                cacheHeight:
                    (_imageMaxHeight * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                fit: BoxFit.contain,
                errorBuilder: (context, _, _) =>
                    Text(appLocalizations.binaryData),
              ),
            ),
          ),
        ),
        ListItem.open(
          title: Text(appLocalizations.hex),
          trailing: keptSize,
          widget: hex,
        ),
      ],
      MitmBodyKind.binary => [
        ListItem.open(
          title: Text(appLocalizations.binaryData),
          trailing: keptSize,
          widget: hex,
        ),
      ],
    };
    return Column(
      children: [
        ListHeader(
          title: title,
          caption: '${size.traffic.show} · ${_typeLabel(appLocalizations)}',
          atTop: atTop,
        ),
        generateGroup(items),
        if (footer != null) ListFooter(text: footer, last: last),
      ],
    );
  }
}

/// Every byte of a body. Lines are formatted as they scroll in, at as many
/// bytes a line, in fours, as the width holds.
class _MitmHexView extends StatelessWidget {
  final String title;
  final MitmBodyContent content;

  const _MitmHexView({required this.title, required this.content});

  Future<void> _copyBase64(BuildContext context) async {
    await dialogs.copy(await compute(base64Encode, content.bytes));
  }

  int _perLine(double width, double charWidth) {
    final length = content.bytes.length;
    var perLine = _hexMaxPerLine;
    while (perLine > _hexPerLineStep &&
        mitmHexLineLength(length, perLine) * charWidth > width) {
      perLine -= _hexPerLineStep;
    }
    return perLine;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final style = AppTextStyle.footnote.of(context).toJetBrainsMono;
    return Scaffold(
      title: title,
      menuItems: [
        PopupMenuItem(
          glyph: AppGlyphs.copy,
          label: appLocalizations.copyAsBase64,
          onPressed: () => _copyBase64(context),
        ),
      ],
      body: WidthBuilder(
        builder: (context, width) {
          final painter = TextPainter(
            text: TextSpan(text: '0', style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final charWidth = painter.width;
          final lineHeight = painter.height;
          painter.dispose();
          final bytes = content.bytes;
          final margin = context.listInsets.margin;
          final perLine = _perLine(width - margin * 2, charWidth);
          return ArrivalCacheExtentBuilder(
            builder: (cacheExtent) => CustomScrollView(
              scrollCacheExtent: cacheExtent,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: margin).copyWith(
                    top: context.contentTopPadding,
                    bottom: 16 + context.bottomInset,
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      if (content.truncated)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              appLocalizations.httpBodyTruncated,
                              style: AppTextStyle.footnote
                                  .of(context)
                                  .copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      SliverPrismList(
                        itemCount: (bytes.length + perLine - 1) ~/ perLine,
                        itemExtent: lineHeight + _hexLineGap,
                        addRepaintBoundaries: false,
                        itemBuilder: (_, index) => Text(
                          mitmHexLine(bytes, index * perLine, perLine),
                          style: style,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

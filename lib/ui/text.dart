import 'package:emoji_regex/emoji_regex.dart';
import 'package:fl_clash/ui/measure.dart';
import 'package:fl_clash/ui/text_style.dart';
import 'package:material_ui/material_ui.dart';

class TooltipText extends StatelessWidget {
  final Text text;

  const TooltipText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isOverflow = MeasureScope.of(
          context,
        ).computeTextIsOverflow(text, maxWidth: maxWidth);
        if (isOverflow) {
          return Tooltip(
            triggerMode: TooltipTriggerMode.longPress,
            preferBelow: false,
            message: text.data,
            child: text,
          );
        }
        return text;
      },
    );
  }
}

class TooltipLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const TooltipLabel(this.text, {super.key, this.style, this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    return TooltipText(
      text: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
    );
  }
}

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const EmojiText(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.style,
  });

  /// The spans [EmojiText] lays [text] out in, emoji in their own font.
  static TextSpan spanOf(String text, TextStyle? style) {
    final List<TextSpan> spans = [];
    final matches = emojiRegex().allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: (style ?? const TextStyle()).copyWith(
            fontFamily: FontFamily.twEmoji.value,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      spanOf(text, style),
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

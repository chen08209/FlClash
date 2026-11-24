import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// As `text [label] [!error] [+success]`, without a part that has no room.
String recordLineText(Element line) {
  final widget = line.widget as RecordLabelLine;
  final shown = <bool>[];
  line.renderObject!.visitChildren(
    (part) => shown.add(recordLinePartShown(part)),
  );
  final parts = [
    if (widget.text.isNotEmpty) widget.text,
    for (final label in widget.labels.whereType<RecordLabel>())
      switch (label.tone) {
        RecordTone.error => '[!${label.label}]',
        RecordTone.success => '[+${label.label}]',
        RecordTone.warning => '[?${label.label}]',
        RecordTone.neutral => '[${label.label}]',
      },
  ];
  return [
    for (final (index, part) in parts.indexed)
      if (index >= shown.length || shown[index]) part,
  ].join(' ');
}

Finder findRecordLine(String text) => find.byElementPredicate(
  (element) =>
      element.widget is RecordLabelLine && recordLineText(element) == text,
  description: 'record line "$text"',
);

List<String> recordLinesIn(WidgetTester tester, [Finder? of]) => [
  for (final line
      in (of == null
              ? find.byType(RecordLabelLine)
              : find.descendant(of: of, matching: find.byType(RecordLabelLine)))
          .evaluate())
    recordLineText(line),
];

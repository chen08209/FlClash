import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A table's column header, apart from a filter chip of the same name.
Finder headerText(String label) => find.descendant(
  of: find.byType(RecordHeaderCell),
  matching: find.text(label),
);

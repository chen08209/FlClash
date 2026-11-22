import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/record_minute_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _Record {
  final String id;

  _Record(this.id);
}

class _Row extends StatefulWidget {
  final String id;
  final List<String> created;

  const _Row({required this.id, required this.created});

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  @override
  void initState() {
    super.initState();
    widget.created.add(widget.id);
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 40, child: Text(widget.id));
}

void main() {
  _minuteGroups();

  for (final (name, keyOf) in <(String, Key Function(_Record))>[
    ('a value key', (record) => ValueKey(record.id)),
    ('an object key', ObjectKey.new),
  ]) {
    testWidgets('rows keyed by $name keep their state as the oldest leaves', (
      tester,
    ) async {
      final created = <String>[];
      final older = [for (var i = 0; i < 4; i++) _Record('old $i')];
      Widget list(List<RecordGroup<_Record>> groups) => HostApp(
        home: RecordMinuteList<_Record>(
          rows: GroupedMinuteRows(groups, keyOf),
          itemBuilder: (record) => _Row(id: record.id, created: created),
        ),
      );

      await tester.pumpWidget(list([RecordGroup(0, '09:00', older)]));
      expect(created, hasLength(older.length));

      created.clear();
      await tester.pumpWidget(
        list([
          RecordGroup(1, '09:01', [_Record('new')]),
          RecordGroup(0, '09:00', older.sublist(0, older.length - 1)),
        ]),
      );

      expect(created, ['new']);
    });
  }
}

void _minuteGroups() {
  test('minutes run newest first whatever order their records came in', () {
    final records = [
      (DateTime.utc(2026, 9, 18, 10, 2), 'later'),
      (DateTime.utc(2026, 9, 18, 10, 1), 'earlier, in last'),
    ];

    final groups = recordMinuteGroups(
      records,
      (record) => record.$1,
      DateTime.utc(2026, 9, 18, 10, 5),
    );

    expect(
      [
        for (final group in groups)
          [for (final record in group.items) record.$2],
      ],
      [
        ['later'],
        ['earlier, in last'],
      ],
    );
  });

  test('two minutes a clock set back shows alike keep a header each', () {
    final times = [
      DateTime.utc(2026, 11, 1, 5, 30),
      DateTime.utc(2026, 11, 1, 6, 30),
    ];
    final rows = GroupedMinuteRows(
      recordMinuteGroups(times, (time) => time, times.last),
      ObjectKey.new,
    );

    final headers = [
      for (var index = 0; index < rows.length; index++)
        if (rows.rowAt(index) case final MinuteHeader<DateTime> header)
          (index, header),
    ];

    expect(headers, hasLength(2));
    for (final (index, header) in headers) {
      expect(rows.indexOfKey(header.key), index);
    }
  });
}

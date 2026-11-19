import 'package:fl_clash/features/connection/connection_filters.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _connection(int id, {bool open = true}) => TrackerInfo(
  id: id,
  start: DateTime.utc(2026, 11, 22),
  metadata: const Metadata(network: 'tcp', process: 'curl'),
  chains: const ['Proxy'],
  rule: 'MATCH',
  rulePayload: '',
  closedAt: open ? null : DateTime.utc(2026, 11, 22, 0, 1),
);

void main() {
  test('offering connections counts their statuses, tells only of a count '
      'that moved, and builds no facet options a condition page never '
      'reads', () {
    final controller = connectionFilters();
    addTearDown(controller.dispose);
    var told = 0;
    controller.counted.addListener(() => told++);

    controller.offer([_connection(1), _connection(2, open: false)]);
    expect(controller.countOf(ConnectionStatus.all), 2);
    expect(controller.countOf(ConnectionStatus.active), 1);
    expect(told, 1);
    expect(controller.options.value, isEmpty);

    controller.offer([_connection(1), _connection(3, open: false)]);
    expect(told, 1);
    controller.offer([_connection(1)]);
    expect(controller.countOf(ConnectionStatus.all), 1);
    expect(told, 2);
  });
}

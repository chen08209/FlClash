import 'package:fl_clash/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

StateChangedEvent _selected(
  int seq,
  String group,
  String proxy, {
  ChangeOrigin origin = ChangeOrigin.controller,
}) => StateChangedEvent(
  seq: seq,
  origin: origin,
  change: SelectedChange(group: group, proxy: proxy),
);

StateChangedEvent _mode(
  int seq,
  String mode, {
  ChangeOrigin origin = ChangeOrigin.controller,
}) => StateChangedEvent(
  seq: seq,
  origin: origin,
  change: GeneralChange(mode: mode),
);

GeneralStateDto _state(
  int seq, {
  Map<String, String> selections = const {},
  String mode = 'rule',
}) => GeneralStateDto(
  seq: seq,
  general: GeneralChange(mode: mode),
  selections: selections,
);

List<String?> _modes(List<StateWrite> writes) => [
  for (final write in writes)
    if (write case GeneralWrite(:final change)) change.mode,
];

List<SelectionWrite> _picks(List<StateWrite> writes) =>
    writes.whereType<SelectionWrite>().toList();

CoreStateSync _settled(int seq) {
  final sync = CoreStateSync();
  sync.settle(sync.resync(), _state(seq));
  return sync;
}

void main() {
  test('events before the baseline answers wait for it and are dropped at '
      'or below its seq', () {
    final sync = CoreStateSync();
    final generation = sync.resync();
    expect(sync.take(_selected(3, 'G', 'old')), isEmpty);
    expect(sync.take(_selected(5, 'G', 'new')), isEmpty);
    final writes = sync.settle(
      generation,
      _state(4, selections: {'G': 'base'}),
    );
    expect(_picks(writes), const [
      SelectionWrite('G', 'base'),
      SelectionWrite('G', 'new'),
    ]);
  });

  test('a baseline a newer one replaced writes nothing', () {
    final sync = CoreStateSync();
    final stale = sync.resync();
    final current = sync.resync();
    expect(sync.settle(stale, _state(9, selections: {'G': 'a'})), isEmpty);
    expect(_picks(sync.settle(current, _state(2, selections: {'G': 'b'}))), [
      const SelectionWrite('G', 'b'),
    ]);
  });

  test('the host\'s own changes only move the seq on', () {
    final sync = _settled(1);
    expect(
      sync.take(_selected(2, 'G', 'mine', origin: ChangeOrigin.host)),
      isEmpty,
    );
    expect(sync.take(_mode(3, 'global', origin: ChangeOrigin.host)), isEmpty);
    expect(sync.take(_selected(2, 'G', 'late')), isEmpty);
  });

  test('a dashboard pick and a pick the Core drops are written back', () {
    final sync = _settled(1);
    expect(sync.take(_selected(2, 'G', 'HK')), [
      const SelectionWrite('G', 'HK'),
    ]);
    expect(sync.take(_selected(3, 'F', '', origin: ChangeOrigin.core)), [
      const SelectionWrite('F', ''),
    ]);
    expect(_modes(sync.take(_mode(4, 'direct'))), ['direct']);
  });

  test('a dashboard change older than the app\'s own answered one is '
      'dropped', () {
    final sync = _settled(1);
    sync.selectStarted('G');
    sync.selectEnded('G', 5);
    expect(sync.take(_selected(4, 'G', 'dashboard')), isEmpty);
    expect(sync.take(_selected(6, 'G', 'later')), [
      const SelectionWrite('G', 'later'),
    ]);

    sync.patchScheduled();
    sync.patched(sync.patchStarted(), 8);
    expect(sync.take(_mode(7, 'global')), isEmpty);
    expect(_modes(sync.take(_mode(9, 'global'))), ['global']);
  });

  test('a dashboard pick that comes while the app\'s own pick is unanswered '
      'waits for the answer, which decides whether it stands', () {
    final sync = _settled(1);
    final held = <StateWrite>[];
    sync.onHeldPicks = held.addAll;

    sync.selectStarted('G');
    expect(sync.take(_selected(2, 'G', 'dashboard')), isEmpty);
    sync.selectEnded('G', 3);
    expect(held, isEmpty);

    sync.selectStarted('G');
    expect(sync.take(_selected(4, 'G', 'dashboard')), isEmpty);
    sync.selectEnded('G', null);
    expect(held, const [SelectionWrite('G', 'dashboard')]);

    held.clear();
    sync.selectStarted('G');
    sync.selectStarted('G');
    expect(sync.take(_selected(5, 'G', 'later')), isEmpty);
    sync.selectEnded('G', 6);
    expect(held, isEmpty);
    sync.selectEnded('G', 7);
    expect(held, isEmpty);
    expect(sync.take(_selected(8, 'H', 'other')), const [
      SelectionWrite('H', 'other'),
    ]);
  });

  test('picks reported while the app applies a config are dropped, and the '
      'apply ending asks for a new baseline', () {
    final sync = _settled(1);
    var resyncs = 0;
    sync.onApplied = () => resyncs++;
    sync.applyStarted();
    expect(sync.take(_selected(2, 'G', 'old-profile')), isEmpty);
    expect(_modes(sync.take(_mode(3, 'global'))), ['global']);
    sync.applyEnded(7);
    expect(resyncs, 1);
    expect(sync.profileId, 7);
    expect(sync.take(_selected(4, 'G', 'HK')), [
      const SelectionWrite('G', 'HK'),
    ]);
  });

  test('a failed apply keeps the profile the Core still runs', () {
    final sync = _settled(1);
    sync.applyStarted();
    sync.applyEnded(3);
    sync.applyStarted();
    sync.applyEnded(null);
    expect(sync.profileId, 3);
  });

  test('a baseline taken during an apply leaves the picks alone', () {
    final sync = CoreStateSync();
    sync.applyStarted();
    final writes = sync.settle(
      sync.resync(),
      _state(2, selections: {'G': 'a'}),
    );
    expect(_picks(writes), isEmpty);
    expect(_modes(writes), ['rule']);
  });

  test('a baseline does not undo a pick or setting the app has in flight', () {
    final sync = CoreStateSync();
    sync.selectStarted('G');
    sync.patchScheduled();
    final generation = sync.resync();
    final writes = sync.settle(
      generation,
      _state(3, selections: {'G': 'old', 'H': 'kept'}),
    );
    expect(_picks(writes), const [SelectionWrite('H', 'kept')]);
    expect(_modes(writes), isEmpty);
  });

  test('a baseline read before the app\'s answered change leaves it alone', () {
    final sync = CoreStateSync();
    final generation = sync.resync();
    sync.selectStarted('G');
    sync.selectEnded('G', 6);
    sync.patchScheduled();
    sync.patched(sync.patchStarted(), 7);
    final writes = sync.settle(generation, _state(5, selections: {'G': 'old'}));
    expect(writes, isEmpty);
  });

  test('a restarted Core numbers its changes from the start again', () {
    final sync = _settled(40);
    sync.selectStarted('G');
    sync.selectEnded('G', 41);
    sync.reset();
    expect(_picks(sync.settle(sync.resync(), _state(0))), isEmpty);
    expect(sync.take(_selected(1, 'G', 'HK')), [
      const SelectionWrite('G', 'HK'),
    ]);
  });

  test('a failed patch keeps the app\'s settings until a later patch '
      'answers or the Core restarts', () {
    final sync = CoreStateSync();
    sync.patchScheduled();
    sync.patchStarted();
    expect(_modes(sync.settle(sync.resync(), _state(1))), isEmpty);

    sync.patchScheduled();
    sync.patched(sync.patchStarted(), 2);
    expect(_modes(sync.settle(sync.resync(), _state(3))), ['rule']);

    sync.patchScheduled();
    sync.patchStarted();
    sync.reset();
    expect(_modes(sync.settle(sync.resync(), _state(0))), ['rule']);
  });
}

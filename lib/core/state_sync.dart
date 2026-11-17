import 'package:fl_clash/core/api/dto.dart';

sealed class StateWrite {
  const StateWrite();
}

final class SelectionWrite extends StateWrite {
  final String group;
  final String proxy;

  const SelectionWrite(this.group, this.proxy);

  @override
  bool operator ==(Object other) =>
      other is SelectionWrite && other.group == group && other.proxy == proxy;

  @override
  int get hashCode => Object.hash(group, proxy);

  @override
  String toString() => 'SelectionWrite($group, $proxy)';
}

final class GeneralWrite extends StateWrite {
  final GeneralChange change;

  const GeneralWrite(this.change);
}

/// Orders `stateChanged` against a `config.general` baseline and the app's
/// own changes by `seq`, and answers what the app writes back.
class CoreStateSync {
  int? _seen;
  int _generation = 0;
  final _held = <StateChangedEvent>[];
  final _ownSelects = <String, int>{};
  final _selecting = <String, int>{};
  final _heldPicks = <String, ({int seq, String proxy})>{};
  int _ownPatch = -1;
  int _patchWanted = 0;
  int _patchDone = 0;
  int _applying = 0;
  int? _profileId;

  void Function()? onApplied;

  void Function(List<StateWrite> writes)? onHeldPicks;

  /// Picks reported meanwhile may belong to the config being replaced.
  bool get applying => _applying > 0;

  /// The profile the Core last applied, which a pick it reports belongs to.
  int? get profileId => _profileId;

  void reset() {
    _seen = null;
    _generation++;
    _held.clear();
    _ownSelects.clear();
    _selecting.clear();
    _heldPicks.clear();
    _ownPatch = -1;
    _patchDone = _patchWanted;
    _profileId = null;
  }

  int resync() {
    _seen = null;
    _held.clear();
    _heldPicks.clear();
    return ++_generation;
  }

  /// A pick the app has and the Core lacks is kept: it may name a node of a
  /// provider that has not loaded yet.
  List<StateWrite> settle(int generation, GeneralStateDto state) {
    if (generation != _generation) {
      return const [];
    }
    _seen = state.seq;
    final writes = <StateWrite>[];
    if (!applying) {
      for (final MapEntry(key: group, value: proxy)
          in state.selections.entries) {
        if (!_selecting.containsKey(group) &&
            (_ownSelects[group] ?? -1) <= state.seq) {
          writes.add(SelectionWrite(group, proxy));
        }
      }
    }
    if (_patchDone >= _patchWanted && _ownPatch <= state.seq) {
      writes.add(GeneralWrite(state.general));
    }
    final held = List.of(_held);
    _held.clear();
    for (final event in held) {
      writes.addAll(take(event));
    }
    return writes;
  }

  List<StateWrite> take(StateChangedEvent event) {
    final seen = _seen;
    if (seen == null) {
      _held.add(event);
      return const [];
    }
    if (event.seq <= seen) {
      return const [];
    }
    _seen = event.seq;
    if (event.origin == ChangeOrigin.host) {
      return const [];
    }
    if (event.change case SelectedChange(
      :final group,
      :final proxy,
    ) when _selecting.containsKey(group)) {
      _heldPicks[group] = (seq: event.seq, proxy: proxy);
      return const [];
    }
    return switch (event.change) {
      SelectedChange(:final group, :final proxy)
          when _picks(group, event.seq) =>
        [SelectionWrite(group, proxy)],
      final GeneralChange change when _ownPatch < event.seq => [
        GeneralWrite(change),
      ],
      _ => const [],
    };
  }

  void selectStarted(String group) {
    _selecting.update(group, (count) => count + 1, ifAbsent: () => 1);
  }

  bool _picks(String group, int seq) =>
      !applying && (_ownSelects[group] ?? -1) < seq;

  /// Call after the app has put its own record of the pick back on failure.
  void selectEnded(String group, int? seq) {
    final count = (_selecting[group] ?? 1) - 1;
    if (count > 0) {
      _selecting[group] = count;
    } else {
      _selecting.remove(group);
    }
    if (seq != null && seq > (_ownSelects[group] ?? -1)) {
      _ownSelects[group] = seq;
    }
    if (count > 0) {
      return;
    }
    if (_heldPicks.remove(group) case (
      seq: final heldSeq,
      :final proxy,
    ) when _picks(group, heldSeq)) {
      onHeldPicks?.call([SelectionWrite(group, proxy)]);
    }
  }

  void patchScheduled() => _patchWanted++;

  int patchStarted() => _patchWanted;

  /// A host patch carries every setting a dashboard can change, so any
  /// earlier change of them is overridden by it.
  void patched(int token, int seq) {
    if (token > _patchDone) {
      _patchDone = token;
    }
    if (seq > _ownPatch) {
      _ownPatch = seq;
    }
  }

  void applyStarted() => _applying++;

  void applyEnded(int? appliedProfileId) {
    if (appliedProfileId != null) {
      _profileId = appliedProfileId;
    }
    if (_applying > 0 && --_applying == 0) {
      onApplied?.call();
    }
  }
}

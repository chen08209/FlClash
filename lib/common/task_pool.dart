import 'dart:async';
import 'dart:collection';

class TaskPool {
  TaskPool(this.concurrency) : assert(concurrency > 0);

  final int concurrency;

  final Queue<Completer<void>> _waiting = Queue();
  int _active = 0;

  int get activeCount => _active;

  int get pendingCount => _waiting.length;

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= concurrency || _waiting.isNotEmpty) {
      final waiter = Completer<void>();
      _waiting.add(waiter);
      await waiter.future;
    } else {
      _active++;
    }
    try {
      return await task();
    } finally {
      if (_waiting.isNotEmpty) {
        _waiting.removeFirst().complete();
      } else {
        _active--;
      }
    }
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _stateManagement = [
  'flutter_riverpod',
  'hooks_riverpod',
  'riverpod',
  'riverpod_annotation',
];

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

String _resolve(String uri, String from) {
  if (uri.startsWith('package:fl_clash/')) {
    return 'lib/${uri.substring('package:fl_clash/'.length)}';
  }
  if (uri.startsWith('dart:') || uri.startsWith('package:')) return uri;
  return p.normalize(p.join(p.dirname(from), uri));
}

bool _isStateManagement(String uri) =>
    _stateManagement.any((package) => uri.startsWith('package:$package/'));

bool _staysInUi(String path) =>
    !path.startsWith('lib/') ||
    path.startsWith('lib/ui/') ||
    (path.startsWith('lib/common/') && path != 'lib/common/common.dart');

/// The chain of files from [root] to the first one outside the UI layer, or
/// null when every file [root] reaches stays in it.
List<String>? _escape(String root) {
  final parents = <String, String>{};
  final queue = [root];
  final seen = {root};
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final file = File(current);
    if (!file.existsSync()) continue;
    for (final match in _directive.allMatches(file.readAsStringSync())) {
      final next = _resolve(match.group(1)!, current);
      if (!seen.add(next)) continue;
      parents[next] = current;
      if (!_staysInUi(next) || _isStateManagement(next)) {
        final chain = [next];
        while (parents.containsKey(chain.first)) {
          chain.insert(0, parents[chain.first]!);
        }
        return chain;
      }
      if (next.startsWith('lib/')) queue.add(next);
    }
  }
  return null;
}

void main() {
  test('lib/ui reaches no app layer and no state management', () {
    final directory = Directory('lib/ui');
    if (!directory.existsSync()) {
      fail('lib/ui no longer exists; update this test.');
    }
    final offenders = <String>[];
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final chain = _escape(p.relative(entity.path));
      if (chain != null) offenders.add(chain.join(' -> '));
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'lib/ui holds the components that know nothing of the app. It may '
          'use lib/common files whose own imports stay out of the app, never '
          'the lib/common/common.dart barrel, and gets app state through '
          'ViewScope, MeasureScope and UiLocalizations instead:\n'
          '${offenders.join('\n')}',
    );
  });
}

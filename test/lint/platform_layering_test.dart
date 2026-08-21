import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _platformPackages = [
  'tray_manager',
  'window_manager',
  'launch_at_startup',
  'screen_retriever',
  'hotkey_manager',
];

const _platformModules = [
  'lib/common/tray.dart',
  'lib/common/window.dart',
  'lib/common/launch.dart',
  'lib/common/system_dns.dart',
  'lib/common/permission.dart',
];

final _platformImport = RegExp(
  "^import 'package:(${_platformPackages.join('|')})/",
  multiLine: true,
);

/// Everything `lib/common/common.dart` pulls into its compile graph, as
/// repository paths for project files and `package:`/`dart:` uris otherwise.
Set<String> _closureOfCommonBarrel() {
  String resolve(String uri, String from) {
    if (uri.startsWith('package:fl_clash/')) {
      return 'lib/${uri.substring('package:fl_clash/'.length)}';
    }
    if (uri.startsWith('dart:') || uri.startsWith('package:')) return uri;
    return p.normalize(p.join(p.dirname(from), uri));
  }

  final directive = RegExp(
    r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  final reached = <String>{'lib/common/common.dart'};
  final queue = <String>[...reached];

  while (queue.isNotEmpty) {
    final current = queue.removeLast();
    final file = File(current);
    if (!file.existsSync()) continue;
    for (final match in directive.allMatches(file.readAsStringSync())) {
      final next = resolve(match.group(1)!, current);
      if (!reached.add(next)) continue;
      queue.add(next);
    }
  }

  return reached;
}

Iterable<File> _dartFilesIn(String root) sync* {
  final directory = Directory(root);
  if (!directory.existsSync()) {
    fail('$root no longer exists; update this test.');
  }
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.contains('/generated/')) {
      yield entity;
    }
  }
}

void main() {
  test('the common barrel never re-exports a platform module', () {
    final exports = File('lib/common/common.dart').readAsLinesSync();
    final leaked = <String>[];

    for (final module in _platformModules) {
      final line = "export '${p.basename(module)}';";
      if (exports.contains(line)) {
        leaked.add(
          '$line — importing the barrel would pull the platform package into '
          'every one of its consumers',
        );
      }
    }

    expect(leaked, isEmpty, reason: leaked.join('\n'));
  });

  test('only the designated modules reach a desktop platform package', () {
    final offenders = <String>[];

    for (final root in ['lib/common', 'lib/enum', 'lib/models']) {
      for (final file in _dartFilesIn(root)) {
        final relative = p.relative(file.path);
        if (_platformModules.contains(relative)) {
          continue;
        }
        final match = _platformImport.firstMatch(file.readAsStringSync());
        if (match != null) {
          offenders.add('$relative imports ${match.group(1)}');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('nothing the common barrel reaches imports a platform package', () {
    final reached = _closureOfCommonBarrel();
    final offenders = [
      for (final package in _platformPackages)
        if (reached.any((uri) => uri.startsWith('package:$package/'))) package,
    ];

    expect(
      offenders,
      isEmpty,
      reason:
          'A file the common barrel transitively reaches pulls a desktop '
          'platform package into all ${reached.where((f) => f.startsWith('lib/')).length} '
          'of its dependencies:\n${offenders.join('\n')}',
    );
  });

  test('the common barrel never reaches the view tree', () {
    final reached = _closureOfCommonBarrel();
    final views =
        reached.where((file) => file.startsWith('lib/views/')).toList()..sort();

    expect(
      views,
      isEmpty,
      reason:
          'A widget is reachable from `lib/common/common.dart`, so every file '
          'that imports the barrel for a string helper now compiles the UI. '
          'This is how `common/navigation.dart` and the widget on '
          '`DashboardWidget` each put ~60 view files in the closure. Data the '
          'provider layer needs is passed through a port in '
          '`common/app_ports.dart`; the layer that owns the widgets binds '
          'it:\n${views.join('\n')}',
    );
  });

  test('common never depends on the manager barrel', () {
    final offenders = <String>[];

    for (final file in _dartFilesIn('lib/common')) {
      if (file.readAsStringSync().contains(
        "import 'package:fl_clash/manager/manager.dart';",
      )) {
        offenders.add(
          '${p.relative(file.path)} — import the one manager it needs, not the '
          'barrel that reaches every platform manager',
        );
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}

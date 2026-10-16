import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/core/spill.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

import '../helpers/app_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late Directory spillDirectory;

  setUp(() async {
    home = Directory.systemTemp.createTempSync('spill_test');
    await useAppPaths(home);
    spillDirectory = Directory(join(home.path, coreSpillDirectoryName))
      ..createSync();
  });

  tearDown(() => home.deleteSync(recursive: true));

  File spill(Directory directory, Map<String, Object?> envelope) {
    return File(join(directory.path, '1.json'))
      ..writeAsStringSync(json.encode(envelope));
  }

  test('an answer sent inline passes through', () async {
    const response = CoreMethodResponse(id: '1', result: 'inline');

    expect(await resolveSpilledResponse(response), same(response));
  });

  test('reads a spilled answer and deletes its file', () async {
    final file = spill(spillDirectory, {
      'id': '2',
      'result': {'mode': 'rule'},
    });

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '2', file: file.path),
    );

    expect(response.id, '2');
    expect(response.unwrap<Map<String, dynamic>>(), {'mode': 'rule'});
    expect(file.existsSync(), isFalse);
  });

  test('a spilled connection list arrives parsed', () async {
    final file = spill(spillDirectory, {
      'id': '4',
      'result': {
        'connections': [
          {
            'id': 'c1',
            'metadata': {'network': 'tcp'},
            'start': '2026-01-01',
            'chains': ['DIRECT'],
            'rule': 'MATCH',
            'rulePayload': '',
          },
        ],
      },
    });

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '4', file: file.path),
      method: CoreMethod.getConnections,
    );

    expect(response.unwrap<List<TrackerInfo>>()?.single.id, 'c1');
  });

  test('refuses a file outside the spill directory', () async {
    final file = spill(home, {'id': '3', 'result': 'secret'});

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '3', file: file.path),
    );

    expect(
      () => response.unwrap<Object?>(),
      throwsA(
        isA<CoreMethodException>().having((e) => e.code, 'code', 'spill_error'),
      ),
    );
    expect(file.existsSync(), isTrue);
  });

  test('a missing file fails the call instead of the transport', () async {
    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '4', file: join(spillDirectory.path, 'gone.json')),
    );

    expect(response.error?.code, 'spill_error');
  });

  test('reads a file the Core built there as text and deletes it', () async {
    final built = File(join(spillDirectory.path, 'built.yaml'))
      ..writeAsStringSync('mode: rule\n');

    expect(await readSpilledText(built.path), 'mode: rule\n');
    expect(built.existsSync(), isFalse);
  });

  test('refuses to read text outside the spill directory', () async {
    final outside = File(join(home.path, 'built.yaml'))
      ..writeAsStringSync('secret');

    await expectLater(
      readSpilledText(outside.path),
      throwsA(
        isA<CoreMethodException>().having((e) => e.code, 'code', 'spill_error'),
      ),
    );
    expect(outside.existsSync(), isTrue);
  });

  test('discarding deletes only a spilled file', () async {
    final spilled = spill(spillDirectory, {'id': '5', 'result': null});
    final outside = spill(home, {'id': '6', 'result': null});

    await discardSpilledResponse(CoreMethodResponse(file: spilled.path));
    await discardSpilledResponse(CoreMethodResponse(file: outside.path));

    expect(spilled.existsSync(), isFalse);
    expect(outside.existsSync(), isTrue);
  });

  test('discarding a late built profile deletes the file it names', () async {
    final built = File(join(spillDirectory.path, 'built.yaml'))
      ..writeAsStringSync('proxies: []');

    await discardSpilledResponse(
      CoreMethodResponse(id: '7', result: built.path),
    );
    await discardSpilledResponse(
      const CoreMethodResponse(id: '8', result: 'not a path'),
    );

    expect(built.existsSync(), isFalse);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  late Directory dir;
  late String path;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('preferences_store');
    path = join(dir.path, 'shared_preferences.json');
  });

  tearDown(() => dir.delete(recursive: true));

  AtomicFilePreferencesStore openStore() {
    return AtomicFilePreferencesStore(Future.value(path));
  }

  Object? readFile() => json.decode(File(path).readAsStringSync());

  List<String> dirEntries() {
    return dir.listSync().map((entity) => basename(entity.path)).toList();
  }

  test('reads the file the upstream store writes', () async {
    File(path).writeAsStringSync(
      json.encode({
        'flutter.config': '{"a":1}',
        'flutter.version': 1,
        'flutter.flag': true,
        'flutter.ratio': 0.5,
        'flutter.list': ['a', 'b'],
        'other': 'kept',
      }),
    );

    expect(await openStore().getAll(), {
      'flutter.config': '{"a":1}',
      'flutter.version': 1,
      'flutter.flag': true,
      'flutter.ratio': 0.5,
      'flutter.list': ['a', 'b'],
    });
  });

  test('a missing or empty file reads as empty', () async {
    expect(await openStore().getAll(), isEmpty);

    File(path).writeAsStringSync('');

    expect(await openStore().getAll(), isEmpty);
  });

  test('a torn file fails to load until it is readable again', () async {
    File(path).writeAsStringSync('{"flutter.config": "{');
    final store = openStore();

    await expectLater(store.getAll(), throwsFormatException);

    File(path).writeAsStringSync(json.encode({'flutter.config': '{}'}));

    expect(await store.getAll(), {'flutter.config': '{}'});
  });

  test('writes keep keys outside the prefix', () async {
    File(path).writeAsStringSync(json.encode({'other': 'kept'}));
    final store = openStore();

    expect(await store.setValue('String', 'flutter.config', 'x'), isTrue);
    expect(await store.remove('flutter.missing'), isTrue);
    expect(readFile(), {'other': 'kept', 'flutter.config': 'x'});

    expect(await store.clear(), isTrue);
    expect(readFile(), {'other': 'kept'});
  });

  test('parameters filter by prefix and allow list', () async {
    final store = openStore();
    await store.setValue('String', 'flutter.a', 'a');
    await store.setValue('String', 'flutter.b', 'b');
    await store.setValue('String', 'other.c', 'c');

    expect(
      await store.getAllWithParameters(
        GetAllParameters(
          filter: PreferencesFilter(
            prefix: 'flutter.',
            allowList: {'flutter.a', 'other.c'},
          ),
        ),
      ),
      {'flutter.a': 'a'},
    );

    await store.clearWithParameters(
      ClearParameters(filter: PreferencesFilter(prefix: 'other.')),
    );
    expect(readFile(), {'flutter.a': 'a', 'flutter.b': 'b'});
  });

  test('overlapping writes all land and leave no temp file', () async {
    final store = openStore();

    final results = await Future.wait([
      for (var i = 0; i < 50; i++) store.setValue('Int', 'flutter.k$i', i),
    ]);

    expect(results, everyElement(isTrue));
    expect(readFile(), {for (var i = 0; i < 50; i++) 'flutter.k$i': i});
    expect(dirEntries(), ['shared_preferences.json']);
  });

  test('a save that cannot be written leaves the previous file', () async {
    File(path).writeAsStringSync(json.encode({'flutter.config': 'old'}));
    Directory('$path.$pid.tmp').createSync();

    expect(
      await openStore().setValue('String', 'flutter.config', 'new'),
      isFalse,
    );
    expect(readFile(), {'flutter.config': 'old'});
  });

  test('a save that cannot replace the file removes its temp file', () async {
    Directory(path).createSync();
    File(join(path, 'occupied')).createSync();

    expect(
      await openStore().setValue('String', 'flutter.config', 'new'),
      isFalse,
    );
    expect(dirEntries(), ['shared_preferences.json']);
  });

  test('backs SharedPreferences', () async {
    addTearDown(SharedPreferences.resetStatic);
    SharedPreferencesStorePlatform.instance = openStore();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('config', '{}');
    await preferences.setStringList('list', ['a']);

    expect(readFile(), {
      'flutter.config': '{}',
      'flutter.list': ['a'],
    });

    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = openStore();
    final reopened = await SharedPreferences.getInstance();

    expect(reopened.getString('config'), '{}');
    expect(reopened.getStringList('list'), ['a']);
  });
}

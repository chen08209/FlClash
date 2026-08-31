import 'dart:io';

import 'package:fl_clash/common/lock.dart';
import 'package:fl_clash/common/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  late Directory home;

  setUp(() {
    home = Directory.systemTemp.createTempSync('flclash-lock-');
    SingleInstanceLock.resolvePath = () async =>
        join(home.path, 'FlClash.lock');
  });

  tearDown(() async {
    SingleInstanceLock.resolvePath = () => appPath.lockFilePath;
    await SingleInstanceLock().release();
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  test('SingleInstanceLock is a singleton', () {
    expect(SingleInstanceLock(), same(singleInstanceLock));
  });

  test(
    'acquiring holds the lock file the second instance would test',
    () async {
      final path = join(home.path, 'FlClash.lock');
      expect(File(path).existsSync(), isFalse);

      expect(await SingleInstanceLock().acquire(), isTrue);

      expect(
        File(path).existsSync(),
        isTrue,
        reason:
            'the file is what a second process locks against; without it every '
            'launch would start another core.',
      );
    },
  );

  test('an unusable lock path is reported, not thrown', () async {
    SingleInstanceLock.resolvePath = () async =>
        join(home.path, 'missing-dir', 'FlClash.lock');

    expect(
      await SingleInstanceLock().acquire(),
      isFalse,
      reason:
          'acquire runs before the window exists, so a broken path has to come '
          'back as false rather than take the launch down.',
    );
  });

  test('a path that is a directory is reported, not thrown', () async {
    final directory = Directory(join(home.path, 'FlClash.lock'))
      ..createSync(recursive: true);
    SingleInstanceLock.resolvePath = () async => directory.path;

    expect(await SingleInstanceLock().acquire(), isFalse);
  });

  test('an activation request reaches the lock holder once', () async {
    final received = <void>[];
    final subscription = SingleInstanceLock().activationRequests.listen(
      received.add,
    );
    addTearDown(subscription.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    await SingleInstanceLock().requestActivation();

    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (received.isEmpty && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(received, hasLength(1));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(
      received,
      hasLength(1),
      reason: 'create and modify events for one marker must not show twice',
    );
    expect(
      File(join(home.path, 'FlClash.lock.activate')).existsSync(),
      isFalse,
      reason: 'a consumed marker must not fire again on the next launch',
    );
  });

  test(
    'an activation request on a broken path is reported, not thrown',
    () async {
      SingleInstanceLock.resolvePath = () async =>
          join(home.path, 'missing-dir', 'FlClash.lock');

      await SingleInstanceLock().requestActivation();
    },
  );

  test('a failure to resolve the path is reported, not thrown', () async {
    SingleInstanceLock.resolvePath = () async =>
        throw const FileSystemException('no home directory');

    expect(await SingleInstanceLock().acquire(), isFalse);
  });
}

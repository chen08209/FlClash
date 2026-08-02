import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:test/test.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String> getApplicationSupportPath() async => p.join(rootPath, 'data');

  @override
  Future<String> getTemporaryPath() async => p.join(rootPath, 'temp');

  @override
  Future<String> getDownloadsPath() async => p.join(rootPath, 'downloads');

  @override
  Future<String> getApplicationCachePath() async => p.join(rootPath, 'cache');
}

void main() {
  late Directory rootDir;
  late PathProviderPlatform originalPathProvider;

  setUpAll(() async {
    rootDir = await Directory.systemTemp.createTemp('fl_clash_profile_test_');
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProviderPlatform(rootDir.path);
    await Directory(p.join(rootDir.path, 'temp')).create();
    registerFallbackValue(
      const DownloadFileParams(
        url: 'https://example.com/profile',
        path: '/tmp/profile.yaml',
        userAgent: 'FlClash/Test',
      ),
    );
  });

  setUp(CoreController.resetInstance);

  tearDownAll(() async {
    PathProviderPlatform.instance = originalPathProvider;
    await rootDir.delete(recursive: true);
  });

  tearDown(CoreController.resetInstance);

  group('SubscriptionInfo', () {
    test('parses subscription-userinfo header values', () {
      final info = SubscriptionInfo.formHString(
        'upload=10; download=20; total=100; expire=200',
      );

      expect(info.upload, 10);
      expect(info.download, 20);
      expect(info.total, 100);
      expect(info.expire, 200);
    });

    test('falls back to zero for null and invalid values', () {
      expect(SubscriptionInfo.formHString(null), const SubscriptionInfo());
      expect(SubscriptionInfo.formHString(''), const SubscriptionInfo());

      final info = SubscriptionInfo.formHString(
        'invalid; upload=bad; download=20; total=; expire=abc',
      );

      expect(info.upload, 0);
      expect(info.download, 20);
      expect(info.total, 0);
      expect(info.expire, 0);
    });
  });

  group('ProfileExtension', () {
    test('derives type, label, filename, and updating key', () {
      const fileProfile = Profile(
        id: 7,
        autoUpdateDuration: defaultUpdateDuration,
      );
      const urlProfile = Profile(
        id: 8,
        label: 'Remote',
        url: 'https://example.com/profile.yaml',
        autoUpdate: true,
        autoUpdateDuration: defaultUpdateDuration,
      );

      expect(fileProfile.type, ProfileType.file);
      expect(fileProfile.realAutoUpdate, false);
      expect(fileProfile.realLabel, '7');
      expect(fileProfile.fileName, '7.yaml');
      expect(fileProfile.updatingKey, 'profile_7');

      expect(urlProfile.type, ProfileType.url);
      expect(urlProfile.realAutoUpdate, true);
      expect(urlProfile.realLabel, 'Remote');
    });

    test(
      'copies a direct download before deleting its temporary file',
      () async {
        final mock = MockCoreHandlerInterface();
        final controller = CoreController.test(mock);
        final validationStarted = Completer<void>();
        final finishValidation = Completer<void>();
        late String downloadPath;
        when(() => mock.downloadFile(any())).thenAnswer((invocation) async {
          final params =
              invocation.positionalArguments.first as DownloadFileParams;
          downloadPath = params.path;
          await File(downloadPath).writeAsString('proxies: []');
          return json.encode({
            'content-disposition': 'attachment; filename=direct.yaml',
            'subscription-userinfo': 'upload=1; total=10',
            'error': '',
          });
        });
        when(() => mock.validateConfig(any())).thenAnswer((_) async {
          validationStarted.complete();
          await finishValidation.future;
          return '';
        });

        try {
          const profile = Profile(
            id: 7,
            url: 'https://example.com/profile',
            autoUpdateDuration: defaultUpdateDuration,
          );
          final update = profile.updateDirect(
            controller: controller,
            userAgent: 'FlClash/Test',
          );

          await validationStarted.future;
          await Future<void>.delayed(Duration.zero);
          expect(await File(downloadPath).exists(), isTrue);

          finishValidation.complete();
          final updated = await update;
          final profileFile = File(await appPath.getProfilePath('7'));

          expect(await profileFile.readAsString(), 'proxies: []');
          expect(await File(downloadPath).exists(), isFalse);
          expect(updated.label, 'direct.yaml');
          expect(updated.subscriptionInfo?.upload, 1);
          expect(updated.subscriptionInfo?.total, 10);
        } finally {
          if (!finishValidation.isCompleted) {
            finishValidation.complete();
          }
        }
      },
    );
  });

  group('ProfilesExt', () {
    test('gets profile by id', () {
      const profiles = [
        Profile(id: 1, label: 'A', autoUpdateDuration: defaultUpdateDuration),
        Profile(id: 2, label: 'B', autoUpdateDuration: defaultUpdateDuration),
      ];

      expect(profiles.getProfile(2)?.label, 'B');
      expect(profiles.getProfile(3), isNull);
      expect(profiles.getProfile(null), isNull);
    });

    test('optimizes duplicate labels with incremented suffix', () {
      const profiles = [
        Profile(
          id: 1,
          label: 'Work',
          autoUpdateDuration: defaultUpdateDuration,
        ),
        Profile(
          id: 2,
          label: 'Work(1)',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ];
      const newProfile = Profile(
        id: 3,
        label: 'Work',
        autoUpdateDuration: defaultUpdateDuration,
      );

      expect(profiles.optimizeLabel(newProfile).label, 'Work(2)');
    });
  });

  group('ProfileRuleLinkExt', () {
    test('builds stable key from non-null parts', () {
      const link = ProfileRuleLink(
        profileId: 1,
        ruleId: 2,
        scene: RuleScene.added,
      );
      const globalLink = ProfileRuleLink(ruleId: 3);

      expect(link.key, '1_2_added');
      expect(globalLink.key, '3');
    });
  });
}

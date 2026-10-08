import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
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

      final info = SubscriptionInfo.formHString(
        'upload=bad; download=20; total=; expire=abc',
      );

      expect(info.upload, 0);
      expect(info.download, 20);
      expect(info.total, 0);
      expect(info.expire, 0);
    });

    test('skips empty and malformed fields instead of throwing', () {
      final info = SubscriptionInfo.formHString(
        'upload=10;; download; =5; total=100;',
      );

      expect(info.upload, 10);
      expect(info.download, 0);
      expect(info.total, 100);
    });

    test('truncates decimal and exponent counts', () {
      final info = SubscriptionInfo.formHString(
        'Upload=1.5; download=2.4e3; total=1.073741824E10; expire=Infinity',
      );

      expect(info.upload, 1);
      expect(info.download, 2400);
      expect(info.total, 10737418240);
      expect(info.expire, 0);
    });
  });

  group('Profile factories', () {
    test('normal takes its type from whether it has a url', () {
      expect(Profile.normal().type, ProfileType.file);
      expect(
        Profile.normal(url: 'https://example.com/profile.yaml').type,
        ProfileType.url,
      );
    });

    test('custom never updates itself', () {
      final profile = Profile.custom(label: 'Mine');

      expect(profile.type, ProfileType.custom);
      expect(profile.url, isEmpty);
      expect(profile.realAutoUpdate, false);
    });
  });

  group('ProfileExtension', () {
    test('derives auto update, label, filename, and updating key', () {
      const fileProfile = Profile(
        id: 7,
        autoUpdateDuration: defaultUpdateDuration,
      );
      const urlProfile = Profile(
        id: 8,
        type: ProfileType.url,
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
      expect(urlProfile.copyWith(label: '').realLabel, 'example.com');
    });

    test('an unnamed profile falls back to its url host, then its id', () {
      final profiles = [
        const Profile(
          id: 1,
          label: 'example.com',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ];
      const remote = Profile(
        id: 2,
        type: ProfileType.url,
        url: 'https://example.com:8443/api/subscribe?token=1',
        autoUpdateDuration: defaultUpdateDuration,
      );
      const local = Profile(id: 3, autoUpdateDuration: defaultUpdateDuration);

      expect(remote.defaultLabel, 'example.com');
      expect(local.defaultLabel, '3');
      expect(profiles.optimizeLabel(remote).label, 'example.com(1)');
      expect(profiles.optimizeLabel(local).label, '3');
    });
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
}

import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:test/test.dart';

void main() {
  test(
    'v2 to v3 migration preserves profiles and adds empty favorites',
    () async {
      final database = Database(
        NativeDatabase.memory(
          setup: (database) {
            database.execute('''
            CREATE TABLE profiles (
              id INTEGER NOT NULL PRIMARY KEY,
              label TEXT NOT NULL,
              current_group_name TEXT,
              url TEXT NOT NULL,
              last_update_date INTEGER,
              overwrite_type TEXT NOT NULL,
              script_id INTEGER,
              auto_update_duration_millis INTEGER NOT NULL,
              subscription_info TEXT,
              auto_update INTEGER NOT NULL CHECK (auto_update IN (0, 1)),
              selected_map TEXT NOT NULL,
              unfold_set TEXT NOT NULL,
              "order" INTEGER
            )
          ''');
            database.execute('''
            INSERT INTO profiles (
              id,
              label,
              current_group_name,
              url,
              overwrite_type,
              auto_update_duration_millis,
              auto_update,
              selected_map,
              unfold_set,
              "order"
            ) VALUES (
              1,
              'Existing profile',
              'GLOBAL',
              'https://example.com/config.yaml',
              'standard',
              14400000,
              1,
              '{"GLOBAL":"HK"}',
              '["GLOBAL"]',
              2
            )
          ''');
            database.execute('PRAGMA user_version = 2');
          },
        ),
      );
      addTearDown(database.close);

      final profiles = await database.profilesDao.query().get();

      expect(database.schemaVersion, 3);
      expect(profiles, hasLength(1));
      expect(profiles.single.label, 'Existing profile');
      expect(profiles.single.selectedMap, {'GLOBAL': 'HK'});
      expect(profiles.single.unfoldSet, {'GLOBAL'});
      expect(profiles.single.favoriteProxies, isEmpty);
      expect(profiles.single.order, 2);
    },
  );
}

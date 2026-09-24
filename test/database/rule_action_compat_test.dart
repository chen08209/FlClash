import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleAction compatibility', () {
    const converter = RuleActionConverter();

    test('accepts enum names and Mihomo wire names and stores enum names', () {
      expect(converter.fromSql('PROCESS_NAME'), RuleAction.PROCESS_NAME);
      expect(converter.fromSql('PROCESS-NAME'), RuleAction.PROCESS_NAME);
      expect(
        converter.fromSql('PROCESS-PATH-REGEX'),
        RuleAction.PROCESS_PATH_REGEX,
      );
      expect(converter.toSql(RuleAction.PROCESS_NAME), 'PROCESS_NAME');
      expect(
        converter.toSql(RuleAction.PROCESS_PATH_REGEX),
        'PROCESS_PATH_REGEX',
      );
    });

    test('Mihomo PROCESS-NAME parses and serializes with wire syntax', () {
      final rule = Rule.parse('PROCESS-NAME,chrome.exe,DIRECT', id: 7);

      expect(rule.ruleAction, RuleAction.PROCESS_NAME);
      expect(rule.content, 'chrome.exe');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.rawValue, 'PROCESS-NAME,chrome.exe,DIRECT');
    });

    test('new databases persist canonical enum names', () async {
      final database = Database(NativeDatabase.memory());
      addTearDown(database.close);

      await database.rulesDao.putGlobalRule(
        const Rule(
          id: 1,
          ruleAction: RuleAction.PROCESS_NAME,
          content: 'chrome.exe',
          ruleTarget: 'DIRECT',
        ),
      );

      final row = await database
          .customSelect(
            'SELECT rule_action FROM rules WHERE id = ?',
            variables: [const Variable<int>(1)],
          )
          .getSingle();

      expect(row.read<String>('rule_action'), 'PROCESS_NAME');
    });

    test('startup rewrites legacy wire names before typed reads', () async {
      final directory = await Directory.systemTemp.createTemp(
        'flclash-rule-action-startup-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );

      var database = Database(NativeDatabase(file));
      await database.customStatement(
        'INSERT INTO rules '
        '(id, rule_action, content, rule_target, no_resolve, src) '
        'VALUES (?, ?, ?, ?, 0, 0)',
        [1, 'PROCESS-NAME', 'chrome.exe', 'DIRECT'],
      );
      await database.close();

      database = Database(NativeDatabase(file));
      addTearDown(database.close);

      final raw = await database
          .customSelect(
            'SELECT rule_action FROM rules WHERE id = ?',
            variables: [const Variable<int>(1)],
          )
          .getSingle();
      final typed = await database.rules.all().getSingle();

      expect(raw.read<String>('rule_action'), 'PROCESS_NAME');
      expect(typed.ruleAction, RuleAction.PROCESS_NAME);
      expect(typed.toRule().rawValue, 'PROCESS-NAME,chrome.exe,DIRECT');
    });

    test('schema v1 migration stores PROCESS-NAME as PROCESS_NAME', () async {
      final directory = await Directory.systemTemp.createTemp(
        'flclash-rule-action-upgrade-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );

      var database = Database(NativeDatabase(file));
      await database.customSelect('SELECT 1').getSingle();
      await database.customStatement('DROP TABLE rules');
      await database.customStatement('DROP TABLE proxy_groups');
      await database.customStatement('DROP TABLE icon_records');
      await database.customStatement(
        'CREATE TABLE rules ('
        'id INTEGER NOT NULL PRIMARY KEY, '
        'value TEXT NOT NULL'
        ')',
      );
      await database.customStatement(
        'INSERT INTO rules (id, value) VALUES (?, ?)',
        [9, 'PROCESS-NAME,chrome.exe,DIRECT'],
      );
      await database.customStatement('PRAGMA user_version = 1');
      await database.close();

      database = Database(NativeDatabase(file));
      addTearDown(database.close);

      final raw = await database
          .customSelect(
            'SELECT rule_action FROM rules WHERE id = ?',
            variables: [const Variable<int>(9)],
          )
          .getSingle();
      final typed = await database.rules.all().getSingle();

      expect(raw.read<String>('rule_action'), 'PROCESS_NAME');
      expect(typed.ruleAction, RuleAction.PROCESS_NAME);
      expect(typed.content, 'chrome.exe');
      expect(typed.ruleTarget, 'DIRECT');
    });

    test('restore writes legacy-parsed rules back in canonical form', () async {
      final database = Database(NativeDatabase.memory());
      addTearDown(database.close);
      final rule = Rule.parse('PROCESS-NAME,chrome.exe,DIRECT', id: 11);

      await database.restore([], [], [rule], [], []);

      final raw = await database
          .customSelect(
            'SELECT rule_action FROM rules WHERE id = ?',
            variables: [const Variable<int>(11)],
          )
          .getSingle();
      final restored = await database.rules.all().getSingle();

      expect(raw.read<String>('rule_action'), 'PROCESS_NAME');
      expect(restored.ruleAction, RuleAction.PROCESS_NAME);
      expect(restored.toRule().rawValue, 'PROCESS-NAME,chrome.exe,DIRECT');
    });
  });
}

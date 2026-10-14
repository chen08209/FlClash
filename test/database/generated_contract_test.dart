import 'package:drift/drift.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile and script generated data classes preserve all fields', () {
    final date = DateTime.utc(2026, 7, 26);
    final profile = RawProfile(
      id: 1,
      type: ProfileType.url,
      label: 'Profile',
      currentGroupName: 'Select',
      url: 'https://example.com/profile.yaml',
      ageSecretKey: 'AGE-SECRET-KEY-1',
      lastUpdateDate: date,
      extendType: ExtendType.script,
      scriptId: 2,
      matchTarget: 'Proxy',
      autoUpdateDurationMillis: 3600000,
      subscriptionInfo: const SubscriptionInfo(
        upload: 1,
        download: 2,
        total: 3,
        expire: 4,
      ),
      autoUpdate: true,
      selectedMap: const {'Select': 'DIRECT'},
      unfoldSet: const {'Select'},
      order: 3,
      overrides: const ProfileOverrides(
        dnsOverrideKeys: {DnsOverrideKey.nameserver},
      ),
    );

    expect(profile.toColumns(true), hasLength(17));
    expect(profile.toCompanion(true).toColumns(true), hasLength(17));
    expect(RawProfile.fromJson(profile.toJson()).toJson(), profile.toJson());
    expect(profile.copyWith(label: 'Next').label, 'Next');
    expect(
      profile
          .copyWithCompanion(
            const ProfilesCompanion(
              currentGroupName: Value(null),
              scriptId: Value(null),
              order: Value(9),
            ),
          )
          .order,
      9,
    );
    expect(profile.copyWith(), profile);
    expect(profile.hashCode, isNonZero);
    expect(profile.toString(), contains('Profile'));

    const emptyProfile = RawProfile(
      id: 2,
      type: ProfileType.custom,
      label: 'Empty',
      url: '',
      extendType: ExtendType.standard,
      autoUpdateDurationMillis: 0,
      autoUpdate: false,
      selectedMap: {},
      unfoldSet: {},
    );
    expect(emptyProfile.toColumns(true), hasLength(9));
    expect(emptyProfile.toColumns(false), hasLength(17));
    expect(emptyProfile.toCompanion(true).toColumns(true), hasLength(9));

    final insertedProfile = ProfilesCompanion.insert(
      type: ProfileType.file,
      label: 'Inserted',
      url: 'url',
      extendType: ExtendType.script,
      autoUpdateDurationMillis: 60,
      autoUpdate: true,
      selectedMap: const {},
      unfoldSet: const {},
    ).copyWith(id: const Value(8), order: const Value(1));
    expect(insertedProfile.toColumns(true), hasLength(10));
    expect(insertedProfile.toString(), contains('Inserted'));
    expect(
      ProfilesCompanion.custom(
        id: const Variable(1),
        type: const Variable('custom'),
        label: const Variable('custom'),
        currentGroupName: const Variable('group'),
        url: const Variable('url'),
        ageSecretKey: const Variable('AGE-SECRET-KEY-1'),
        lastUpdateDate: Variable(date),
        extendType: const Variable('standard'),
        scriptId: const Variable(2),
        matchTarget: const Variable('Proxy'),
        autoUpdateDurationMillis: const Variable(60),
        subscriptionInfo: const Variable('{}'),
        autoUpdate: const Variable(true),
        selectedMap: const Variable('{}'),
        unfoldSet: const Variable('[]'),
        order: const Variable(1),
        overrides: const Variable('{}'),
      ).toColumns(false),
      hasLength(17),
    );

    final script = RawScript(id: 2, label: 'Script', lastUpdateTime: date);
    expect(script.toColumns(true), hasLength(3));
    expect(script.toCompanion(true).toColumns(true), hasLength(3));
    final restoredScript = RawScript.fromJson(script.toJson());
    expect(restoredScript.id, script.id);
    expect(restoredScript.label, script.label);
    expect(restoredScript.lastUpdateTime.isAtSameMomentAs(date), true);
    expect(script.copyWith(label: 'Changed').label, 'Changed');
    expect(
      script
          .copyWithCompanion(
            ScriptsCompanion(
              label: const Value('Companion'),
              lastUpdateTime: Value(date.add(const Duration(days: 1))),
            ),
          )
          .label,
      'Companion',
    );
    expect(script.toString(), contains('Script'));
    expect(script.hashCode, isNonZero);

    final scriptCompanion = ScriptsCompanion.insert(
      label: 'Inserted',
      lastUpdateTime: date,
    ).copyWith(id: const Value(3));
    expect(scriptCompanion.toColumns(true), hasLength(3));
    expect(scriptCompanion.toString(), contains('Inserted'));
    expect(
      ScriptsCompanion.custom(
        id: const Variable(1),
        label: const Variable('custom'),
        lastUpdateTime: Variable(date),
      ).toColumns(false),
      hasLength(3),
    );
  });

  test('rule generated classes preserve nullable contracts', () {
    const rule = RawRule(
      id: 10,
      profileId: 1,
      ruleAction: RuleAction.RULE_SET,
      content: 'content',
      ruleTarget: 'Proxy',
      ruleProvider: 'provider',
      subRule: 'sub',
      noResolve: true,
      src: true,
      order: 'a0',
    );

    expect(rule.toColumns(true), hasLength(10));
    expect(rule.toCompanion(true).toColumns(true), hasLength(10));
    expect(RawRule.fromJson(rule.toJson()), rule);
    expect(rule.copyWith(content: const Value(null)).content, null);
    expect(
      rule
          .copyWithCompanion(
            const RulesCompanion(
              ruleAction: Value(RuleAction.DOMAIN),
              noResolve: Value(false),
            ),
          )
          .ruleAction,
      RuleAction.DOMAIN,
    );
    expect(rule.toString(), contains('RULE_SET'));
    expect(rule.hashCode, isNonZero);

    const emptyRule = RawRule(
      id: 11,
      ruleAction: RuleAction.MATCH,
      noResolve: false,
      src: false,
    );
    expect(emptyRule.toColumns(true), hasLength(4));
    expect(emptyRule.toColumns(false), hasLength(10));

    final ruleCompanion =
        RulesCompanion.insert(ruleAction: RuleAction.DOMAIN_SUFFIX).copyWith(
          id: const Value(12),
          profileId: const Value(1),
          content: const Value('example.com'),
          ruleTarget: const Value('DIRECT'),
          ruleProvider: const Value('provider'),
          subRule: const Value('sub'),
          noResolve: const Value(true),
          src: const Value(true),
          order: const Value('a0'),
        );
    expect(ruleCompanion.toColumns(true), hasLength(10));
    expect(ruleCompanion.toString(), contains('DOMAIN_SUFFIX'));
    expect(
      RulesCompanion.custom(
        id: const Variable(1),
        profileId: const Variable(2),
        ruleAction: const Variable('DOMAIN'),
        content: const Variable('example.com'),
        ruleTarget: const Variable('DIRECT'),
        ruleProvider: const Variable('provider'),
        subRule: const Variable('sub'),
        noResolve: const Variable(true),
        src: const Variable(false),
        order: const Variable('a'),
      ).toColumns(false),
      hasLength(10),
    );

    const disabled = RawDisabledRule(profileId: 1, ruleId: 10);
    expect(disabled.toColumns(true), hasLength(2));
    expect(disabled.toCompanion(true).toColumns(true), hasLength(2));
    expect(RawDisabledRule.fromJson(disabled.toJson()), disabled);
    expect(disabled.copyWith(ruleId: 11).ruleId, 11);
    expect(
      disabled
          .copyWithCompanion(const DisabledRulesCompanion(ruleId: Value(12)))
          .ruleId,
      12,
    );
    expect(disabled.toString(), contains('10'));
    expect(disabled.hashCode, isNonZero);
    final disabledCompanion = DisabledRulesCompanion.insert(
      profileId: 1,
      ruleId: 10,
    ).copyWith(rowid: const Value(5));
    expect(disabledCompanion.toColumns(true), hasLength(3));
    expect(disabledCompanion.toString(), contains('10'));
    expect(
      DisabledRulesCompanion.custom(
        profileId: const Variable(1),
        ruleId: const Variable(2),
        rowid: const Variable(3),
      ).toColumns(false),
      hasLength(3),
    );
  });

  test('proxy group and icon generated classes preserve every field', () {
    const group = RawProxyGroup(
      id: 20,
      profileId: 1,
      name: 'Select',
      type: 'select',
      proxies: ['DIRECT'],
      use: ['provider'],
      definition: '{"hidden":false}',
      order: 'a0',
    );

    expect(group.toColumns(true), hasLength(8));
    expect(group.toCompanion(true).toColumns(true), hasLength(8));
    expect(RawProxyGroup.fromJson(group.toJson()).toJson(), group.toJson());
    expect(group.copyWith(name: 'Changed').name, 'Changed');
    expect(
      group
          .copyWithCompanion(
            const ProxyGroupsCompanion(
              profileId: Value(2),
              definition: Value('{}'),
            ),
          )
          .definition,
      '{}',
    );
    expect(group.copyWith(), group);
    expect(group.toString(), contains('Select'));
    expect(group.hashCode, isNonZero);

    const emptyGroup = RawProxyGroup(
      id: 21,
      profileId: 1,
      name: 'Empty',
      type: 'select',
      definition: '{}',
    );
    expect(emptyGroup.toColumns(true), hasLength(5));
    expect(emptyGroup.toColumns(false), hasLength(8));

    final companion =
        ProxyGroupsCompanion.insert(
          profileId: 1,
          name: 'Inserted',
          type: 'select',
        ).copyWith(
          id: const Value(22),
          proxies: const Value(['DIRECT']),
          use: const Value(['provider']),
          definition: const Value('{"hidden":false}'),
          order: const Value('a0'),
        );
    expect(companion.toColumns(true), hasLength(8));
    expect(companion.toString(), contains('Inserted'));
    expect(
      ProxyGroupsCompanion.custom(
        id: const Variable(1),
        profileId: const Variable(2),
        name: const Variable('name'),
        type: const Variable('select'),
        proxies: const Variable('[]'),
        use: const Variable('[]'),
        definition: const Variable('{}'),
        order: const Variable('a0'),
      ).toColumns(false),
      hasLength(8),
    );

    const icon = IconRecord(
      url: 'https://example.com/icon.png',
      lastAccessed: 1,
    );
    expect(icon.toColumns(true), hasLength(2));
    expect(icon.toCompanion(true).toColumns(true), hasLength(2));
    expect(IconRecord.fromJson(icon.toJson()), icon);
    expect(icon.copyWith(lastAccessed: 2).lastAccessed, 2);
    expect(
      icon
          .copyWithCompanion(const IconRecordsCompanion(lastAccessed: Value(3)))
          .lastAccessed,
      3,
    );
    expect(icon.toString(), contains('icon.png'));
    expect(icon.hashCode, isNonZero);

    final iconCompanion = IconRecordsCompanion.insert(
      url: 'url',
      lastAccessed: 4,
    ).copyWith(rowid: const Value(1));
    expect(iconCompanion.toColumns(true), hasLength(3));
    expect(iconCompanion.toString(), contains('url'));
    expect(
      IconRecordsCompanion.custom(
        url: const Variable('url'),
        lastAccessed: const Variable(1),
        rowid: const Variable(2),
      ).toColumns(false),
      hasLength(3),
    );
  });
}

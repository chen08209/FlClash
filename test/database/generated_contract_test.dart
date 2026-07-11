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
      label: 'Profile',
      currentGroupName: 'Select',
      url: 'https://example.com/profile.yaml',
      lastUpdateDate: date,
      overwriteType: OverwriteType.custom,
      scriptId: 2,
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
    );

    expect(profile.toColumns(true), hasLength(13));
    expect(profile.toCompanion(true).toColumns(true), hasLength(13));
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
      label: 'Empty',
      url: '',
      overwriteType: OverwriteType.standard,
      autoUpdateDurationMillis: 0,
      autoUpdate: false,
      selectedMap: {},
      unfoldSet: {},
    );
    expect(emptyProfile.toColumns(true), hasLength(8));
    expect(emptyProfile.toColumns(false), hasLength(13));
    expect(emptyProfile.toCompanion(true).toColumns(true), hasLength(8));

    final insertedProfile = ProfilesCompanion.insert(
      label: 'Inserted',
      url: 'url',
      overwriteType: OverwriteType.script,
      autoUpdateDurationMillis: 60,
      autoUpdate: true,
      selectedMap: const {},
      unfoldSet: const {},
    ).copyWith(id: const Value(8), order: const Value(1));
    expect(insertedProfile.toColumns(true), hasLength(9));
    expect(insertedProfile.toString(), contains('Inserted'));
    expect(
      ProfilesCompanion.custom(
        id: const Variable(1),
        label: const Variable('custom'),
        currentGroupName: const Variable('group'),
        url: const Variable('url'),
        lastUpdateDate: Variable(date),
        overwriteType: const Variable('custom'),
        scriptId: const Variable(2),
        autoUpdateDurationMillis: const Variable(60),
        subscriptionInfo: const Variable('{}'),
        autoUpdate: const Variable(true),
        selectedMap: const Variable('{}'),
        unfoldSet: const Variable('[]'),
        order: const Variable(1),
      ).toColumns(false),
      hasLength(13),
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

  test('rule and link generated classes preserve nullable contracts', () {
    const rule = RawRule(
      id: 10,
      ruleAction: RuleAction.RULE_SET,
      content: 'content',
      ruleTarget: 'Proxy',
      ruleProvider: 'provider',
      subRule: 'sub',
      noResolve: true,
      src: true,
    );

    expect(rule.toColumns(true), hasLength(8));
    expect(rule.toCompanion(true).toColumns(true), hasLength(8));
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
    expect(emptyRule.toColumns(false), hasLength(8));

    final ruleCompanion =
        RulesCompanion.insert(ruleAction: RuleAction.DOMAIN_SUFFIX).copyWith(
          id: const Value(12),
          content: const Value('example.com'),
          ruleTarget: const Value('DIRECT'),
          ruleProvider: const Value('provider'),
          subRule: const Value('sub'),
          noResolve: const Value(true),
          src: const Value(true),
        );
    expect(ruleCompanion.toColumns(true), hasLength(8));
    expect(ruleCompanion.toString(), contains('DOMAIN_SUFFIX'));
    expect(
      RulesCompanion.custom(
        id: const Variable(1),
        ruleAction: const Variable('DOMAIN'),
        content: const Variable('example.com'),
        ruleTarget: const Variable('DIRECT'),
        ruleProvider: const Variable('provider'),
        subRule: const Variable('sub'),
        noResolve: const Variable(true),
        src: const Variable(false),
      ).toColumns(false),
      hasLength(8),
    );

    const link = RawProfileRuleLink(
      id: '1_10_added',
      profileId: 1,
      ruleId: 10,
      scene: RuleScene.added,
      order: 'a0',
    );
    expect(link.toColumns(true), hasLength(5));
    expect(link.toCompanion(true).toColumns(true), hasLength(5));
    expect(RawProfileRuleLink.fromJson(link.toJson()), link);
    expect(link.copyWith(profileId: const Value(null)).profileId, null);
    expect(
      link
          .copyWithCompanion(
            const ProfileRuleLinksCompanion(order: Value('b0')),
          )
          .order,
      'b0',
    );
    expect(link.toString(), contains('1_10_added'));
    expect(link.hashCode, isNonZero);

    const emptyLink = RawProfileRuleLink(id: '10', ruleId: 10);
    expect(emptyLink.toColumns(true), hasLength(2));
    expect(emptyLink.toColumns(false), hasLength(5));
    final linkCompanion =
        ProfileRuleLinksCompanion.insert(id: 'link', ruleId: 10).copyWith(
          profileId: const Value(1),
          scene: const Value(RuleScene.custom),
          order: const Value('c0'),
          rowid: const Value(5),
        );
    expect(linkCompanion.toColumns(true), hasLength(6));
    expect(linkCompanion.toString(), contains('link'));
    expect(
      ProfileRuleLinksCompanion.custom(
        id: const Variable('id'),
        profileId: const Variable(1),
        ruleId: const Variable(2),
        scene: const Variable('custom'),
        order: const Variable('a'),
        rowid: const Variable(3),
      ).toColumns(false),
      hasLength(6),
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
      url: 'https://example.com/generate_204',
      interval: 300,
      timeout: 5000,
      maxFailedTimes: 3,
      lazy: true,
      disableUDP: false,
      filter: 'include',
      excludeFilter: 'exclude',
      excludeType: 'Direct',
      expectedStatus: '204',
      includeAll: true,
      includeAllProxies: true,
      includeAllProviders: true,
      hidden: false,
      icon: 'icon',
      order: 'a0',
    );

    expect(group.toColumns(true), hasLength(22));
    expect(group.toCompanion(true).toColumns(true), hasLength(22));
    expect(RawProxyGroup.fromJson(group.toJson()).toJson(), group.toJson());
    expect(group.copyWith(name: 'Changed').name, 'Changed');
    expect(
      group
          .copyWithCompanion(
            const ProxyGroupsCompanion(
              profileId: Value(null),
              hidden: Value(true),
            ),
          )
          .hidden,
      true,
    );
    expect(group.copyWith(), group);
    expect(group.toString(), contains('Select'));
    expect(group.hashCode, isNonZero);

    const emptyGroup = RawProxyGroup(id: 21, name: 'Empty', type: 'select');
    expect(emptyGroup.toColumns(true), hasLength(3));
    expect(emptyGroup.toColumns(false), hasLength(22));

    final companion =
        ProxyGroupsCompanion.insert(name: 'Inserted', type: 'select').copyWith(
          id: const Value(22),
          profileId: const Value(1),
          proxies: const Value(['DIRECT']),
          use: const Value(['provider']),
          url: const Value('url'),
          interval: const Value(60),
          timeout: const Value(1000),
          maxFailedTimes: const Value(2),
          lazy: const Value(true),
          disableUDP: const Value(false),
          filter: const Value('filter'),
          excludeFilter: const Value('exclude'),
          excludeType: const Value('Direct'),
          expectedStatus: const Value('204'),
          includeAll: const Value(true),
          includeAllProxies: const Value(true),
          includeAllProviders: const Value(true),
          hidden: const Value(false),
          icon: const Value('icon'),
          order: const Value('a0'),
        );
    expect(companion.toColumns(true), hasLength(22));
    expect(companion.toString(), contains('Inserted'));
    expect(
      ProxyGroupsCompanion.custom(
        id: const Variable(1),
        profileId: const Variable(2),
        name: const Variable('name'),
        type: const Variable('select'),
        proxies: const Variable('[]'),
        use: const Variable('[]'),
        url: const Variable('url'),
        interval: const Variable(60),
        timeout: const Variable(1000),
        maxFailedTimes: const Variable(2),
        lazy: const Variable(true),
        disableUDP: const Variable(false),
        filter: const Variable('filter'),
        excludeFilter: const Variable('exclude'),
        excludeType: const Variable('Direct'),
        expectedStatus: const Variable('204'),
        includeAll: const Variable(true),
        includeAllProxies: const Variable(true),
        includeAllProviders: const Variable(true),
        hidden: const Variable(false),
        icon: const Variable('icon'),
        order: const Variable('a0'),
      ).toColumns(false),
      hasLength(22),
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

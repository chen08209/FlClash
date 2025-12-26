import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:isar_community/isar.dart';

import 'clash_config.dart';
import 'common.dart';

part 'generated/isar.g.dart';

@embedded
class StringMapEntryEmbedded {
  late String key;
  late String value;

  static StringMapEntryEmbedded fromEntry(MapEntry<String, String> entry) {
    return StringMapEntryEmbedded()
      ..key = entry.key
      ..value = entry.value;
  }

  MapEntry<String, String> toEntry() {
    return MapEntry(key, value);
  }
}

@embedded
class RuleEmbedded {
  late int id;
  late String value;

  int order = -1;

  static RuleEmbedded fromRule(Rule rule, {int? order}) {
    return RuleEmbedded()
      ..id = rule.id
      ..value = rule.value
      ..order = order ?? rule.order;
  }

  Rule toRule() {
    return Rule(id: id, value: value);
  }
}

@embedded
class StandardOverwriteEmbedded {
  List<RuleEmbedded> addedRules = [];
  List<int> disabledRuleIds = [];

  static StandardOverwriteEmbedded fromStandardOverwrite(
    StandardOverwrite overwrite,
  ) {
    return StandardOverwriteEmbedded()
      ..addedRules = overwrite.addedRules
          .map((rule) => RuleEmbedded.fromRule(rule))
          .toList()
      ..disabledRuleIds = overwrite.disabledRuleIds;
  }

  StandardOverwrite toStandardOverwrite() {
    return StandardOverwrite(
      addedRules: addedRules.map((rc) => rc.toRule()).toList(),
      disabledRuleIds: disabledRuleIds,
    );
  }
}

@embedded
class ScriptOverwriteEmbedded {
  int? scriptId;

  static ScriptOverwriteEmbedded fromScriptOverwrite(
    ScriptOverwrite overwrite,
  ) {
    return ScriptOverwriteEmbedded()..scriptId = overwrite.scriptId;
  }

  ScriptOverwrite toScriptOverwrite() {
    return ScriptOverwrite(scriptId: scriptId);
  }
}

@embedded
class CustomOverwriteEmbedded {}

@embedded
class OverwriteEmbedded {
  @Enumerated(EnumType.name)
  late OverwriteType type;

  StandardOverwriteEmbedded? standardOverwrite;
  ScriptOverwriteEmbedded? scriptOverwrite;

  static OverwriteEmbedded fromOverwrite(Overwrite overwrite) {
    return OverwriteEmbedded()
      ..type = overwrite.type
      ..standardOverwrite = StandardOverwriteEmbedded.fromStandardOverwrite(
        overwrite.standardOverwrite,
      )
      ..scriptOverwrite = ScriptOverwriteEmbedded.fromScriptOverwrite(
        overwrite.scriptOverwrite,
      );
  }

  Overwrite toOverwrite() {
    return Overwrite(
      type: type,
      standardOverwrite:
          standardOverwrite?.toStandardOverwrite() ?? const StandardOverwrite(),
      scriptOverwrite:
          scriptOverwrite?.toScriptOverwrite() ?? const ScriptOverwrite(),
    );
  }
}

@embedded
class SubscriptionInfoEmbedded {
  int upload = 0;
  int download = 0;
  int total = 0;
  int expire = 0;

  static SubscriptionInfoEmbedded fromSubscriptionInfo(
    SubscriptionInfo subscriptionInfo,
  ) {
    return SubscriptionInfoEmbedded()
      ..upload = subscriptionInfo.upload
      ..download = subscriptionInfo.download
      ..total = subscriptionInfo.total
      ..expire = subscriptionInfo.expire;
  }

  SubscriptionInfo toSubscriptionInfo() {
    return SubscriptionInfo(
      upload: upload,
      download: download,
      total: total,
      expire: expire,
    );
  }
}

@collection
@Name('Profile')
class ProfileCollection {
  late Id id;

  late String label;

  String? currentGroupName;

  late String url;

  DateTime? lastUpdateDate;

  @ignore
  Duration get autoUpdateDuration =>
      Duration(milliseconds: autoUpdateDurationMillis);

  int autoUpdateDurationMillis = defaultUpdateDuration.inMilliseconds;

  SubscriptionInfoEmbedded? subscriptionInfo;

  bool autoUpdate = true;

  List<StringMapEntryEmbedded> selectedMapEntries = [];

  List<String> unfoldList = [];

  late OverwriteEmbedded overwrite;

  final customRules = IsarLinks<RuleCollection>();

  @Index()
  int order = -1;

  static ProfileCollection fromProfile(Profile profile, [int? order]) {
    return ProfileCollection()
      ..id = profile.id
      ..label = profile.label
      ..currentGroupName = profile.currentGroupName
      ..url = profile.url
      ..lastUpdateDate = profile.lastUpdateDate
      ..autoUpdateDurationMillis = profile.autoUpdateDuration.inMilliseconds
      ..subscriptionInfo = profile.subscriptionInfo != null
          ? SubscriptionInfoEmbedded.fromSubscriptionInfo(
              profile.subscriptionInfo!,
            )
          : null
      ..autoUpdate = profile.autoUpdate
      ..selectedMapEntries = profile.selectedMap.entries
          .map((e) => StringMapEntryEmbedded.fromEntry(e))
          .toList()
      ..unfoldList = profile.unfoldSet.toList()
      ..overwrite = OverwriteEmbedded.fromOverwrite(profile.overwrite)
      ..order = order ?? profile.order;
  }

  Profile toProfile() {
    final selectedMap = Map.fromEntries(
      selectedMapEntries.map((e) => e.toEntry()),
    );

    return Profile(
      id: id,
      label: label,
      currentGroupName: currentGroupName,
      url: url,
      lastUpdateDate: lastUpdateDate,
      autoUpdateDuration: autoUpdateDuration,
      subscriptionInfo: subscriptionInfo?.toSubscriptionInfo(),
      autoUpdate: autoUpdate,
      selectedMap: selectedMap,
      unfoldSet: unfoldList.toSet(),
      overwrite: overwrite.toOverwrite(),
    );
  }
}

@collection
@Name('Rule')
class RuleCollection {
  late Id id;

  late String value;

  @Index()
  int order = -1;

  static RuleCollection fromRule(Rule rule, [int? order]) {
    return RuleCollection()
      ..id = rule.id
      ..value = rule.value
      ..order = order ?? rule.order;
  }

  Rule toRule() {
    return Rule(id: id, value: value);
  }
}

@collection
@Name('Script')
class ScriptCollection {
  late Id id;

  late String label;

  late DateTime lastUpdateTime;

  static ScriptCollection fromScript(Script script) {
    return ScriptCollection()
      ..id = script.id
      ..label = script.label
      ..lastUpdateTime = script.lastUpdateTime;
  }

  Script toScript() {
    return Script(id: id, label: label, lastUpdateTime: lastUpdateTime);
  }
}

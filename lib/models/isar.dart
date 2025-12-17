import 'package:fl_clash/common/utils.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:isar_community/isar.dart';

import 'clash_config.dart';

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
  late String id;
  late String value;

  static RuleEmbedded fromRule(Rule rule) {
    return RuleEmbedded()
      ..id = rule.id
      ..value = rule.value;
  }

  Rule toRule() {
    return Rule(id: id, value: value);
  }
}

@embedded
class StandardOverwriteEmbedded {
  List<RuleEmbedded> addedRules = [];
  List<String> disabledRuleIds = [];

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
  String? scriptId;

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

@collection
@Name('Profile')
class ProfileCollection {
  Id get localId => utils.fastHash(id);

  @Index(unique: true)
  late String id;

  late String label;

  String? currentGroupName;

  late String url;

  DateTime? lastUpdateDate;

  @ignore
  Duration get autoUpdateDuration =>
      Duration(milliseconds: autoUpdateDurationMillis);

  set autoUpdateDuration(Duration value) {
    autoUpdateDurationMillis = value.inMilliseconds;
  }

  late int autoUpdateDurationMillis;

  int subscriptionUpload = 0;
  int subscriptionDownload = 0;
  int subscriptionTotal = 0;
  int subscriptionExpire = 0;

  late bool autoUpdate;

  List<StringMapEntryEmbedded> selectedMapEntries = [];

  List<String> unfoldList = [];

  OverwriteEmbedded? overwrite;

  final customRules = IsarLinks<RuleCollection>();

  static ProfileCollection fromProfile(Profile profile) {
    return ProfileCollection()
      ..id = profile.id
      ..label = profile.label
      ..currentGroupName = profile.currentGroupName
      ..url = profile.url
      ..lastUpdateDate = profile.lastUpdateDate
      ..autoUpdateDuration = profile.autoUpdateDuration
      ..subscriptionUpload = profile.subscriptionInfo?.upload ?? 0
      ..subscriptionDownload = profile.subscriptionInfo?.download ?? 0
      ..subscriptionTotal = profile.subscriptionInfo?.total ?? 0
      ..subscriptionExpire = profile.subscriptionInfo?.expire ?? 0
      ..autoUpdate = profile.autoUpdate
      ..selectedMapEntries = profile.selectedMap.entries
          .map((e) => StringMapEntryEmbedded.fromEntry(e))
          .toList()
      ..unfoldList = profile.unfoldSet.toList()
      ..overwrite = OverwriteEmbedded.fromOverwrite(profile.overwrite);
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
      subscriptionInfo: SubscriptionInfo(
        upload: subscriptionUpload,
        download: subscriptionDownload,
        total: subscriptionTotal,
        expire: subscriptionExpire,
      ),
      autoUpdate: autoUpdate,
      selectedMap: selectedMap,
      unfoldSet: unfoldList.toSet(),
      overwrite: overwrite?.toOverwrite() ?? const Overwrite(),
    );
  }
}

@collection
@Name('Rule')
class RuleCollection {
  Id id = Isar.autoIncrement;

  late String value;

  Rule toRule() {
    return Rule(id: '', value: value);
  }
}

@collection
@Name('Script')
class ScriptCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String label;
}

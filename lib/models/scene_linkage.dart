class SceneRule {
  final String id;
  final String name;
  final List<String> packageNames;
  final String? profileId;
  final String? proxyName;
  final bool enable;
  final bool enableNotification;

  const SceneRule({
    required this.id,
    required this.name,
    this.packageNames = const [],
    this.profileId,
    this.proxyName,
    this.enable = true,
    this.enableNotification = true,
  });

  SceneRule copyWith({
    String? id,
    String? name,
    List<String>? packageNames,
    String? profileId,
    String? proxyName,
    bool? enable,
    bool? enableNotification,
  }) {
    return SceneRule(
      id: id ?? this.id,
      name: name ?? this.name,
      packageNames: packageNames ?? this.packageNames,
      profileId: profileId ?? this.profileId,
      proxyName: proxyName ?? this.proxyName,
      enable: enable ?? this.enable,
      enableNotification: enableNotification ?? this.enableNotification,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'packageNames': packageNames,
      'profileId': profileId,
      'proxyName': proxyName,
      'enable': enable,
      'enableNotification': enableNotification,
    };
  }

  factory SceneRule.fromJson(Map<String, dynamic> json) {
    return SceneRule(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      packageNames: (json['packageNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      profileId: json['profileId'] as String?,
      proxyName: json['proxyName'] as String?,
      enable: json['enable'] as bool? ?? true,
      enableNotification: json['enableNotification'] as bool? ?? true,
    );
  }
}

class SceneLinkageProps {
  final bool enable;
  final bool enableNotification;
  final List<SceneRule> rules;

  const SceneLinkageProps({
    this.enable = false,
    this.enableNotification = true,
    this.rules = const [],
  });

  SceneLinkageProps copyWith({
    bool? enable,
    bool? enableNotification,
    List<SceneRule>? rules,
  }) {
    return SceneLinkageProps(
      enable: enable ?? this.enable,
      enableNotification: enableNotification ?? this.enableNotification,
      rules: rules ?? this.rules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'enableNotification': enableNotification,
      'rules': rules.map((r) => r.toJson()).toList(),
    };
  }

  factory SceneLinkageProps.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SceneLinkageProps();
    return SceneLinkageProps(
      enable: json['enable'] as bool? ?? false,
      enableNotification: json['enableNotification'] as bool? ?? true,
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => SceneRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

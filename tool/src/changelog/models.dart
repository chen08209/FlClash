/// Structured changelog model shared by the parser, the renderers and the
/// `changelog.json` data file embedded in GitHub release bodies.
library;

const changelogSchemaVersion = 2;

/// Groups a changelog entry can land in, in render order.
enum ChangelogType {
  breaking('breaking', 'Breaking Changes'),
  feat('feat', 'Features'),
  fix('fix', 'Bug Fixes'),
  perf('perf', 'Performance'),
  revert('revert', 'Reverts');

  const ChangelogType(this.id, this.title);

  final String id;
  final String title;

  static ChangelogType? fromId(String value) {
    for (final type in values) {
      if (type.id == value) {
        return type;
      }
    }
    return null;
  }
}

/// A commit as read from `git log`, before any conventional-commit parsing.
class RawCommit {
  const RawCommit({
    required this.hash,
    required this.subject,
    required this.body,
  });

  final String hash;
  final String subject;
  final String body;

  String get shortHash => hash.length > 7 ? hash.substring(0, 7) : hash;
}

class ChangelogEntry {
  const ChangelogEntry({required this.id, required this.text, this.scope});

  final String id;
  final String? scope;
  final String text;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    if (scope != null) 'scope': scope,
    'text': text,
  };

  static ChangelogEntry fromJson(Map<String, dynamic> json) => ChangelogEntry(
    id: json['id'] as String,
    scope: json['scope'] as String?,
    text: json['text'] as String,
  );
}

class ChangelogGroup {
  const ChangelogGroup({required this.type, required this.entries});

  final ChangelogType type;
  final List<ChangelogEntry> entries;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.id,
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };

  static ChangelogGroup? fromJson(Map<String, dynamic> json) {
    final type = ChangelogType.fromId(json['type'] as String);
    if (type == null) {
      return null;
    }
    return ChangelogGroup(
      type: type,
      entries: (json['entries'] as List<dynamic>)
          .map(
            (entry) => ChangelogEntry.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ChangelogVersion {
  const ChangelogVersion({
    required this.version,
    required this.tag,
    required this.date,
    required this.groups,
    this.prerelease = false,
  });

  final String version;
  final String tag;
  final String date;
  final bool prerelease;
  final List<ChangelogGroup> groups;

  bool get isEmpty => groups.every((group) => group.entries.isEmpty);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'version': version,
    'tag': tag,
    'date': date,
    'prerelease': prerelease,
    'groups': groups.map((group) => group.toJson()).toList(),
  };

  static ChangelogVersion fromJson(Map<String, dynamic> json) =>
      ChangelogVersion(
        version: json['version'] as String,
        tag: json['tag'] as String,
        date: json['date'] as String,
        prerelease: json['prerelease'] as bool? ?? false,
        groups: (json['groups'] as List<dynamic>)
            .map(
              (group) => ChangelogGroup.fromJson(group as Map<String, dynamic>),
            )
            .whereType<ChangelogGroup>()
            .toList(),
      );
}

class Changelog {
  const Changelog({
    required this.versions,
    this.schemaVersion = changelogSchemaVersion,
  });

  final int schemaVersion;
  final List<ChangelogVersion> versions;

  static const empty = Changelog(versions: <ChangelogVersion>[]);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'versions': versions.map((version) => version.toJson()).toList(),
  };

  static Changelog fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int? ?? 0;
    if (schemaVersion != changelogSchemaVersion) {
      return empty;
    }
    return Changelog(
      schemaVersion: schemaVersion,
      versions: (json['versions'] as List<dynamic>)
          .map(
            (version) =>
                ChangelogVersion.fromJson(version as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

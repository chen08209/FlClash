import 'models.dart';

/// A single rendered line of a version, together with the group it belongs to.
class ChangelogItem {
  const ChangelogItem({required this.type, required this.entry});

  final ChangelogType type;
  final ChangelogEntry entry;
}

const _skipMarker = 'skip';

const _defaultTypes = <String, ChangelogType>{
  'feat': ChangelogType.feat,
  'fix': ChangelogType.fix,
  'perf': ChangelogType.perf,
  'revert': ChangelogType.revert,
};

final _subjectPattern = RegExp(r'^([a-z]+)(?:\(([^)]*)\))?(!)?:[ \t]+(.+)$');

final _trailerPattern = RegExp(
  r'^(BREAKING[ -]CHANGE|Changelog(?:-[A-Za-z0-9-]+)?|Breaking-[A-Za-z0-9-]+):[ \t]*(.*)$',
);

/// The only suffixed trailer left. Translations were removed on purpose: the
/// changelog ships English, and anything else belongs in a post-processing
/// step, not in the commit message.
const _knownSuffixedTrailer = 'Changelog-Type';

/// Turns conventional commits into changelog items.
///
/// The parser is pure: it never touches git or the filesystem, so every rule
/// below is covered by `test/tool/changelog_parser_test.dart`.
class ChangelogParser {
  final List<String> warnings = <String>[];

  List<ChangelogItem> parseAll(List<RawCommit> commits) =>
      commits.expand(parse).toList();

  List<ChangelogItem> parse(RawCommit commit) {
    final match = _subjectPattern.firstMatch(commit.subject.trim());
    if (match == null) {
      warnings.add(
        '${commit.shortHash} is not a conventional commit: ${commit.subject}',
      );
      return const <ChangelogItem>[];
    }

    final type = match.group(1)!;
    final scope = match.group(2);
    final bang = match.group(3) != null;
    final description = match.group(4)!.trim();

    final trailers = _readTrailers(commit);
    final changelog = trailers['Changelog'];
    if (changelog != null && changelog.toLowerCase() == _skipMarker) {
      return const <ChangelogItem>[];
    }

    final items = <ChangelogItem>[];
    final breakingText = trailers['BREAKING CHANGE'];
    if (bang || breakingText != null) {
      if (breakingText == null) {
        warnings.add(
          '${commit.shortHash} is marked breaking but has no '
          '"BREAKING CHANGE:" footer; using the subject instead.',
        );
      }
      items.add(
        ChangelogItem(
          type: ChangelogType.breaking,
          entry: ChangelogEntry(
            id: commit.shortHash,
            scope: _normalizeScope(scope),
            text: _text(breakingText, description),
          ),
        ),
      );
    }

    final group = _resolveType(type, trailers, commit);
    if (group != null) {
      items.add(
        ChangelogItem(
          type: group,
          entry: ChangelogEntry(
            id: commit.shortHash,
            scope: _normalizeScope(scope),
            text: _text(changelog, description),
          ),
        ),
      );
    }

    return items;
  }

  ChangelogType? _resolveType(
    String type,
    Map<String, String> trailers,
    RawCommit commit,
  ) {
    final override = trailers['Changelog-Type'];
    if (override != null) {
      final resolved = ChangelogType.fromId(override);
      if (resolved == null) {
        warnings.add(
          '${commit.shortHash} has an unknown Changelog-Type: $override',
        );
      }
      return resolved;
    }
    final byType = _defaultTypes[type];
    if (byType != null) {
      return byType;
    }
    return trailers.containsKey('Changelog') ? ChangelogType.feat : null;
  }

  /// The trailer wins over the subject, but only when it carries text: an
  /// empty `Changelog:` used to blank the entry out instead of falling back.
  String _text(String? trailer, String description) =>
      trailer == null || trailer.isEmpty ? _capitalize(description) : trailer;

  Map<String, String> _readTrailers(RawCommit commit) {
    final trailers = <String, String>{};
    String? currentKey;
    for (final line in commit.body.split('\n')) {
      final match = _trailerPattern.firstMatch(line);
      if (match != null) {
        currentKey = match
            .group(1)!
            .replaceAll('BREAKING-CHANGE', 'BREAKING CHANGE');
        _warnUnknownTrailer(currentKey, commit);
        trailers[currentKey] = match.group(2)!.trim();
        continue;
      }
      if (currentKey == null) {
        continue;
      }
      final continuation = line.trim();
      if (continuation.isEmpty) {
        currentKey = null;
        continue;
      }
      trailers[currentKey] = '${trailers[currentKey]} $continuation'.trim();
    }
    return trailers;
  }

  void _warnUnknownTrailer(String key, RawCommit commit) {
    if (key == _knownSuffixedTrailer || !key.contains('-')) {
      return;
    }
    warnings.add(
      '${commit.shortHash} uses an unsupported changelog trailer: $key. '
      'The changelog is English only; $_knownSuffixedTrailer is the only '
      'suffixed trailer left.',
    );
  }
}

/// Collapses items into the groups of one version, keeping [ChangelogType]
/// declaration order and dropping groups that ended up empty.
List<ChangelogGroup> groupItems(List<ChangelogItem> items) {
  final groups = <ChangelogGroup>[];
  for (final type in ChangelogType.values) {
    final entries = items
        .where((item) => item.type == type)
        .map((item) => item.entry)
        .toList();
    if (entries.isNotEmpty) {
      groups.add(ChangelogGroup(type: type, entries: entries));
    }
  }
  return groups;
}

String? _normalizeScope(String? scope) {
  final trimmed = scope?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}

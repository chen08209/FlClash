import 'dart:io';

import 'models.dart';

final _tagPattern = RegExp(r'^v(\d+)\.(\d+)\.(\d+)(?:-pre\.(\d+))?$');

const _fieldSeparator = '\u001f';
const _recordSeparator = '\u001e';

/// A release tag that matches the `vMAJOR.MINOR.PATCH[-pre.N]` contract.
///
/// Every other tag in the repository is ignored on purpose: `backup-pre-squash-*`
/// and similar bookkeeping tags used to leak into the generated changelog as
/// fake version sections.
class VersionTag implements Comparable<VersionTag> {
  const VersionTag({
    required this.name,
    required this.major,
    required this.minor,
    required this.patch,
    this.pre,
  });

  final String name;
  final int major;
  final int minor;
  final int patch;
  final int? pre;

  bool get isPrerelease => pre != null;

  String get version => '$major.$minor.$patch';

  static VersionTag? tryParse(String name) {
    final match = _tagPattern.firstMatch(name.trim());
    if (match == null) {
      return null;
    }
    return VersionTag(
      name: name.trim(),
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      pre: match.group(4) == null ? null : int.parse(match.group(4)!),
    );
  }

  @override
  int compareTo(VersionTag other) {
    final byMajor = major.compareTo(other.major);
    if (byMajor != 0) {
      return byMajor;
    }
    final byMinor = minor.compareTo(other.minor);
    if (byMinor != 0) {
      return byMinor;
    }
    final byPatch = patch.compareTo(other.patch);
    if (byPatch != 0) {
      return byPatch;
    }
    if (pre == null && other.pre == null) {
      return 0;
    }
    if (pre == null) {
      return 1;
    }
    if (other.pre == null) {
      return -1;
    }
    return pre!.compareTo(other.pre!);
  }

  @override
  String toString() => name;
}

class GitException implements Exception {
  GitException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The only part of the generator that shells out to git.
class Git {
  Git({this.workingDirectory});

  final String? workingDirectory;

  /// Version tags reachable from [revision], newest first.
  List<VersionTag> versionTags({String revision = 'HEAD'}) {
    final output = _run(['tag', '--merged', revision]);
    final tags = output
        .split('\n')
        .map(VersionTag.tryParse)
        .whereType<VersionTag>()
        .toList();
    tags.sort((a, b) => b.compareTo(a));
    return tags;
  }

  List<VersionTag> stableTags({String revision = 'HEAD'}) => versionTags(
    revision: revision,
  ).where((tag) => !tag.isPrerelease).toList();

  bool tagExists(String name) =>
      _run(['tag', '--list', name]).trim().isNotEmpty;

  /// Whether [name] is one of the tags [versionTags] would return.
  ///
  /// [tagExists] answers a different question — a tag on another branch exists
  /// but is not derivable here — so callers comparing against a built changelog
  /// want this one.
  bool tagIsReachable(String name, {String revision = 'HEAD'}) =>
      _run(['tag', '--merged', revision, '--list', name]).trim().isNotEmpty;

  /// `YYYY-MM-DD` of the commit a tag points at.
  String tagDate(String name) =>
      _run(['log', '-1', '--format=%cs', name]).trim();

  String head() => _run(['rev-parse', 'HEAD']).trim();

  /// Commits in `from..to`, newest first, merges excluded.
  ///
  /// A null [from] walks back to the root commit.
  List<RawCommit> commits({String? from, required String to}) {
    final range = from == null ? to : '$from..$to';
    final output = _run([
      'log',
      '--no-merges',
      '--format=%H$_fieldSeparator%s$_fieldSeparator%b$_recordSeparator',
      range,
    ]);
    return output
        .split(_recordSeparator)
        .map((record) => record.trim())
        .where((record) => record.isNotEmpty)
        .map((record) {
          final fields = record.split(_fieldSeparator);
          return RawCommit(
            hash: fields[0].trim(),
            subject: fields.length > 1 ? fields[1] : '',
            body: fields.length > 2 ? fields[2] : '',
          );
        })
        .toList();
  }

  String _run(List<String> arguments) {
    final result = Process.runSync(
      'git',
      arguments,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) {
      throw GitException('git ${arguments.join(' ')} failed: ${result.stderr}');
    }
    return result.stdout as String;
  }
}

import 'dart:convert';

import 'models.dart';

const changelogTitle = '# Changelog';

/// Everything below this marker predates the structured pipeline and is kept
/// verbatim. The generator never writes past it.
const changelogFrozenMarker = '<!-- changelog:frozen -->';

const changelogFrozenNote =
    '<!-- Entries below predate the structured pipeline. Their wording is kept as '
    'written; only the heading and list style were normalized. -->';

const releaseBeginMarker = '<!-- flclash:changelog:begin -->';
const releaseEndMarker = '<!-- flclash:changelog:end -->';

/// Opens the HTML comment that carries the structured entries to the app. The
/// update dialog reads them from the release GitHub already returns, so the
/// notes cost no request of their own and stay invisible on the release page.
const releaseJsonBeginMarker = '<!-- flclash:changelog:json';
const releaseJsonEndMarker = '-->';

const emptyVersionNote = 'Internal improvements only.';

String renderMarkdown(Changelog changelog) {
  final buffer = StringBuffer()
    ..writeln(changelogTitle)
    ..writeln();
  for (final version in changelog.versions) {
    buffer
      ..writeln(_heading(version))
      ..writeln();
    if (version.isEmpty) {
      buffer
        ..writeln(emptyVersionNote)
        ..writeln();
    }
    for (final group in version.groups) {
      buffer
        ..writeln('**${group.type.title}**')
        ..writeln();
      for (final entry in group.entries) {
        buffer.writeln('- ${_prefix(entry)}${entry.text} (${entry.id})');
      }
      buffer.writeln();
    }
  }
  buffer
    ..writeln(changelogFrozenMarker)
    ..writeln(changelogFrozenNote)
    ..writeln();
  return buffer.toString();
}

String renderRelease(ChangelogVersion version) {
  final buffer = StringBuffer()..writeln(releaseBeginMarker);
  if (version.isEmpty) {
    buffer.writeln('- $emptyVersionNote');
  }
  for (final group in version.groups) {
    buffer.writeln('### ${group.type.title}');
    for (final entry in group.entries) {
      buffer.writeln('- ${_prefix(entry)}${entry.text}');
    }
    buffer.writeln();
  }
  buffer
    ..writeln(releaseEndMarker)
    ..writeln()
    ..write(renderReleaseJson(version));
  return buffer.toString();
}

/// The same version as machine readable JSON, wrapped in an HTML comment so it
/// travels with the release body without showing up on the release page.
///
/// `>` is escaped so no entry can close the comment early, which keeps a
/// changelog line containing `-->` from truncating the payload.
String renderReleaseJson(ChangelogVersion version) {
  final payload = jsonEncode(
    Changelog(versions: <ChangelogVersion>[version]).toJson(),
  ).replaceAll('>', r'\u003e');
  return '$releaseJsonBeginMarker\n$payload\n$releaseJsonEndMarker\n';
}

/// Version headings stay the only `##` level; groups are bold lines because a
/// release carries a handful of entries and an `###` per group outweighs them.
String _heading(ChangelogVersion version) => version.date.isEmpty
    ? '## ${version.tag}'
    : '## ${version.tag} (${version.date})';

String _prefix(ChangelogEntry entry) =>
    entry.scope == null ? '' : '**${entry.scope}** ';

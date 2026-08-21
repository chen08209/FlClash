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

const telegramLimit = 900;

const emptyVersionNote = 'Internal improvements only.';

/// The structured part of `CHANGELOG.md`: title, versions, frozen marker.
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

/// GitHub release body for a single version, wrapped in the markers the app
/// uses to separate real entries from the appended download template.
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

/// Escapes the three characters Telegram's HTML parse mode treats as markup.
///
/// The caption is sent with a parse mode, so entry text is markup, not text: a
/// commit subject carrying a `<` used to be a malformed tag and Telegram
/// rejected the whole upload. HTML rather than Markdown because it is the one
/// Telegram parse mode with a defined escape — legacy Markdown has none, and a
/// subject containing a lone `*` or `_` cannot be made safe in it.
String escapeTelegramHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

/// Telegram captions are capped at 1024 characters, so the text is truncated
/// with a pointer to the full notes instead of failing the upload.
String renderTelegram(ChangelogVersion version, {required String moreUrl}) {
  final buffer = StringBuffer();
  if (version.isEmpty) {
    buffer.writeln('• ${escapeTelegramHtml(emptyVersionNote)}');
  }
  for (final group in version.groups) {
    buffer.writeln('<b>${escapeTelegramHtml(group.type.title)}</b>');
    for (final entry in group.entries) {
      buffer.writeln('• ${escapeTelegramHtml(entry.text)}');
    }
    buffer.writeln();
  }
  final text = buffer.toString().trimRight();
  if (text.length <= telegramLimit) {
    return text;
  }
  final cut = text.substring(0, telegramLimit);
  final lastBreak = cut.lastIndexOf('\n');
  // Cut on a line break so the cut never lands inside a tag; the trailing
  // pattern covers the one case that has no break to cut on, where the cut can
  // still land halfway through an entity.
  final kept = (lastBreak < 0 ? cut : cut.substring(0, lastBreak)).replaceAll(
    RegExp(r'&[A-Za-z]*$|<[^>]*$'),
    '',
  );
  return '$kept\n\n…\n$moreUrl';
}

/// Version headings stay the only `##` level; groups are bold lines because a
/// release carries a handful of entries and an `###` per group outweighs them.
String _heading(ChangelogVersion version) => version.date.isEmpty
    ? '## ${version.tag}'
    : '## ${version.tag} (${version.date})';

String _prefix(ChangelogEntry entry) =>
    entry.scope == null ? '' : '**${entry.scope}** ';

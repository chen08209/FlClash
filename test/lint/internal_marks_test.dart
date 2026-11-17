import 'dart:io';

import 'package:test/test.dart';

const _self = 'test/lint/internal_marks_test.dart';

const _internalDirs = {
  'codex-rootcause',
  'concord-wt',
  'flclash-sync',
  'lead-tools',
};
const _internalNotes = {
  'REVIEW-QUEUE',
  'HOST-HOLD',
  'SHARED-JOBS',
  'COORDINATION.md',
  'known-gaps.md',
  'main-regressions.md',
};
final _notePrefix = RegExp(r'^(?:REPORT|BRIEF|HANDOVER|PLAN|VM-BUSY)-[A-Z0-9]');

/// After `cl`, a vowel starts an English word (`clear_`, `close-`, `clash_`),
/// not an agent prefix; `cxx` is C++.
final _runName = RegExp(
  r'^(?:cx(?!x[_-])[a-z0-9]{0,3}|cl[b-df-hj-np-tv-z0-9][a-z0-9]{0,2}|cl[ouy])'
  r'[_-][A-Za-z0-9]',
);
final _workLineCode = RegExp(
  r'^(?:TestP[0-9][A-Z]|P[0-9]_[A-Z]|p[0-9][_-][a-z])',
);
final _resultDir = RegExp(r'(?<![A-Za-z0-9_/.\-])(?:evidence|cb)/');
final _word = RegExp(r'[A-Za-z0-9_.\-]+');

/// Mirrors `internal_marks` in Concord's `xtask/src/public_tree.rs`.
List<String> internalMarks(String line) {
  final marks = <String>[];
  for (final match in _word.allMatches(line)) {
    final word = _trimDots(match[0]!);
    if (_kind(word) case final kind?) marks.add('`$word` is $kind');
  }
  for (final match in _resultDir.allMatches(line)) {
    marks.add('`${match[0]}` is an internal result directory');
  }
  return marks;
}

String _trimDots(String word) => word.replaceAll(RegExp(r'^\.+|\.+$'), '');

String? _kind(String word) {
  if (_internalDirs.contains(word)) return 'an internal directory';
  if (_internalNotes.contains(word) || _notePrefix.hasMatch(word)) {
    return 'an internal note';
  }
  if (_runName.hasMatch(word)) return 'an internal run name';
  if (_workLineCode.hasMatch(word)) return 'an internal work-line code';
  return null;
}

bool _skipped(String path) =>
    path == _self ||
    path.contains('/vendor/') ||
    path.endsWith('.lock') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.contains('/generated/');

void main() {
  test('reports each internal name by kind', () {
    for (final (line, kind) in [
      ('// generator in codex-rootcause/x.go', 'an internal directory'),
      ('worktree concord-wt/x', 'an internal directory'),
      ('see REVIEW-QUEUE', 'an internal note'),
      ('as REPORT-H says', 'an internal note'),
      ('(bench clw_rec_win_1)', 'an internal run name'),
      ('branch clr-quinn-ack', 'an internal run name'),
      ('cxxe_cid_2 and', 'an internal run name'),
      ('clu_jobs', 'an internal run name'),
      ("-run '^TestP6Vectors\$'", 'an internal work-line code'),
      ('(P6_AUTH)', 'an internal work-line code'),
      ('place p7_vectors_test.go', 'an internal work-line code'),
      ('cd evidence/x && go run .', 'an internal result directory'),
      ('read cb/x', 'an internal result directory'),
    ]) {
      final found = internalMarks(line);
      expect(found, hasLength(1), reason: line);
      expect(found.single, endsWith(kind), reason: line);
    }
  });

  test('passes names shaped like internal ones', () {
    for (final line in [
      'clear_failure close_all clash_config.dart client_h2 clip-path',
      'cl_len cl-status cx_ cl_ clap_builder cxx_std_17 claude-code',
      'clamp_value cloud_config clock_offset clone_from class_name',
      'DOMAIN,x.a.com,P1 and MATCH,P7; P256_KEY; p99_latency; p50-rtt',
      'TestPlain, TestP256, PLAN-, REPORT-, a report-card',
      'src/evidence/x, ./cb/y, abcb/z, the lead byte, SIMD lanes',
      'https://example.com/cb/x and fixtures/evidence/y',
    ]) {
      expect(internalMarks(line), isEmpty, reason: line);
    }
  });

  test('no tracked file names the project coordination', () {
    final listed = Process.runSync('git', ['ls-files', '-z']);
    expect(listed.exitCode, 0, reason: '${listed.stderr}');
    final offenders = <String>[];
    for (final path in (listed.stdout as String).split('\x00')) {
      if (path.isEmpty || _skipped(path)) continue;
      final file = File(path);
      if (!file.existsSync()) continue;
      final String text;
      try {
        text = file.readAsStringSync();
      } on FileSystemException {
        continue;
      }
      final lines = text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        for (final mark in internalMarks(lines[i])) {
          offenders.add('$path:${i + 1}: $mark');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}

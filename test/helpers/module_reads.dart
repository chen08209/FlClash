import 'dart:convert';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:mocktail/mocktail.dart';

import 'core_mocks.dart';

/// What `mitm.readModule` answers, in the Core's JSON; only what a test sets
/// differs from a module that adds nothing.
JsonMap moduleRead({
  String format = 'surge',
  JsonMap meta = const {},
  JsonMap? off,
  List<JsonMap> arguments = const [],
  List<JsonMap> resources = const [],
  List<int> declaredScripts = const [],
  bool asksConsent = false,
  Map<String, List<JsonMap>> issues = const {},
  Map<String, List<JsonMap>> views = const {},
  List<JsonMap> rules = const [],
  List<JsonMap> ruleSets = const [],
  JsonMap network = const {},
  List<JsonMap> ignored = const [],
}) => {
  'format': format,
  'meta': meta,
  'off': ?off,
  'arguments': arguments,
  'resources': resources,
  'declaredScripts': declaredScripts,
  'asksConsent': asksConsent,
  'issues': issues,
  'views': views,
  'rules': rules,
  'ruleSets': ruleSets,
  'network': network,
  'ignored': ignored,
};

JsonMap lineEntry(int index, MitmLineView view) => {
  'index': index,
  'view': jsonDecode(jsonEncode(view)),
};

JsonMap lineIssue(int index, String message) => {
  'index': index,
  'kind': 'invalid',
  'message': message,
};

JsonMap scriptResource(String url, int line) => {
  'url': url,
  'kind': 'script',
  'lines': [line],
};

JsonMap moduleRule(
  int line,
  String rule,
  String policy, {
  bool builtin = true,
  bool noResolve = false,
  bool extendedMatching = false,
  bool requiresResolve = false,
}) => {
  'line': line,
  'rule': rule,
  'policy': {builtin ? 'builtin' : 'named': policy},
  'noResolve': noResolve,
  'extendedMatching': extendedMatching,
  'requiresResolve': requiresResolve,
};

MitmModuleDetails moduleDetails(String text, JsonMap read) {
  final parsed = MitmModuleRead.fromJson(read);
  return mitmModuleDetailsOf(
    text,
    parsed,
    ModelApi.mitmCheckOf({'issues': parsed.issues, 'views': parsed.views}),
  );
}

void stubModuleReads(
  MockCoreApi api,
  JsonMap Function(String text, Map<String, String> arguments) read,
) {
  when(
    () => api.readMitmModule(
      any(),
      arguments: any(named: 'arguments'),
      attachments: any(named: 'attachments'),
      language: any(named: 'language'),
    ),
  ).thenAnswer(
    (invocation) async => read(
      invocation.positionalArguments.first as String,
      invocation.namedArguments[#arguments] as Map<String, String>? ?? const {},
    ),
  );
}

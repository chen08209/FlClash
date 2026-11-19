part of 'dto.dart';

enum MitmStatus {
  informational('1xx'),
  success('2xx'),
  redirection('3xx'),
  clientError('4xx'),
  serverError('5xx'),
  failed('failed'),
  pending('pending'),
  unknown('');

  final String wire;

  const MitmStatus(this.wire);

  static MitmStatus parse(Object? wire) => values.firstWhere(
    (status) => status.wire == wire,
    orElse: () => MitmStatus.unknown,
  );
}

enum MitmKind {
  json,
  html,
  script,
  css,
  image,
  font,
  media,
  text,
  other;

  static MitmKind parse(Object? name) => _enum(values, name, MitmKind.other);
}

/// An empty list or an absent field lets every exchange through; a list keeps
/// the exchanges matching any of its items. Times are Unix milliseconds.
@immutable
class MitmFilter {
  final List<MitmStatus> statuses;
  final List<String> methods;
  final List<MitmKind> kinds;
  final List<String> hosts;
  final List<String> apps;
  final bool? rewritten;
  final int? slowMs;
  final String? text;
  final int? from;
  final int? to;

  const MitmFilter({
    this.statuses = const [],
    this.methods = const [],
    this.kinds = const [],
    this.hosts = const [],
    this.apps = const [],
    this.rewritten,
    this.slowMs,
    this.text,
    this.from,
    this.to,
  });

  JsonMap toJson() => {
    if (statuses.isNotEmpty)
      'statuses': [for (final status in statuses) status.wire],
    if (methods.isNotEmpty) 'methods': methods,
    if (kinds.isNotEmpty) 'kinds': [for (final kind in kinds) kind.name],
    if (hosts.isNotEmpty) 'hosts': hosts,
    if (apps.isNotEmpty) 'apps': apps,
    'rewritten': ?rewritten,
    'slowMs': ?slowMs,
    'text': ?text,
    'from': ?from,
    'to': ?to,
  };
}

@immutable
class MitmApp {
  final String process;
  final String processPath;
  final int? uid;

  const MitmApp({required this.process, this.processPath = '', this.uid});

  factory MitmApp.fromJson(JsonMap json) => MitmApp(
    process: json['process'] as String,
    processPath: json['process-path'] as String? ?? '',
    uid: json['uid'] as int?,
  );
}

/// [start] is RFC 3339. Durations are in milliseconds; one still pending has
/// waited that long when it was listed.
@immutable
class MitmExchangeSummaryDto {
  final int id;
  final String start;
  final bool pending;
  final int duration;
  final String method;
  final String url;
  final int status;
  final int requestSize;
  final int responseSize;
  final String error;
  final String host;
  final String path;
  final String contentType;
  final MitmStatus statusClass;
  final MitmKind kind;
  final bool rewritten;
  final List<String> actionKinds;
  final String answer;
  final int? connectionId;
  final MitmApp? app;

  const MitmExchangeSummaryDto({
    required this.id,
    required this.start,
    this.pending = false,
    required this.duration,
    required this.method,
    required this.url,
    required this.status,
    required this.requestSize,
    required this.responseSize,
    this.error = '',
    required this.host,
    required this.path,
    this.contentType = '',
    required this.statusClass,
    required this.kind,
    this.rewritten = false,
    this.actionKinds = const [],
    this.answer = '',
    this.connectionId,
    this.app,
  });

  factory MitmExchangeSummaryDto.fromJson(JsonMap json) =>
      MitmExchangeSummaryDto(
        id: json['id'] as int,
        start: json['start'] as String,
        pending: json['pending'] as bool? ?? false,
        duration: json['duration'] as int,
        method: json['method'] as String,
        url: json['url'] as String,
        status: json['status'] as int,
        requestSize: json['request-size'] as int,
        responseSize: json['response-size'] as int,
        error: json['error'] as String? ?? '',
        host: json['host'] as String,
        path: json['path'] as String,
        contentType: json['content-type'] as String? ?? '',
        statusClass: MitmStatus.parse(json['status-class']),
        kind: MitmKind.parse(json['kind']),
        rewritten: json['rewritten'] as bool? ?? false,
        actionKinds: _strings(json['action-kinds']),
        answer: json['answer'] as String? ?? '',
        connectionId: json['connection-id'] as int?,
        app: switch (_optionalMap(json['app'])) {
          final app? => MitmApp.fromJson(app),
          null => null,
        },
      );
}

Map<K, int> _counts<K>(Object? value, K Function(String key) keyOf) => {
  for (final MapEntry(:key, :value) in _map(value).entries)
    keyOf(key): value as int,
};

/// Each dimension counts the matches of the rest of the filter.
@immutable
class MitmFacets {
  final Map<MitmStatus, int> status;
  final Map<String, int> method;
  final Map<MitmKind, int> kind;

  /// Keyed by process; `''` counts the exchanges of no known app.
  final Map<String, int> app;

  const MitmFacets({
    required this.status,
    required this.method,
    required this.kind,
    required this.app,
  });

  factory MitmFacets.fromJson(JsonMap json) => MitmFacets(
    status: _counts(json['status'], MitmStatus.parse),
    method: _counts(json['method'], (key) => key),
    kind: _counts(json['kind'], MitmKind.parse),
    app: _counts(json['app'], (key) => key),
  );
}

@immutable
class MitmRateBucket {
  final int time;
  final int requests;
  final int errors;

  const MitmRateBucket({
    required this.time,
    required this.requests,
    required this.errors,
  });

  factory MitmRateBucket.fromJson(JsonMap json) => MitmRateBucket(
    time: json['t'] as int,
    requests: json['requests'] as int,
    errors: json['errors'] as int,
  );
}

/// One page of `mitm.query`, newest first.
@immutable
class MitmQueryAnswer {
  final bool capturing;

  /// When the oldest exchange held started, or capture was turned on
  /// (RFC 3339).
  final String? since;

  /// The `since` that asks for what changes after this answer.
  final int version;

  /// The lowest id held; a client drops the ids it kept below it.
  final int oldest;
  final int held;
  final int matched;
  final List<MitmExchangeSummaryDto> exchanges;

  /// The `before` of the next page, absent on the last.
  final int? next;

  /// Changed since `since` and no longer matching.
  final List<int> unmatched;
  final MitmFacets? facets;
  final List<MitmRateBucket>? rate;
  final int? medianDuration;

  const MitmQueryAnswer({
    required this.capturing,
    this.since,
    required this.version,
    required this.oldest,
    required this.held,
    required this.matched,
    required this.exchanges,
    this.next,
    this.unmatched = const [],
    this.facets,
    this.rate,
    this.medianDuration,
  });

  factory MitmQueryAnswer.fromJson(JsonMap json) => MitmQueryAnswer(
    capturing: json['capturing'] as bool,
    since: json['since'] as String?,
    version: json['version'] as int,
    oldest: json['oldest'] as int,
    held: json['held'] as int,
    matched: json['matched'] as int,
    exchanges: _list(json['exchanges'], MitmExchangeSummaryDto.fromJson),
    next: json['next'] as int?,
    unmatched: [
      for (final id in json['unmatched'] as List? ?? const []) id as int,
    ],
    facets: switch (_optionalMap(json['facets'])) {
      final facets? => MitmFacets.fromJson(facets),
      null => null,
    },
    rate: json['rate'] == null
        ? null
        : _list(json['rate'], MitmRateBucket.fromJson),
    medianDuration: json['median-duration'] as int?,
  );
}

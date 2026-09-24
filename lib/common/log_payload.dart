// Mirrors the wording of the routing and dial-failure lines in mihomo's
// tunnel/tunnel.go; a line that stops matching falls back to plain text.
const _endpoint = r'((?:\[[^\]]+\]|[^\s\[\]()]+):\d+|mihomo)(?:\((.*)\))?';

final _tagPattern = RegExp(r'^\[([^\]]+)\] (.+)$', dotAll: true);

final _routePattern = RegExp(
  '^$_endpoint --> (\\S+) '
  "(?:(?:match (.+?)|(doesn't match any rule)) )?using (.+)\$",
);

final _dialPattern = RegExp(
  '^dial (.+?) (?:\\(match (.+?)\\) )?$_endpoint --> (\\S+) error: (.+)\$',
  dotAll: true,
);

class LogRoute {
  final String source;
  final String sourceDetail;
  final String destination;
  final String rule;
  final String proxy;
  final String error;

  const LogRoute({
    required this.source,
    this.sourceDetail = '',
    required this.destination,
    this.rule = '',
    required this.proxy,
    this.error = '',
  });
}

class LogPayload {
  final String tag;
  final String message;
  final LogRoute? route;

  const LogPayload({this.tag = '', required this.message, this.route});

  factory LogPayload.parse(String payload) {
    final tagged = _tagPattern.firstMatch(payload);
    if (tagged == null) {
      return LogPayload(message: payload);
    }
    final message = tagged[2]!;
    return LogPayload(
      tag: tagged[1]!,
      message: message,
      route: _parseRoute(message),
    );
  }

  static LogRoute? _parseRoute(String message) {
    final route = _routePattern.firstMatch(message);
    if (route != null) {
      return LogRoute(
        source: route[1]!,
        sourceDetail: route[2] ?? '',
        destination: route[3]!,
        rule: route[4] ?? route[5] ?? '',
        proxy: route[6]!,
      );
    }
    final dial = _dialPattern.firstMatch(message);
    if (dial != null) {
      return LogRoute(
        proxy: dial[1]!,
        rule: dial[2] ?? '',
        source: dial[3]!,
        sourceDetail: dial[4] ?? '',
        destination: dial[5]!,
        error: dial[6]!,
      );
    }
    return null;
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

typedef IpQualityFailure = ({
  IpQualitySource source,
  IpQualitySourceStatus status,
});

class IpQualityLookupException implements Exception {
  const IpQualityLookupException(this.failures);

  final List<IpQualityFailure> failures;
}

class _SourceFailure implements Exception {
  const _SourceFailure(this.status);

  final IpQualitySourceStatus status;
}

typedef _Answer = ({IpQuality quality, bool inferred});

/// A later wave only starts while the earlier ones are still unanswered, so
/// the sources with the tightest free quotas are asked last and rarely.
const _waves = [
  [IpQualitySource.identMe, IpQualitySource.ipApiCom, IpQualitySource.ipQuery],
  [IpQualitySource.ipLocate],
  [IpQualitySource.ipApiIs],
  [IpQualitySource.proxyCheck],
];

Future<IpQuality> lookupIpQuality(
  Dio dio,
  String ip, {
  required CancelToken cancelToken,
  Duration timeout = const Duration(seconds: 8),
  Duration hedge = const Duration(seconds: 1),
}) {
  return _Lookup(dio, ip, cancelToken, timeout, hedge).run();
}

class _Lookup {
  _Lookup(this.dio, this.ip, this.cancelToken, this.timeout, this.hedge);

  final Dio dio;
  final String ip;
  final CancelToken cancelToken;
  final Duration timeout;
  final Duration hedge;

  final _completer = Completer<IpQuality>();
  final _failures = <IpQualityFailure>[];
  IpQuality? _fallback;
  int _wave = 0;
  int _inFlight = 0;
  Timer? _timer;

  Future<IpQuality> run() {
    _launch();
    return _completer.future;
  }

  void _launch() {
    _timer?.cancel();
    if (_completer.isCompleted) {
      return;
    }
    if (_wave == _waves.length) {
      _settle();
      return;
    }
    final sources = _waves[_wave++];
    _inFlight += sources.length;
    for (final source in sources) {
      unawaited(
        _query(
          dio,
          source,
          ip,
          cancelToken,
          timeout,
        ).then(_onAnswer, onError: (Object error) => _onError(source, error)),
      );
    }
    if (_wave < _waves.length) {
      _timer = Timer(hedge, _launch);
    }
  }

  void _onAnswer(_Answer answer) {
    _inFlight--;
    if (_completer.isCompleted) {
      return;
    }
    if (answer.inferred) {
      _fallback ??= answer.quality;
      _advance();
      return;
    }
    _timer?.cancel();
    _completer.complete(answer.quality);
    cancelToken.cancel();
  }

  void _onError(IpQualitySource source, Object error) {
    _inFlight--;
    if (_completer.isCompleted) {
      return;
    }
    _failures.add((source: source, status: _statusOf(error)));
    _advance();
  }

  void _advance() {
    if (_inFlight == 0) {
      _launch();
    }
  }

  void _settle() {
    if (_inFlight > 0) {
      return;
    }
    final fallback = _fallback;
    if (fallback != null) {
      _completer.complete(fallback);
      return;
    }
    _failures.sort((a, b) => a.source.index.compareTo(b.source.index));
    _completer.completeError(IpQualityLookupException(_failures));
  }
}

Future<_Answer> _query(
  Dio dio,
  IpQualitySource source,
  String ip,
  CancelToken cancelToken,
  Duration timeout,
) async {
  final response = await dio
      .get<String>(
        _urlOf(source, ip),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      )
      .timeout(timeout);
  if (response.statusCode == HttpStatus.tooManyRequests) {
    throw const _SourceFailure(IpQualitySourceStatus.rateLimited);
  }
  if (response.statusCode != HttpStatus.ok) {
    throw const _SourceFailure(IpQualitySourceStatus.failed);
  }
  final json = jsonDecode(response.data ?? '') as Map<String, dynamic>;
  final answer = _parse(source, ip, json);
  if (answer == null) {
    throw const _SourceFailure(IpQualitySourceStatus.noType);
  }
  return answer;
}

IpQualitySourceStatus _statusOf(Object error) {
  return switch (error) {
    _SourceFailure(:final status) => status,
    TimeoutException() => IpQualitySourceStatus.timeout,
    DioException(
      type: DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout,
    ) =>
      IpQualitySourceStatus.timeout,
    _ => IpQualitySourceStatus.failed,
  };
}

String _urlOf(IpQualitySource source, String ip) {
  return switch (source) {
    IpQualitySource.identMe => 'https://ident.me/json',
    IpQualitySource.ipApiCom =>
      'http://ip-api.com/json/$ip?fields=status,isp,org,as,mobile,proxy,hosting',
    IpQualitySource.ipQuery => 'https://api.ipquery.io/$ip?format=json',
    IpQualitySource.ipLocate => 'https://iplocate.io/api/lookup/$ip',
    IpQualitySource.proxyCheck => 'https://proxycheck.io/v3/$ip',
    IpQualitySource.ipApiIs => 'https://api.ipapi.is/?q=$ip',
  };
}

_Answer? _parse(IpQualitySource source, String ip, Map<String, dynamic> json) {
  return switch (source) {
    IpQualitySource.identMe => _fromIdentMe(ip, json),
    IpQualitySource.ipApiCom => _fromIpApiCom(ip, json),
    IpQualitySource.ipQuery => _fromIpQuery(ip, json),
    IpQualitySource.ipLocate => _fromIpLocate(ip, json),
    IpQualitySource.proxyCheck => _fromProxyCheck(ip, json),
    IpQualitySource.ipApiIs => _fromIpApiIs(ip, json),
  };
}

_Answer? _fromIdentMe(String ip, Map<String, dynamic> json) {
  if (json['ip'] != ip) {
    throw const _SourceFailure(IpQualitySourceStatus.ipMismatch);
  }
  return _quality(
    ip,
    IpQualitySource.identMe,
    _declaredType(json['type']),
    organization: _text(json['aso']),
    asn: _asn(json['asn']),
  );
}

_Answer? _fromIpApiCom(String ip, Map<String, dynamic> json) {
  if (json['status'] != 'success') {
    throw const _SourceFailure(IpQualitySourceStatus.failed);
  }
  final type = _pickType(
    hosting: _flag(json['hosting']),
    mobile: _flag(json['mobile']),
  );
  return _quality(
    ip,
    IpQualitySource.ipApiCom,
    type ?? IpType.residential,
    inferred: type == null,
    organization: _text(json['org']) ?? _text(json['isp']),
    asn: _asn(json['as']),
    isProxy: _flag(json['proxy']),
  );
}

_Answer? _fromIpQuery(String ip, Map<String, dynamic> json) {
  final risk = _object(json['risk']);
  final isp = _object(json['isp']);
  final type = _pickType(
    hosting: _flag(risk['is_datacenter']),
    mobile: _flag(risk['is_mobile']),
  );
  return _quality(
    ip,
    IpQualitySource.ipQuery,
    type ?? IpType.residential,
    inferred: type == null,
    organization: _text(isp['org']) ?? _text(isp['isp']),
    asn: _asn(isp['asn']),
    isProxy: _flag(risk['is_proxy']),
    isVpn: _flag(risk['is_vpn']),
    isTor: _flag(risk['is_tor']),
  );
}

_Answer? _fromIpLocate(String ip, Map<String, dynamic> json) {
  final privacy = _object(json['privacy']);
  final company = _object(json['company']);
  final asn = _object(json['asn']);
  return _quality(
    ip,
    IpQualitySource.ipLocate,
    _pickType(
      hosting: _flag(privacy['is_hosting']),
      declared: _declaredType(company['type']) ?? _declaredType(asn['type']),
    ),
    organization: _text(company['name']) ?? _text(asn['name']),
    asn: _asn(asn['asn']),
    isProxy: _flag(privacy['is_proxy']),
    isVpn: _flag(privacy['is_vpn']),
    isTor: _flag(privacy['is_tor']),
    isAbuser: _flag(privacy['is_abuser']),
  );
}

_Answer? _fromProxyCheck(String ip, Map<String, dynamic> json) {
  final status = json['status'];
  if (status == 'denied') {
    throw const _SourceFailure(IpQualitySourceStatus.rateLimited);
  }
  if (status != 'ok' && status != 'warning') {
    throw const _SourceFailure(IpQualitySourceStatus.failed);
  }
  final result = _object(json[ip]);
  final network = _object(result['network']);
  final detections = _object(result['detections']);
  final networkType = network['type'];
  return _quality(
    ip,
    IpQualitySource.proxyCheck,
    _pickType(
      hosting: _flag(detections['hosting']) || networkType == 'Hosting',
      mobile: networkType == 'Wireless',
      declared: switch (networkType) {
        'Residential' => IpType.residential,
        'Business' => IpType.business,
        _ => null,
      },
    ),
    organization: _text(network['organisation']),
    asn: _asn(network['asn']),
    isProxy: _flag(detections['proxy']),
    isVpn: _flag(detections['vpn']),
    isTor: _flag(detections['tor']),
  );
}

_Answer? _fromIpApiIs(String ip, Map<String, dynamic> json) {
  final company = _object(json['company']);
  final asn = _object(json['asn']);
  return _quality(
    ip,
    IpQualitySource.ipApiIs,
    _pickType(
      hosting: _flag(json['is_datacenter']),
      mobile: _flag(json['is_mobile']),
      declared: _declaredType(company['type']) ?? _declaredType(asn['type']),
    ),
    organization: _text(company['name']) ?? _text(asn['org']),
    asn: _asn(asn['asn']),
    isProxy: _flag(json['is_proxy']),
    isVpn: _flag(json['is_vpn']),
    isTor: _flag(json['is_tor']),
    isAbuser: _flag(json['is_abuser']),
  );
}

/// An inferred type is the source's silence about hosting and mobile taken
/// as residential; it only stands in when no source states a type.
_Answer? _quality(
  String ip,
  IpQualitySource source,
  IpType? type, {
  bool inferred = false,
  String? organization,
  int? asn,
  bool isProxy = false,
  bool isVpn = false,
  bool isTor = false,
  bool isAbuser = false,
}) {
  if (type == null) {
    return null;
  }
  final quality = IpQuality(
    ip: ip,
    source: source,
    type: type,
    organization: organization,
    asn: asn,
    isProxy: isProxy,
    isVpn: isVpn,
    isTor: isTor,
    isAbuser: isAbuser,
  );
  return (quality: quality, inferred: inferred);
}

IpType? _pickType({
  required bool hosting,
  bool mobile = false,
  IpType? declared,
}) {
  if (hosting || declared == IpType.hosting) {
    return IpType.hosting;
  }
  if (mobile) {
    return IpType.mobile;
  }
  return declared;
}

IpType? _declaredType(Object? value) {
  return switch (value) {
    'isp' => IpType.residential,
    'business' || 'education' || 'government' || 'banking' => IpType.business,
    'hosting' => IpType.hosting,
    _ => null,
  };
}

Map<String, dynamic> _object(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

bool _flag(Object? value) => value == true;

String? _text(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

int? _asn(Object? value) {
  final asn = switch (value) {
    final int number => number,
    final String text => int.tryParse(
      RegExp(r'\d+').firstMatch(text)?[0] ?? '',
    ),
    _ => null,
  };
  return asn == 0 ? null : asn;
}

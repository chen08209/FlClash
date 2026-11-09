import 'dart:async';

import 'package:fl_clash/enum/enum.dart';

/// A Core method by its wire name, `area.verb` as `core/protocol.go` names it.
enum CoreMethod {
  coreInit('core.init'),
  coreInitialized('core.initialized'),
  coreGc('core.gc'),
  coreMemory('core.memory'),
  coreCrash('core.crash'),
  configSetup('config.setup'),
  configUpdate('config.update'),
  configValidate('config.validate'),
  configDecrypt('config.decrypt'),
  configRead('config.read'),
  profileBase('profile.base'),
  profileOutbounds('profile.outbounds'),
  profileBuild('profile.build'),
  profileClearEffect('profile.clearEffect'),
  proxyList('proxy.list'),
  proxySelect('proxy.select'),
  proxyDefinition('proxy.definition'),
  proxyTestDelay('proxy.testDelay'),
  proxyValidate('proxy.validate'),
  proxyConvert('proxy.convert'),
  shareLinkEncode('shareLink.encode'),
  shareLinkDecode('shareLink.decode'),
  filterValidate('filter.validate'),
  providerList('provider.list'),
  providerGet('provider.get'),
  providerUpdate('provider.update'),
  providerSideLoad('provider.sideLoad'),
  ruleSetDump('ruleSet.dump'),
  ruleSetCompile('ruleSet.compile'),
  geoUpdate('geo.update'),
  trafficCurrent('traffic.current'),
  trafficTotal('traffic.total'),
  trafficReset('traffic.reset'),
  connectionList('connection.list'),
  connectionCount('connection.count'),
  connectionClose('connection.close'),
  connectionCloseAll('connection.closeAll'),
  connectionReset('connection.reset'),
  dnsClearCache('dns.clearCache'),
  networkChanged('network.changed'),
  logStart('log.start'),
  logStop('log.stop'),
  listenerStart('listener.start'),
  listenerStop('listener.stop'),
  routeWatch('route.watch'),
  routeCheck('route.check'),
  probeOutboundIp('probe.outboundIp'),
  probeServices('probe.services'),
  mitmCertificate('mitm.certificate'),
  mitmGenerateCertificate('mitm.generateCertificate'),
  mitmValidate('mitm.validate'),
  mitmIssueCertificate('mitm.issueCertificate'),
  mitmRunScript('mitm.runScript'),
  mitmExchanges('mitm.exchanges'),
  mitmExchange('mitm.exchange'),
  mitmBody('mitm.body'),

  /// The envelope of the Core's event batches, never called.
  message('message');

  final String wireName;

  const CoreMethod(this.wireName);

  static final _byWireName = {
    for (final method in values) method.wireName: method,
  };

  static CoreMethod fromWireName(String name) {
    final method = _byWireName[name];
    if (method == null) {
      throw ArgumentError.value(name, 'name', 'Unknown Core method');
    }
    return method;
  }
}

class CoreMethodCall {
  final String? id;
  final CoreMethod method;
  final Object? arguments;

  const CoreMethodCall({this.id, required this.method, this.arguments});

  factory CoreMethodCall.fromJson(Map<String, Object?> json) {
    return CoreMethodCall(
      id: json['id'] as String?,
      method: CoreMethod.fromWireName(json['method'] as String),
      arguments: json['arguments'],
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'method': method.wireName,
      'arguments': arguments,
    };
  }
}

class CoreMethodError {
  final String code;
  final String message;
  final Object? details;

  const CoreMethodError({
    required this.code,
    required this.message,
    this.details,
  });

  factory CoreMethodError.fromJson(Map<String, Object?> json) {
    return CoreMethodError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'],
    );
  }

  Map<String, Object?> toJson() {
    return {'code': code, 'message': message, 'details': details};
  }
}

class CoreMethodResponse {
  final String? id;
  final Object? result;
  final CoreMethodError? error;

  /// Where the Core wrote the whole response instead; see `spill.dart`.
  final String? file;

  const CoreMethodResponse({this.id, this.result, this.error, this.file});

  factory CoreMethodResponse.fromJson(Map<String, Object?> json) {
    final error = json['error'];
    return CoreMethodResponse(
      id: json['id'] as String?,
      result: json['result'],
      error: error is Map
          ? CoreMethodError.fromJson(Map<String, Object?>.from(error))
          : null,
      file: json['file'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'result': result,
      if (error != null) 'error': error!.toJson(),
      if (file != null) 'file': file,
    };
  }

  T? unwrap<T>() {
    final error = this.error;
    if (error != null) {
      throw CoreMethodException(
        code: error.code,
        message: error.message,
        details: error.details,
      );
    }
    return result as T?;
  }
}

class CoreMethodException implements Exception {
  final String code;
  final String message;
  final Object? details;

  const CoreMethodException({
    required this.code,
    required this.message,
    this.details,
  });

  bool get isCoreUnavailable => const {
    'transport_disconnected',
    'transport_error',
    'core_unavailable',
  }.contains(code);

  @override
  String toString() => 'CoreMethodException($code, $message, $details)';
}

/// A Core that never answered, as opposed to one that answered with an error.
bool isUnansweredCoreError(Object? error) => switch (error) {
  TimeoutException() => true,
  CoreMethodException(:final code) =>
    code == 'no_response' || code == 'core_unavailable',
  _ => false,
};

LogLevel coreFailureLogLevel(Object? error) {
  if (error is TimeoutException) {
    return LogLevel.debug;
  }
  if (error is! CoreMethodException) {
    return LogLevel.warning;
  }
  return error.isCoreUnavailable ? LogLevel.debug : LogLevel.warning;
}

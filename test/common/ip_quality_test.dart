import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _ip = '203.0.113.9';

const _hosts = {
  IpQualitySource.identMe: 'ident.me',
  IpQualitySource.ipApiCom: 'ip-api.com',
  IpQualitySource.ipQuery: 'api.ipquery.io',
  IpQualitySource.ipLocate: 'iplocate.io',
  IpQualitySource.proxyCheck: 'proxycheck.io',
  IpQualitySource.ipApiIs: 'api.ipapi.is',
};

typedef _Reply = ({int status, Object? body, Duration delay});

_Reply _ok(Object body, [Duration delay = Duration.zero]) =>
    (status: 200, body: body, delay: delay);

_Reply _status(int status) =>
    (status: status, body: null, delay: Duration.zero);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.replies);

  final Map<String, _Reply> replies;
  final requested = <Uri>[];
  final cancelled = <String>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requested.add(options.uri);
    final reply = replies[options.uri.host] ?? _status(503);
    final completer = Completer<ResponseBody>();
    final timer = Timer(reply.delay, () {
      completer.complete(
        ResponseBody.fromString(
          reply.body == null ? '' : jsonEncode(reply.body),
          reply.status,
        ),
      );
    });
    cancelFuture?.then((_) {
      if (completer.isCompleted) {
        return;
      }
      timer.cancel();
      cancelled.add(options.uri.host);
      completer.completeError(
        DioException.requestCancelled(
          requestOptions: options,
          reason: 'cancelled',
        ),
      );
    });
    return completer.future;
  }

  @override
  void close({bool force = false}) {}
}

({_Adapter adapter, Future<IpQuality> result}) _lookup(
  Map<String, _Reply> replies, {
  Duration timeout = const Duration(seconds: 8),
  Duration hedge = const Duration(seconds: 1),
}) {
  final adapter = _Adapter(replies);
  final dio = Dio()..httpClientAdapter = adapter;
  addTearDown(dio.close);
  return (
    adapter: adapter,
    result: lookupIpQuality(
      dio,
      _ip,
      cancelToken: CancelToken(),
      timeout: timeout,
      hedge: hedge,
    ),
  );
}

void main() {
  final samples = <IpQualitySource, (Object, IpQuality)>{
    IpQualitySource.identMe: (
      {
        'ip': _ip,
        'aso': 'Example Broadband',
        'asn': 64500,
        'type': 'isp',
        'cc': 'GB',
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.identMe,
        type: IpType.residential,
        organization: 'Example Broadband',
        asn: 64500,
      ),
    ),
    IpQualitySource.ipApiCom: (
      {
        'status': 'success',
        'isp': 'Example Hosting',
        'org': 'Example Cloud',
        'as': 'AS64501 Example Hosting',
        'mobile': false,
        'proxy': true,
        'hosting': true,
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipApiCom,
        type: IpType.hosting,
        organization: 'Example Cloud',
        asn: 64501,
        isProxy: true,
      ),
    ),
    IpQualitySource.ipQuery: (
      {
        'ip': _ip,
        'isp': {'asn': 'AS64502', 'org': 'Example Mobile', 'isp': 'Example'},
        'risk': {
          'is_mobile': true,
          'is_vpn': false,
          'is_tor': true,
          'is_proxy': false,
          'is_datacenter': false,
          'risk_score': 0,
        },
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipQuery,
        type: IpType.mobile,
        organization: 'Example Mobile',
        asn: 64502,
        isTor: true,
      ),
    ),
    IpQualitySource.ipLocate: (
      {
        'ip': _ip,
        'asn': {'asn': 'AS64503', 'name': 'Example Broadband', 'type': 'isp'},
        'privacy': {
          'is_abuser': false,
          'is_hosting': true,
          'is_proxy': false,
          'is_tor': false,
          'is_vpn': false,
        },
        'company': {'name': 'Example Leasing', 'type': 'hosting'},
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipLocate,
        type: IpType.hosting,
        organization: 'Example Leasing',
        asn: 64503,
      ),
    ),
    IpQualitySource.proxyCheck: (
      {
        'status': 'ok',
        _ip: {
          'network': {
            'asn': 'AS64504',
            'organisation': 'Example Business',
            'type': 'Business',
          },
          'detections': {
            'proxy': false,
            'vpn': true,
            'tor': false,
            'hosting': false,
            'risk': 0,
          },
        },
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.proxyCheck,
        type: IpType.business,
        organization: 'Example Business',
        asn: 64504,
        isVpn: true,
      ),
    ),
    IpQualitySource.ipApiIs: (
      {
        'ip': _ip,
        'is_datacenter': true,
        'is_mobile': false,
        'is_vpn': false,
        'is_proxy': false,
        'is_tor': true,
        'is_abuser': true,
        'company': {'name': 'VPS ACE', 'type': 'business'},
        'asn': {'asn': 36352, 'org': 'HostPapa', 'type': 'hosting'},
      },
      const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipApiIs,
        type: IpType.hosting,
        organization: 'VPS ACE',
        asn: 36352,
        isTor: true,
        isAbuser: true,
      ),
    ),
  };

  for (final MapEntry(key: source, value: (body, expected))
      in samples.entries) {
    test('reads the type and flags from ${source.label}', () async {
      final lookup = _lookup({_hosts[source]!: _ok(body)});
      expect(await lookup.result, expected);
    });
  }

  test('looks up the target address instead of the caller', () async {
    final lookup = _lookup({});
    await expectLater(lookup.result, throwsA(isA<IpQualityLookupException>()));
    expect(
      lookup.adapter.requested.map((uri) => uri.toString()),
      unorderedEquals([
        'https://ident.me/json',
        'http://ip-api.com/json/$_ip?fields=status,isp,org,as,mobile,proxy,hosting',
        'https://api.ipquery.io/$_ip?format=json',
        'https://iplocate.io/api/lookup/$_ip',
        'https://proxycheck.io/v3/$_ip',
        'https://api.ipapi.is/?q=$_ip',
      ]),
    );
  });

  test(
    'takes the first source that states a type and cancels the rest',
    () async {
      final lookup = _lookup({
        'ip-api.com': _ok({
          'status': 'success',
          'hosting': false,
          'mobile': false,
        }, const Duration(milliseconds: 10)),
        'ident.me': _ok({
          'ip': _ip,
          'type': 'business',
        }, const Duration(milliseconds: 40)),
        'api.ipquery.io': _ok({
          'risk': {'is_datacenter': true},
        }, const Duration(seconds: 1)),
      });

      final quality = await lookup.result;

      expect(quality.source, IpQualitySource.identMe);
      expect(quality.type, IpType.business);
      await pumpEventQueue();
      expect(lookup.adapter.cancelled, contains('api.ipquery.io'));
      expect(
        lookup.adapter.requested.map((uri) => uri.host),
        isNot(contains('iplocate.io')),
      );
    },
  );

  test('asks the later waves only while the earlier ones fail', () async {
    final lookup = _lookup({
      'iplocate.io': _ok({
        'company': {'type': 'hosting'},
      }),
    });

    final quality = await lookup.result;

    expect(quality.source, IpQualitySource.ipLocate);
    expect(
      lookup.adapter.requested.map((uri) => uri.host),
      unorderedEquals([
        'ident.me',
        'ip-api.com',
        'api.ipquery.io',
        'iplocate.io',
      ]),
    );
  });

  test(
    'asks the next wave after the hedge while the first is silent',
    () async {
      final lookup = _lookup({
        'ident.me': _ok({'ip': _ip, 'type': 'isp'}, const Duration(seconds: 2)),
        'iplocate.io': _ok({
          'company': {'type': 'business'},
        }, const Duration(milliseconds: 10)),
      }, hedge: const Duration(milliseconds: 50));

      final quality = await lookup.result;

      expect(quality.source, IpQualitySource.ipLocate);
      await pumpEventQueue();
      expect(lookup.adapter.cancelled, contains('ident.me'));
    },
  );

  test(
    'falls back to an inferred type once every source has answered',
    () async {
      final lookup = _lookup(
        {
          'ip-api.com': _ok({
            'status': 'success',
            'isp': 'Example Broadband',
            'hosting': false,
            'mobile': false,
          }),
          'api.ipquery.io': _ok({
            'risk': {'is_datacenter': false, 'is_mobile': false},
          }),
          'ident.me': _ok({
            'ip': _ip,
            'type': 'isp',
          }, const Duration(seconds: 2)),
        },
        hedge: const Duration(milliseconds: 10),
        timeout: const Duration(milliseconds: 100),
      );

      final quality = await lookup.result;

      expect(quality.source, IpQualitySource.ipApiCom);
      expect(quality.type, IpType.residential);
      expect(quality.organization, 'Example Broadband');
      expect(lookup.adapter.requested, hasLength(6));
    },
  );

  test('lists why each source failed when none determines a type', () async {
    final lookup = _lookup({
      'ident.me': _ok({'ip': '198.51.100.1', 'type': 'isp'}),
      'ip-api.com': _ok({'status': 'fail', 'message': 'private range'}),
      'api.ipquery.io': _status(429),
      'iplocate.io': _ok({
        'company': {'name': 'Example Leasing'},
      }),
      'proxycheck.io': _ok({'status': 'denied', 'message': 'limit reached'}),
      'api.ipapi.is': _ok({
        'is_datacenter': true,
      }, const Duration(milliseconds: 300)),
    }, timeout: const Duration(milliseconds: 100));

    await expectLater(
      lookup.result,
      throwsA(
        isA<IpQualityLookupException>()
            .having((error) => error.failures, 'failures', [
              (
                source: IpQualitySource.identMe,
                status: IpQualitySourceStatus.ipMismatch,
              ),
              (
                source: IpQualitySource.ipApiCom,
                status: IpQualitySourceStatus.failed,
              ),
              (
                source: IpQualitySource.ipQuery,
                status: IpQualitySourceStatus.rateLimited,
              ),
              (
                source: IpQualitySource.ipLocate,
                status: IpQualitySourceStatus.noType,
              ),
              (
                source: IpQualitySource.proxyCheck,
                status: IpQualitySourceStatus.rateLimited,
              ),
              (
                source: IpQualitySource.ipApiIs,
                status: IpQualitySourceStatus.timeout,
              ),
            ]),
      ),
    );
  });
}

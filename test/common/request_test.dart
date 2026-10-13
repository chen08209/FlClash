import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getTextResponseForUrl propagates the typed DioException', () async {
    // flutter_test's mocked HttpClient answers every request with HTTP 400,
    // which Dio surfaces as a badResponse DioException.
    await expectLater(
      request.getTextResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('getFileResponseForUrl propagates the typed DioException', () async {
    await expectLater(
      request.getFileResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  group('getFileNameForDisposition', () {
    test('uses the quoted filename when there is no extended value', () {
      expect(
        getFileNameForDisposition('attachment; filename="Config.yaml"'),
        'Config.yaml',
      );
      expect(getFileNameForDisposition(null), isNull);
    });

    test('prefers an extended UTF-8 filename over the fallback', () {
      expect(
        getFileNameForDisposition(
          "attachment; filename=fallback.yaml; filename*=UTF-8''config%20one.yaml",
        ),
        'config one.yaml',
      );
    });

    test('decodes the filename after a language tag', () {
      expect(
        getFileNameForDisposition(
          "attachment; filename*=UTF-8'en'%E9%85%8D%E7%BD%AE.yaml",
        ),
        '配置.yaml',
      );
    });

    test('keeps encoded apostrophes in a language-tagged filename', () {
      expect(
        getFileNameForDisposition(
          "attachment; filename*=UTF-8'en'John%27s.yaml",
        ),
        "John's.yaml",
      );
    });

    test('falls back when the extended value has invalid percent encoding', () {
      expect(
        getFileNameForDisposition(
          "attachment; filename=fallback.yaml; filename*=UTF-8''broken%GG.yaml",
        ),
        'fallback.yaml',
      );
    });

    test('ignores an undecodable extended value without a fallback', () {
      expect(
        getFileNameForDisposition("attachment; filename*=UTF-8''%FF.yaml"),
        isNull,
      );
    });
  });
}

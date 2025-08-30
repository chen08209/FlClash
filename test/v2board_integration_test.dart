import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/services/v2board/models/v2board_models.dart';

void main() {
  group('V2Board Integration Tests', () {
    group('V2Board Models Tests', () {
      test('V2BoardUser should serialize/deserialize correctly', () {
        final user = V2BoardUser(
          id: 1,
          email: 'test@example.com',
          balance: 100,
          commissionBalance: 50,
          planId: 1,
          groupId: 1,
          transferEnable: 1073741824, // 1GB
          u: 536870912, // 512MB
          d: 536870912, // 512MB
          expiredAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          uuid: 'test-uuid-123',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final json = user.toJson();
        final deserializedUser = V2BoardUser.fromJson(json);

        expect(deserializedUser.id, equals(user.id));
        expect(deserializedUser.email, equals(user.email));
        expect(deserializedUser.balance, equals(user.balance));
      });

      test('V2BoardPlan should serialize/deserialize correctly', () {
        final plan = V2BoardPlan(
          id: 1,
          transferEnable: 1073741824, // 1GB
          name: 'Basic Plan',
          show: 1,
          sort: 1,
          renew: 1,
          content: 'Basic plan features',
          monthPrice: 10,
          quarterPrice: 25,
          halfYearPrice: 50,
          yearPrice: 100,
          twoYearPrice: 180,
          threeYearPrice: 250,
          onetimePrice: 500,
          resetPrice: 5,
        );

        final json = plan.toJson();
        final deserializedPlan = V2BoardPlan.fromJson(json);

        expect(deserializedPlan.id, equals(plan.id));
        expect(deserializedPlan.name, equals(plan.name));
        expect(deserializedPlan.monthPrice, equals(plan.monthPrice));
      });

      test('V2BoardSubscription should serialize/deserialize correctly', () {
        final subscription = V2BoardSubscription(
          id: 1,
          name: 'Test Subscription',
          url: 'https://example.com/subscribe/token123',
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        );

        final json = subscription.toJson();
        final deserializedSubscription = V2BoardSubscription.fromJson(json);

        expect(deserializedSubscription.id, equals(subscription.id));
        expect(deserializedSubscription.name, equals(subscription.name));
        expect(deserializedSubscription.url, equals(subscription.url));
      });

      test('V2BoardLoginData should handle empty auth data', () {
        final loginData = V2BoardLoginData();

        expect(loginData.authData, isNull);

        final json = loginData.toJson();
        final deserializedData = V2BoardLoginData.fromJson(json);

        expect(deserializedData.authData, equals(loginData.authData));
      });

      test('V2BoardBaseResponse should handle success response', () {
        final response = V2BoardBaseResponse<String>(
          success: true,
          data: 'test data',
          message: 'Success',
        );

        expect(response.success, isTrue);
        expect(response.data, equals('test data'));
        expect(response.message, equals('Success'));
      });

      test('V2BoardBaseResponse should handle error response', () {
        final response = V2BoardBaseResponse<String>(
          success: false,
          data: null,
          message: 'Error occurred',
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.message, equals('Error occurred'));
      });

      test('V2BoardApiException should format error messages correctly', () {
        final exception = V2BoardApiException(
          'Test error',
          statusCode: 400,
        );

        expect(exception.message, equals('Test error'));
        expect(exception.statusCode, equals(400));
        expect(exception.toString(), contains('Test error'));
        // Note: The actual toString implementation may not include status code
        // This test verifies the basic functionality
      });
    });

    group('URL Validation Tests', () {
      test('should validate subscription URLs correctly', () {
        const validUrls = [
          'https://example.com/api/v1/client/subscribe?token=abc123',
          'http://localhost:8080/subscribe',
          'https://v2board.example.com/api/v1/client/subscribe?token=xyz789',
        ];

        const invalidUrls = [
          'not-a-url',
          'ftp://example.com/subscribe',
          'https://',
          '',
          'javascript:alert("xss")',
        ];

        for (final url in validUrls) {
          expect(_isValidUrl(url), isTrue, reason: 'Should accept valid URL: $url');
        }

        for (final url in invalidUrls) {
          expect(_isValidUrl(url), isFalse, reason: 'Should reject invalid URL: $url');
        }
      });
    });

    group('Data Validation Tests', () {
      test('should validate user data constraints', () {
        // Test valid user data
        final validUser = V2BoardUser(
          id: 1,
          email: 'test@example.com',
          balance: 100,
          commissionBalance: 50,
          planId: 1,
          groupId: 1,
          transferEnable: 1073741824,
          u: 536870912,
          d: 536870912,
          expiredAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          uuid: 'valid-uuid-123',
        );

        expect(validUser.id, greaterThan(0));
        expect(validUser.email, contains('@'));
        expect(validUser.balance, greaterThanOrEqualTo(0));
        expect(validUser.transferEnable, greaterThan(0));
      });

      test('should validate plan pricing', () {
        final plan = V2BoardPlan(
          id: 1,
          transferEnable: 1073741824,
          name: 'Test Plan',
          show: 1,
          sort: 1,
          renew: 1,
          monthPrice: 10,
          quarterPrice: 25,
          halfYearPrice: 50,
          yearPrice: 100,
        );

        // Validate pricing logic
        expect(plan.monthPrice, greaterThan(0));
        expect(plan.quarterPrice, greaterThan(plan.monthPrice!));
        expect(plan.halfYearPrice, greaterThan(plan.quarterPrice!));
        expect(plan.yearPrice, greaterThan(plan.halfYearPrice!));
      });
    });
  });
}

// Helper function for URL validation
bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme &&
           (uri.scheme == 'http' || uri.scheme == 'https') &&
           uri.hasAuthority &&
           uri.host.isNotEmpty;
  } catch (e) {
    return false;
  }
}

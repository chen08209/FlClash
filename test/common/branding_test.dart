import 'package:fl_clash/common/branding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://panel.example.com:8000/sub/';

  group('brandingSubscriptionUrl', () {
    test('joins a bare code onto the base', () {
      expect(brandingSubscriptionUrl('abc.def', base), '${base}abc.def');
    });

    test('adds the missing slash to the base', () {
      expect(
        brandingSubscriptionUrl('abc', 'https://p.example.com/sub'),
        'https://p.example.com/sub/abc',
      );
    });

    test('strips whitespace and line breaks from pasted input', () {
      expect(brandingSubscriptionUrl(' ab\nc \t', base), '${base}abc');
    });

    test('accepts a full url that starts with the base', () {
      expect(brandingSubscriptionUrl('${base}abc', base), '${base}abc');
    });

    test('rejects a full url pointing elsewhere', () {
      const other = 'https://evil.example/sub/abc';
      expect(brandingSubscriptionUrl(other, base), isNull);
    });

    test('rejects empty input and an empty base', () {
      expect(brandingSubscriptionUrl(null, base), isNull);
      expect(brandingSubscriptionUrl('  ', base), isNull);
      expect(brandingSubscriptionUrl('abc', ''), isNull);
    });
  });
}

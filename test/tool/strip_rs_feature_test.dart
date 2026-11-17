import 'package:test/test.dart';

import '../../tool/src/strip_rs_feature.dart';

void main() {
  test('a collection element keeps what the check held', () {
    expect(
      stripRsFeature('final a = [1, if (rsFeature) 2, 3];'),
      'final a = [1, 2, 3];',
    );
  });

  test('a conjunction keeps its right side', () {
    expect(
      stripRsFeature('final a = [if (rsFeature && b) c];'),
      'final a = [if (b) c];',
    );
    expect(
      stripRsFeature('bool f() => rsFeature && a && b;'),
      'bool f() => a && b;',
    );
  });

  test('parentheses that held only the conjunction go when safe', () {
    expect(
      stripRsFeature('bool f() => !(rsFeature && a.b);'),
      'bool f() => !a.b;',
    );
    expect(
      stripRsFeature('bool f() => !(rsFeature && a || b);'),
      'bool f() => !(a || b);',
    );
  });

  test('a statement keeps the statements of its block', () {
    expect(
      stripRsFeature('''
void f() {
  if (rsFeature) {
    a();
    b();
  }
}
'''),
      '''
void f() {
  a();
    b();
}
''',
    );
  });

  test('checks nested in a kept part go in a later pass', () {
    expect(
      stripRsFeature('''
void f() {
  if (rsFeature) {
    g([if (rsFeature) 1]);
  }
}
'''),
      '''
void f() {
  g([1]);
}
''',
    );
  });

  for (final source in [
    'final a = [if (!rsFeature) 1];',
    'final a = [if (rsFeature) 1 else 2];',
    'final a = rsFeature ? 1 : 2;',
    'bool f() => a && rsFeature;',
    'bool f() => rsFeature || a;',
    'void f() { if (rsFeature) { a(); } else { b(); } }',
    'void f() => g(rsFeature);',
  ]) {
    test('refuses $source', () {
      expect(() => stripRsFeature(source), throwsA(isA<StripException>()));
    });
  }

  test('source without the flag stays as it is', () {
    const source = 'final rsFeatureName = 1;';
    expect(mentionsFlag(source), isFalse);
    expect(stripRsFeature(source), source);
  });
}

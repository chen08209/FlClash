import 'package:fl_clash/application.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deferred free nodes startup still runs when navigator is late', () {
    expect(
      shouldScheduleDeferredFreeNodesFallback(
        mounted: true,
        hasNavigatorContext: false,
      ),
      true,
      reason:
          'free nodes resume must not be skipped just because navigator context is late',
    );
    expect(
      shouldScheduleDeferredFreeNodesFallback(
        mounted: false,
        hasNavigatorContext: false,
      ),
      false,
    );
    expect(
      shouldScheduleDeferredFreeNodesFallback(
        mounted: true,
        hasNavigatorContext: true,
      ),
      false,
    );
  });
}

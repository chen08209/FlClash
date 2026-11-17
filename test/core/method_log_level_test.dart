import 'dart:async';

import 'package:fl_clash/core/api/errors.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('coreFailureLogLevel', () {
    test('silences failures caused by an unavailable Core', () {
      for (final code in [
        'transport_disconnected',
        'transport_error',
        'core_unavailable',
        'cancelled',
      ]) {
        expect(
          coreFailureLogLevel(CoreMethodException(code: code, message: code)),
          LogLevel.debug,
          reason: code,
        );
      }
      expect(
        coreFailureLogLevel(TimeoutException('Core method timed out')),
        LogLevel.debug,
      );
    });

    test('keeps Core reported failures visible', () {
      expect(
        coreFailureLogLevel(
          const CoreMethodException(
            code: 'core_error',
            message: 'config not found',
          ),
        ),
        LogLevel.warning,
      );
      expect(
        coreFailureLogLevel(
          const CoreMethodException(
            code: 'empty_result',
            message: 'Core returned an empty config result',
          ),
        ),
        LogLevel.warning,
      );
    });

    test('keeps a rejected call visible', () {
      expect(
        coreFailureLogLevel(
          CoreMethodException.fromError({
            'message': 'bad',
            'data': {'kind': 'rejected', 'reason': 'invalid_config'},
          }),
        ),
        LogLevel.warning,
      );
    });

    test('keeps unrelated failures visible', () {
      expect(coreFailureLogLevel(StateError('boom')), LogLevel.warning);
      expect(coreFailureLogLevel(null), LogLevel.warning);
    });
  });

  group('CoreMethodException', () {
    test('marks only transport codes as an unavailable Core', () {
      expect(
        const CoreMethodException(
          code: 'transport_disconnected',
          message: '',
        ).isCoreUnavailable,
        isTrue,
      );
      expect(
        const CoreMethodException(
          code: 'core_error',
          message: '',
        ).isCoreUnavailable,
        isFalse,
      );
    });

    test('reads a rejection by its reason and keeps its kind', () {
      final error = CoreMethodException.fromError({
        'message': 'bad',
        'data': {'kind': 'rejected', 'reason': 'invalid_config'},
      });

      expect(error.code, 'invalid_config');
      expect(error.kind, 'rejected');
    });
  });

  group('isUnansweredCoreError', () {
    test('is true for a Core that never answered', () {
      expect(isUnansweredCoreError(TimeoutException('late')), isTrue);
      expect(
        isUnansweredCoreError(
          const CoreMethodException(code: 'core_unavailable', message: ''),
        ),
        isTrue,
      );
    });

    test('is true for a call the transport dropped before an answer', () {
      for (final code in ['transport_disconnected', 'transport_error']) {
        expect(
          isUnansweredCoreError(CoreMethodException(code: code, message: '')),
          isTrue,
          reason: code,
        );
      }
    });

    test('is false for a Core that answered with an error', () {
      expect(
        isUnansweredCoreError(
          const CoreMethodException(code: 'rejected', message: ''),
        ),
        isFalse,
      );
      expect(isUnansweredCoreError(StateError('boom')), isFalse);
      expect(isUnansweredCoreError(null), isFalse);
    });
  });
}

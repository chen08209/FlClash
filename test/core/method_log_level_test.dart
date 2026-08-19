import 'dart:async';

import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('coreFailureLogLevel', () {
    test('silences failures caused by an unavailable Core', () {
      for (final code in ['transport_disconnected', 'transport_error']) {
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
  });
}

import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

class ProtocolRegistrationPlan {
  final String scheme;
  final String executable;

  const ProtocolRegistrationPlan({
    required this.scheme,
    required this.executable,
  });

  String get protocolKey => 'Software\\Classes\\$scheme';

  String get commandKey => 'shell\\open\\command';

  String get protocolValueName => 'URL Protocol';

  String get protocolValue => '';

  String get command => '"$executable" "%1"';
}

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  void register(String scheme) {
    final plan = ProtocolRegistrationPlan(
      scheme: scheme,
      executable: Platform.resolvedExecutable,
    );
    final regKey = CURRENT_USER.create(plan.protocolKey);
    try {
      regKey.setValue(
        plan.protocolValueName,
        RegistryValue.string(plan.protocolValue),
      );
      final commandKey = regKey.create(plan.commandKey);
      try {
        commandKey.setValue('', RegistryValue.string(plan.command));
      } finally {
        commandKey.close();
      }
    } finally {
      regKey.close();
    }
  }
}

final protocol = Protocol();

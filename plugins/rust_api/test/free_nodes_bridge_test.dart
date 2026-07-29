import 'dart:convert';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var rustInitialized = false;
  Future<void> initRust() async {
    if (rustInitialized) return;
    await RustLib.init(
      externalLibrary: ExternalLibrary.open('rust/target/release/rust_api.dll'),
    );
    rustInitialized = true;
  }

  test('Rust free nodes prefer keeps existing proxies', () async {
    await initRust();

    final outputText = await preferFreeNodesConfigJson(
      inputJson: json.encode({
        'configText': '''
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
''',
        'historyTimeoutHours': 10000,
        'nowDayNumber': 20623,
        'todayToken': 20260619,
        'deleteExpiredGroups': false,
      }),
    );

    final output = json.decode(outputText) as Map;

    expect(output['beforeCount'], 1);
    expect(output['afterCount'], 1);
    expect(output['removedCount'], 0);
    expect(output['yaml'], contains('日期 2026-05-30'));
    expect(output['yaml'], contains('old-node'));
  });

  test('Rust free nodes prefer rejects empty output before write', () async {
    await initRust();

    await expectLater(
      preferFreeNodesConfigJson(
        inputJson: json.encode({
          'configText': 'proxy-groups: []',
          'historyTimeoutHours': 10000,
          'nowDayNumber': 20623,
          'todayToken': 20260619,
          'deleteExpiredGroups': false,
        }),
      ),
      throwsA(contains('已保留原配置')),
    );
  });
}

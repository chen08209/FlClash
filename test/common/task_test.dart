import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('makeRealProfileTask includes auto-detect-interface', () async {
    final result = await makeRealProfileTask(
      const MakeRealProfileState(
        profilesPath: '/tmp/profiles',
        profileId: 1,
        rawConfig: {},
        realPatchConfig: PatchClashConfig(tun: Tun(autoDetectInterface: true)),
        overrideDns: false,
        appendSystemDns: false,
        proxyGroups: [],
        rules: [],
        addedRules: [],
        defaultUA: 'FlClash/Test',
      ),
    );

    expect(result.a, contains('auto-detect-interface: true'));
  });
}

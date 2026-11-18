import 'dart:convert';

import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/core/api/mapping.dart';
import 'package:fl_clash/core/api/rpc_core_api.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/api/fake_channel.dart';
import '../core/api/schema_core.dart';

void main() {
  test(
    'the setup params Android sends spell what applyConfig writes',
    () async {
      final channel = FakeFrameChannel();
      SchemaCore(channel, ApiSchema.load(), full: false);
      final client = CoreClient(channel);
      channel.connect();
      addTearDown(() async {
        await client.close();
        await channel.close();
      });
      const options = CoreOptions(testUrl: 'http://t');
      final host = hostSettingsOf(
        const PatchClashConfig(secret: 's'),
        credential: 'h:s',
        safeMode: false,
      );

      await RpcCoreApi(client).applyConfig(
        overlay: const {},
        selection: const {'g': 'p'},
        options: coreOptionsArgOf(options),
        host: host,
      );

      final written =
          channel.lastCall('config.apply')['params']! as Map<String, Object?>;
      final writtenOptions = (written['options']! as Map).keys.toSet();
      final sent =
          jsonDecode(
                jsonEncode(
                  SetupParams(
                    selectedMap: const {'g': 'p'},
                    options: options,
                    host: host,
                  ),
                ),
              )
              as Map<String, Object?>;
      expect(sent.keys.toSet(), {'selection', 'options', 'host'});
      expect(written.keys, containsAll(sent.keys));
      expect((sent['options']! as Map).keys.toSet(), writtenOptions);
      expect(sent['host'], written['host']);
      expect(options.toJson().keys.toSet(), writtenOptions);
    },
  );
}

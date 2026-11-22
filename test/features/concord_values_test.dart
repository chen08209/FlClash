import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/editor/clash_schema.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/concord_schema.dart';

void main() {
  final values = ConcordSchema.load().values;
  List<String> concord(String section, String key) => values[section]![key]!;

  group('the settings offer only values Concord runs', () {
    test('the TUN congestion control row and its override', () {
      final allowed = concord('tun', 'congestion-controller');
      expect(congestionControllers, unorderedEquals(allowed));
      final row = tunItems().whereType<ConfigOptionsItem<String>>().single;
      expect(allowed, containsAll(row.options));
      final override =
          TunView(
                1,
                isLinux: true,
                isWindows: true,
              ).spec.fieldOf(TunOverrideKey.congestionController)
              as OptionsOverrideField<ProfileTun, String>;
      expect(allowed, containsAll(override.options));
    });

    test('the DNS overrides', () {
      final spec = const DnsView().spec;
      List<String> labels<T extends Object>(DnsOverrideKey key) {
        final field = spec.fieldOf(key) as OptionsOverrideField<Dns, T>;
        return field.options.map(field.labelOf).toList();
      }

      expect(
        concord('dns', 'enhanced-mode'),
        containsAll(labels<DnsMode>(DnsOverrideKey.enhancedMode)),
      );
      expect(
        concord('dns', 'fake-ip-filter-mode'),
        containsAll(labels<FakeIpFilterMode>(DnsOverrideKey.fakeIpFilterMode)),
      );
      expect(
        concord('dns', 'cache-algorithm'),
        containsAll(labels<DnsCacheAlgorithm>(DnsOverrideKey.cacheAlgorithm)),
      );
    });

    test('the mode, log level and process matching', () {
      expect(
        concord('keys', 'mode'),
        containsAll(Mode.values.map((m) => m.name)),
      );
      expect(
        concord('keys', 'log-level'),
        containsAll(LogLevel.values.map((level) => level.name)),
      );
      expect(
        concord('keys', 'find-process-mode'),
        containsAll(FindProcessMode.values.map((mode) => mode.name)),
      );
    });
  });

  group('the editor completes exactly the values Concord runs', () {
    final top = clashConfigSchema.fields;
    final sections = {
      'keys': clashConfigSchema,
      'dns': top['dns']!,
      'tun': top['tun']!,
    };
    for (final MapEntry(key: section, value: schema) in sections.entries) {
      for (final MapEntry(:key, value: allowed) in values[section]!.entries) {
        test('$section $key', () {
          expect(schema.fields[key]!.values, unorderedEquals(allowed));
        });
      }
    }

    test('the ip-stack of every proxy that has one', () {
      final variants = top['proxies']!.entry!.variants;
      final stacks = [
        for (final fields in variants.values) ?fields['ip-stack'],
      ];
      expect(stacks, isNotEmpty);
      for (final stack in stacks) {
        for (final MapEntry(:key, value: allowed) in values['proxy']!.entries) {
          final field = key.substring('ip-stack.'.length);
          expect(stack.fields[field]!.values, unorderedEquals(allowed));
        }
      }
    });
  });
}

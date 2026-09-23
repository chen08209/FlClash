import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogPayload.parse', () {
    test('keeps an untagged line as its message', () {
      final payload = LogPayload.parse('Start initial configuration');

      expect(payload.tag, '');
      expect(payload.message, 'Start initial configuration');
      expect(payload.route, isNull);
    });

    test('splits a matched route into its parts', () {
      final payload = LogPayload.parse(
        '[TCP] 192.168.1.5:52341(Google Chrome, uid=10123) --> '
        'www.google.com:443 match DomainSuffix(google.com) using Proxy[HK 01]',
      );
      final route = payload.route!;

      expect(payload.tag, 'TCP');
      expect(route.source, '192.168.1.5:52341');
      expect(route.sourceDetail, 'Google Chrome, uid=10123');
      expect(route.destination, 'www.google.com:443');
      expect(route.rule, 'DomainSuffix(google.com)');
      expect(route.proxy, 'Proxy[HK 01]');
      expect(route.error, '');
    });

    test('reads routes without a rule and from the core itself', () {
      final direct = LogPayload.parse(
        '[UDP] [fe80::1]:5353 --> [2606:4700::1111]:53 using DIRECT',
      ).route!;
      final unmatched = LogPayload.parse(
        "[TCP] 10.0.0.2:40000 --> a.example:443 doesn't match any rule "
        'using Proxy',
      ).route!;
      final inner = LogPayload.parse(
        '[TCP] mihomo --> dns.google:853 using DIRECT',
      ).route!;

      expect(direct.source, '[fe80::1]:5353');
      expect(direct.destination, '[2606:4700::1111]:53');
      expect(direct.rule, '');
      expect(unmatched.rule, "doesn't match any rule");
      expect(unmatched.proxy, 'Proxy');
      expect(inner.source, 'mihomo');
      expect(inner.sourceDetail, '');
    });

    test('splits a dial failure, with or without its rule', () {
      final matched = LogPayload.parse(
        '[TCP] dial Proxy (match DomainSuffix/openai.com) '
        '10.0.0.2:52400(chatgpt) --> chat.openai.com:443 error: i/o timeout',
      ).route!;
      final bare = LogPayload.parse(
        '[TCP] dial HK Node 01 10.0.0.2:52400 --> a.example:443 error: EOF',
      ).route!;

      expect(matched.proxy, 'Proxy');
      expect(matched.rule, 'DomainSuffix/openai.com');
      expect(matched.source, '10.0.0.2:52400');
      expect(matched.sourceDetail, 'chatgpt');
      expect(matched.destination, 'chat.openai.com:443');
      expect(matched.error, 'i/o timeout');
      expect(bare.proxy, 'HK Node 01');
      expect(bare.rule, '');
      expect(bare.error, 'EOF');
    });

    test('leaves other tagged lines as plain messages', () {
      final dns = LogPayload.parse('[DNS] www.youtube.com --> 142.250.72.14');
      final icmp = LogPayload.parse(
        '[ICMP] ip4 10.0.0.2 --> 1.1.1.1 using DIRECT',
      );

      expect(dns.tag, 'DNS');
      expect(dns.message, 'www.youtube.com --> 142.250.72.14');
      expect(dns.route, isNull);
      expect(icmp.route, isNull);
    });
  });
}

import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/config_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations appLocalizations;

  setUpAll(() async {
    appLocalizations = await AppLocalizations.load(const Locale('en'));
  });

  test('a DNS listen address takes what net.SplitHostPort reads', () {
    for (final value in [
      '0.0.0.0:1053',
      ':53',
      '127.0.0.1:65535',
      'localhost:53',
      '[::]:1053',
      '[fe80::1]:53',
    ]) {
      expect(
        validateListenAddress(value, appLocalizations),
        isNull,
        reason: value,
      );
    }
    for (final value in [
      '0.0.0.0',
      '0.0.0.0:0',
      '0.0.0.0:65536',
      '0.0.0.0:+53',
      ':::53',
      '[::1]',
      '[1.2.3.4]:53',
      'bad host:53',
    ]) {
      expect(
        validateListenAddress(value, appLocalizations),
        appLocalizations.invalidListenContent,
        reason: value,
      );
    }
  });

  test('an NTP server is a domain or an IP address', () {
    for (final value in ['time.apple.com', '162.159.200.1', '2606:4700::1']) {
      expect(validateHost(value, appLocalizations), isNull, reason: value);
    }
    for (final value in [
      'https://time.apple.com',
      'time.apple.com:123',
      'time..com',
      'time apple',
      '-time.com',
    ]) {
      expect(
        validateHost(value, appLocalizations),
        appLocalizations.invalidHostContent,
        reason: value,
      );
    }
  });
}

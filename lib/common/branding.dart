import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/branding_secret.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _handledUrlsKey = 'branding_handled_urls';

String _urlDigest(String url) => sha256.convert(utf8.encode(url)).toString();

Future<void> addBrandingProfilesIfMissing(WidgetRef ref) async {
  final prefs = await preferences.sharedPreferencesCompleter.future;
  final stored = prefs?.getStringList(_handledUrlsKey) ?? <String>[];
  final handled = stored.toSet();
  final before = handled.length;
  for (final url in brandingSecretUrls) {
    if (!url.startsWith('http')) continue;
    final digest = _urlDigest(url);
    if (handled.contains(digest)) continue;
    if (ref.read(profilesProvider).any((profile) => profile.url == url)) {
      handled.add(digest);
      continue;
    }
    try {
      await ref.read(profilesActionProvider.notifier).addProfileFormURL(url);
      handled.add(digest);
    } catch (e) {
      commonPrint.log('addBrandingProfile failed: $e');
    }
  }
  if (handled.length != before) {
    await prefs?.setStringList(_handledUrlsKey, handled.toList());
  }
}

Future<bool> askBrandingUnlockCode() async {
  if (brandingSecretCode.isEmpty) return false;
  final input = await dialogs.showCommonDialog<String>(
    child: InputDialog(
      title: currentAppLocalizations.addProfile,
      value: '',
      obscureText: true,
    ),
  );
  return input?.trim().toLowerCase() == brandingSecretCode.toLowerCase();
}

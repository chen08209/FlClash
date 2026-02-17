import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:fl_clash/common/common.dart';

/// HTTP response header for subscription encryption (same as v2rayN)
const String subscriptionEncryptionHeader = 'subscription-encryption';
const String aesEncryptionValue = 'true';

/// Check if response headers indicate AES-encrypted subscription
bool isSubscriptionEncrypted(String? headerValue) {
  if (headerValue == null || headerValue.isEmpty) return false;
  return headerValue.trim().toLowerCase() == aesEncryptionValue;
}

/// Try to decrypt subscription content (AES-128-CBC, same as v2rayN)
/// Key: MD5(password) as 32-char hex -> 16 bytes
/// IV: first 16 bytes of base64 decoded data
/// Cipher: bytes 16.. of base64 decoded data
Uint8List? tryDecryptSubscription(String password, String base64Data) {
  if (base64Data.isEmpty || password.isEmpty) return null;

  final passHash = md5.convert(utf8.encode(password)).toString();
  if (passHash.length != 32) return null;

  Uint8List keyBytes;
  try {
    keyBytes = Uint8List.fromList(
      List.generate(16, (i) => int.parse(passHash.substring(i * 2, i * 2 + 2), radix: 16)),
    );
  } catch (_) {
    return null;
  }

  Uint8List raw;
  try {
    final normalized = base64Data.trim().replaceAll('\n', '').replaceAll('\r', '');
    raw = base64Decode(normalized);
  } catch (_) {
    return null;
  }

  if (raw.length <= 16) return null;

  final iv = IV(raw.sublist(0, 16));
  final cipher = Encrypted(Uint8List.fromList(raw.sublist(16)));
  final key = Key(keyBytes);

  try {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted = encrypter.decrypt(cipher, iv: iv);
    final bytes = Uint8List.fromList(utf8.encode(decrypted));
    return bytes.isNotEmpty ? bytes : null;
  } catch (e) {
    commonPrint.log('Subscription decrypt error: $e', logLevel: LogLevel.warning);
    return null;
  }
}

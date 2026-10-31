import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:path/path.dart';

/// The name of the leaf the Core signs for a trust store to verify.
const mitmCheckHost = 'mitm-check.flclash.invalid';

const mitmCertificateFileName = 'FlClash CA.crt';

/// Named by the CA, so that a renewed one saved beside it is told apart.
String mitmSavedFileName(MitmCertificate ca) => '${ca.subject}.crt';

class MitmTrustCheck {
  const MitmTrustCheck(
    this.trust, {
    this.missingStores = const [],
    this.certutilInstall,
    this.systemStore = false,
    this.rootAvailable = false,
  });

  final MitmTrust trust;

  /// Android: every app trusts it, not only those that trust user CAs.
  final bool systemStore;

  final bool rootAvailable;

  /// Linux: the browsers whose databases still lack the CA, by name.
  final List<String> missingStores;

  /// Linux: the command that installs certutil, which those databases need.
  final String? certutilInstall;
}

/// A platform's trust store, asked as the user the app runs as: a Core run as
/// root or SYSTEM would read another account's trust settings.
abstract interface class MitmTrustStore {
  /// [issueLeaf] signs a leaf for [mitmCheckHost], for a store that can only
  /// verify a chain.
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  );

  Future<MitmInstallOutcome> install(MitmCertificate ca);

  /// Takes [ca] out of the store before a new CA replaces it. False where
  /// only the user can, in the system's settings.
  Future<bool> remove(MitmCertificate ca);
}

MitmTrustStore? mitmTrustStoreForPlatform() {
  if (system.isMacOS) {
    return MacOSMitmTrustStore(home: Platform.environment['HOME'] ?? '');
  }
  if (system.isWindows) {
    return WindowsMitmTrustStore();
  }
  if (system.isLinux) {
    return LinuxMitmTrustStore(
      home: Platform.environment['HOME'] ?? '',
      searchPath: Platform.environment['PATH'] ?? '',
    );
  }
  if (system.isAndroid && app != null) {
    return AndroidMitmTrustStore(app!);
  }
  return null;
}

List<int> mitmCertificateDer(MitmCertificate ca) {
  final body = const LineSplitter()
      .convert(ca.pem)
      .where((line) => line.isNotEmpty && !line.startsWith('-----'))
      .join();
  return base64.decode(body.trim());
}

String _hexOf(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

String mitmSha1Hex(MitmCertificate ca) =>
    _hexOf(sha1.convert(mitmCertificateDer(ca)).bytes);

String mitmSha256Hex(MitmCertificate ca) =>
    ca.fingerprint.replaceAll(':', '').toUpperCase();

typedef TempFileWriter = Future<String> Function(String content);

Future<String> _writeTempFile(String content) async {
  final file = File(await appPath.tempFilePath);
  await file.safeWriteAsString(content);
  return file.path;
}

Future<T> _withTempFile<T>(
  TempFileWriter write,
  String content,
  Future<T> Function(String path) use,
) async {
  final path = await write(content);
  try {
    return await use(path);
  } finally {
    await File(path).safeDelete();
  }
}

Future<ProcessResult> _runChecked(
  ProcessRunner run,
  String executable,
  List<String> arguments,
) async {
  final result = await run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      '${result.stderr}'.trim(),
      result.exitCode,
    );
  }
  return result;
}

class MacOSMitmTrustStore implements MitmTrustStore {
  MacOSMitmTrustStore({
    required this.home,
    this.run = Process.run,
    this.writeTemp = _writeTempFile,
  });

  final String home;
  final ProcessRunner run;
  final TempFileWriter writeTemp;

  static const _security = '/usr/bin/security';

  String get _keychain => '$home/Library/Keychains/login.keychain-db';

  @override
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  ) async {
    final leaf = await issueLeaf();
    final verified = await _withTempFile(
      writeTemp,
      leaf,
      (path) => run(_security, [
        'verify-cert',
        '-c',
        path,
        '-p',
        'ssl',
        '-n',
        mitmCheckHost,
        '-L',
        '-q',
      ]),
    );
    if (verified.exitCode == 0) {
      return const MitmTrustCheck(MitmTrust.ready);
    }
    final found = await run(_security, [
      'find-certificate',
      '-a',
      '-Z',
      '-c',
      ca.subject,
    ]);
    final installed = '${found.stdout}'.contains(
      'SHA-256 hash: ${mitmSha256Hex(ca)}',
    );
    return MitmTrustCheck(
      installed ? MitmTrust.untrusted : MitmTrust.notInstalled,
    );
  }

  /// Adds the CA to the login keychain and trusts it for this user, which
  /// asks for the user's password.
  @override
  Future<MitmInstallOutcome> install(MitmCertificate ca) async {
    await _withTempFile(
      writeTemp,
      ca.pem,
      (path) => _runChecked(run, _security, [
        'add-trusted-cert',
        '-r',
        'trustRoot',
        '-k',
        _keychain,
        path,
      ]),
    );
    return MitmInstallOutcome.installed;
  }

  @override
  Future<bool> remove(MitmCertificate ca) async {
    await _runChecked(run, _security, [
      'delete-certificate',
      '-Z',
      mitmSha256Hex(ca),
      '-t',
      _keychain,
    ]);
    return true;
  }
}

/// Reads the store through crypt32 rather than certutil, so that a check on
/// every return to the foreground starts no console process.
class WindowsMitmTrustStore implements MitmTrustStore {
  WindowsMitmTrustStore({
    this.run = Process.run,
    this.writeTemp = _writeTempFile,
  });

  final ProcessRunner run;
  final TempFileWriter writeTemp;

  @override
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  ) async {
    final hash = sha1.convert(mitmCertificateDer(ca)).bytes;
    // The first lookup loads crypt32 and opens the store, about 12 ms.
    final found = await Isolate.run(() => _CurrentUserRoot.contains(hash));
    return MitmTrustCheck(found ? MitmTrust.ready : MitmTrust.notInstalled);
  }

  /// The system asks the user to confirm before it trusts the certificate.
  @override
  Future<MitmInstallOutcome> install(MitmCertificate ca) async {
    await _withTempFile(
      writeTemp,
      ca.pem,
      (path) =>
          _runChecked(run, 'certutil', ['-addstore', '-user', 'Root', path]),
    );
    return MitmInstallOutcome.installed;
  }

  @override
  Future<bool> remove(MitmCertificate ca) async {
    await _runChecked(run, 'certutil', [
      '-user',
      '-delstore',
      'Root',
      mitmSha1Hex(ca),
    ]);
    return true;
  }
}

final class _CryptHashBlob extends Struct {
  @Uint32()
  external int cbData;

  external Pointer<Uint8> pbData;
}

abstract final class _CurrentUserRoot {
  static const _x509Encodings = 0x00010001;
  static const _findSha1Hash = 0x00010000;

  static bool contains(List<int> sha1Hash) {
    final crypt32 = DynamicLibrary.open('crypt32.dll');
    final open = crypt32
        .lookupFunction<
          Pointer<Void> Function(IntPtr, Pointer<Utf16>),
          Pointer<Void> Function(int, Pointer<Utf16>)
        >('CertOpenSystemStoreW');
    final find = crypt32
        .lookupFunction<
          Pointer<Void> Function(
            Pointer<Void>,
            Uint32,
            Uint32,
            Uint32,
            Pointer<Void>,
            Pointer<Void>,
          ),
          Pointer<Void> Function(
            Pointer<Void>,
            int,
            int,
            int,
            Pointer<Void>,
            Pointer<Void>,
          )
        >('CertFindCertificateInStore');
    final free = crypt32
        .lookupFunction<
          Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)
        >('CertFreeCertificateContext');
    final close = crypt32
        .lookupFunction<
          Int32 Function(Pointer<Void>, Uint32),
          int Function(Pointer<Void>, int)
        >('CertCloseStore');
    return using((arena) {
      final store = open(0, 'ROOT'.toNativeUtf16(allocator: arena));
      if (store == nullptr) {
        throw const OSError('CertOpenSystemStore failed');
      }
      try {
        final hash = arena<Uint8>(sha1Hash.length);
        hash.asTypedList(sha1Hash.length).setAll(0, sha1Hash);
        final blob = arena<_CryptHashBlob>()
          ..ref.cbData = sha1Hash.length
          ..ref.pbData = hash;
        final context = find(
          store,
          _x509Encodings,
          0,
          _findSha1Hash,
          blob.cast(),
          nullptr,
        );
        if (context == nullptr) {
          return false;
        }
        free(context);
        return true;
      } finally {
        close(store, 0);
      }
    });
  }
}

/// Linux has no one trust store: curl and most programs read the system
/// bundle, while Chrome and each Firefox profile keep an NSS database.
class LinuxMitmTrustStore implements MitmTrustStore {
  LinuxMitmTrustStore({
    required this.home,
    required this.searchPath,
    this.run = Process.run,
    Future<bool> Function(List<String> command)? elevate,
    this.writeTemp = _writeTempFile,
    this.readFile = _readFile,
    this.listDirectory = _listDirectory,
  }) : elevate = elevate ?? linuxElevation.elevate;

  final String home;
  final String searchPath;
  final ProcessRunner run;
  final Future<bool> Function(List<String> command) elevate;
  final TempFileWriter writeTemp;
  final Future<String?> Function(String path) readFile;
  final Future<List<String>> Function(String path) listDirectory;

  static const nickname = 'FlClash MITM CA';

  /// Where Go's crypto/x509 looks, which covers what most programs read.
  static const bundles = [
    '/etc/ssl/certs/ca-certificates.crt',
    '/etc/pki/tls/certs/ca-bundle.crt',
    '/etc/ssl/ca-bundle.pem',
    '/etc/pki/tls/cacert.pem',
    '/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem',
    '/etc/ssl/cert.pem',
  ];

  /// Copies the CA into the anchors of whichever trust tool the system has
  /// and refreshes the bundle, as one elevated step with the path as $1.
  /// openSUSE also has the Debian directory, which its tool ignores, so the
  /// Debian layout is tried last.
  static const installScript = r'''
set -e
name=flclash-mitm-ca.crt
if [ -d /etc/pki/ca-trust/source/anchors ] && command -v update-ca-trust >/dev/null; then
  install -m 0644 "$1" "/etc/pki/ca-trust/source/anchors/$name"
  update-ca-trust extract
elif [ -d /etc/ca-certificates/trust-source/anchors ] && command -v update-ca-trust >/dev/null; then
  install -m 0644 "$1" "/etc/ca-certificates/trust-source/anchors/$name"
  update-ca-trust extract
elif [ -d /etc/pki/trust/anchors ] && command -v update-ca-certificates >/dev/null; then
  install -m 0644 "$1" "/etc/pki/trust/anchors/$name"
  update-ca-certificates
elif [ -d /usr/local/share/ca-certificates ] && command -v update-ca-certificates >/dev/null; then
  install -m 0644 "$1" "/usr/local/share/ca-certificates/$name"
  update-ca-certificates
else
  echo "no supported trust store" >&2
  exit 3
fi
''';

  /// Undoes [installScript], choosing the trust tool the same way.
  static const removeScript = r'''
set -e
name=flclash-mitm-ca.crt
if [ -d /etc/pki/ca-trust/source/anchors ] && command -v update-ca-trust >/dev/null; then
  rm -f "/etc/pki/ca-trust/source/anchors/$name"
  update-ca-trust extract
elif [ -d /etc/ca-certificates/trust-source/anchors ] && command -v update-ca-trust >/dev/null; then
  rm -f "/etc/ca-certificates/trust-source/anchors/$name"
  update-ca-trust extract
elif [ -d /etc/pki/trust/anchors ] && command -v update-ca-certificates >/dev/null; then
  rm -f "/etc/pki/trust/anchors/$name"
  update-ca-certificates
elif [ -d /usr/local/share/ca-certificates ] && command -v update-ca-certificates >/dev/null; then
  rm -f "/usr/local/share/ca-certificates/$name"
  update-ca-certificates
else
  echo "no supported trust store" >&2
  exit 3
fi
''';

  static Future<String?> _readFile(String path) async {
    try {
      return await File(path).readAsString();
    } on FileSystemException {
      return null;
    }
  }

  static Future<List<String>> _listDirectory(String path) async {
    try {
      return await Directory(path)
          .list(followLinks: false)
          .where((entry) => entry is Directory)
          .map((entry) => entry.path)
          .toList();
    } on FileSystemException {
      return const [];
    }
  }

  String? _findExecutable(String name) {
    for (final directory in searchPath.split(':')) {
      if (directory.isEmpty) {
        continue;
      }
      final candidate = join(directory, name);
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  /// The command that installs certutil, by the package manager the system has.
  String certutilInstallCommand() {
    if (_findExecutable('apt-get') != null) {
      return 'sudo apt-get install libnss3-tools';
    }
    if (_findExecutable('dnf') != null) {
      return 'sudo dnf install nss-tools';
    }
    if (_findExecutable('pacman') != null) {
      return 'sudo pacman -S nss';
    }
    if (_findExecutable('zypper') != null) {
      return 'sudo zypper install mozilla-nss-tools';
    }
    return 'certutil (NSS tools)';
  }

  /// Chrome's database and each Firefox profile's, including snap packages,
  /// by the browser's name; a Flatpak browser keeps its own inside its sandbox.
  Future<Map<String, String>> nssDatabases() async {
    final databases = <String, String>{};
    Future<void> addIfDatabase(String directory, String browser) async {
      if (await File(join(directory, 'cert9.db')).exists()) {
        databases[directory] = browser;
      }
    }

    await addIfDatabase(join(home, '.pki', 'nssdb'), 'Chrome');
    await addIfDatabase(
      join(home, 'snap', 'chromium', 'current', '.pki', 'nssdb'),
      'Chrome',
    );
    for (final profiles in [
      join(home, '.mozilla', 'firefox'),
      join(home, 'snap', 'firefox', 'common', '.mozilla', 'firefox'),
    ]) {
      for (final profile in await listDirectory(profiles)) {
        await addIfDatabase(profile, 'Firefox (${basename(profile)})');
      }
    }
    return databases;
  }

  /// Looks for the CA as the trust tools write it, in lines of 64, so that a
  /// bundle of a few hundred roots is searched without being rewritten.
  Future<bool> inSystemBundle(MitmCertificate ca) async {
    final body = base64.encode(mitmCertificateDer(ca));
    final lines = [
      for (var i = 0; i < body.length; i += 64)
        body.substring(i, min(i + 64, body.length)),
    ];
    final unix = lines.join('\n');
    final windows = lines.join('\r\n');
    for (final bundle in bundles) {
      final content = await readFile(bundle);
      if (content != null &&
          (content.contains(unix) || content.contains(windows))) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _inDatabase(
    String certutil,
    String database,
    MitmCertificate ca,
  ) async {
    final result = await run(certutil, [
      '-d',
      'sql:$database',
      '-L',
      '-n',
      nickname,
      '-a',
    ]);
    if (result.exitCode != 0) {
      return false;
    }
    final listed = '${result.stdout}'.replaceAll(RegExp(r'\s'), '');
    return listed.contains(base64.encode(mitmCertificateDer(ca)));
  }

  @override
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  ) async {
    final system = await inSystemBundle(ca);
    final databases = await nssDatabases();
    final certutil = _findExecutable('certutil');
    final missing = <String>[];
    for (final MapEntry(key: database, value: browser) in databases.entries) {
      if (certutil == null || !await _inDatabase(certutil, database, ca)) {
        missing.add(browser);
      }
    }
    final trust = switch ((system, missing.length)) {
      (true, 0) => MitmTrust.ready,
      (false, final count) when count == databases.length =>
        MitmTrust.notInstalled,
      _ => MitmTrust.untrusted,
    };
    return MitmTrustCheck(
      trust,
      missingStores: missing,
      certutilInstall: certutil == null && databases.isNotEmpty
          ? certutilInstallCommand()
          : null,
    );
  }

  @override
  Future<MitmInstallOutcome> install(MitmCertificate ca) async {
    await _withTempFile(writeTemp, ca.pem, (path) async {
      if (!await elevate(['/bin/sh', '-c', installScript, 'flclash', path])) {
        throw MessageException(currentAppLocalizations.mitmSystemStoreFailed);
      }
      final certutil = _findExecutable('certutil');
      final databases = await nssDatabases();
      if (certutil == null) {
        if (databases.isNotEmpty) {
          throw MessageException(
            currentAppLocalizations.mitmCertutilMissing(
              certutilInstallCommand(),
            ),
          );
        }
        return;
      }
      for (final database in databases.keys) {
        await run(certutil, ['-d', 'sql:$database', '-D', '-n', nickname]);
        await _runChecked(run, certutil, [
          '-d',
          'sql:$database',
          '-A',
          '-t',
          'C,,',
          '-n',
          nickname,
          '-i',
          path,
        ]);
      }
    });
    return MitmInstallOutcome.installed;
  }

  @override
  Future<bool> remove(MitmCertificate ca) async {
    var removed = await _removeFromDatabases(ca);
    if (await inSystemBundle(ca) &&
        !await elevate(['/bin/sh', '-c', removeScript, 'flclash'])) {
      removed = false;
    }
    return removed;
  }

  Future<bool> _removeFromDatabases(MitmCertificate ca) async {
    final databases = await nssDatabases();
    final certutil = _findExecutable('certutil');
    if (certutil == null) {
      return databases.isEmpty;
    }
    var removed = true;
    for (final database in databases.keys) {
      if (!await _inDatabase(certutil, database, ca)) {
        continue;
      }
      // `certutil -D` also fails on an absent nickname, so the listing decides.
      await run(certutil, ['-d', 'sql:$database', '-D', '-n', nickname]);
      if (await _inDatabase(certutil, database, ca)) {
        removed = false;
      }
    }
    return removed;
  }
}

class AndroidMitmTrustStore implements MitmTrustStore {
  AndroidMitmTrustStore(this.platform);

  final App platform;

  @override
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  ) async {
    final found = await platform.locateCaCertificate(mitmCertificateDer(ca));
    return MitmTrustCheck(
      found.user || found.system ? MitmTrust.ready : MitmTrust.notInstalled,
      systemStore: found.system,
      rootAvailable: found.root,
    );
  }

  /// Tries the system store with su first; a denied su falls back to the
  /// user store.
  @override
  Future<MitmInstallOutcome> install(MitmCertificate ca) async {
    final der = mitmCertificateDer(ca);
    if ((await platform.locateCaCertificate(der)).root) {
      final MitmInstallOutcome? outcome;
      try {
        outcome = await platform.installCaCertificateWithRoot(der);
      } on PlatformException catch (error) {
        commonPrint.log(
          'Installing the MITM certificate with root failed: ${error.message}',
          logLevel: LogLevel.warning,
        );
        throw MessageException(currentAppLocalizations.mitmSystemStoreFailed);
      }
      if (outcome != null) {
        return outcome;
      }
    }
    final outcome = await platform.installCaCertificate(
      der,
      name: ca.subject,
      fileName: mitmSavedFileName(ca),
    );
    if (outcome == null) {
      throw MessageException(currentAppLocalizations.mitmSystemStoreFailed);
    }
    return outcome;
  }

  /// An app cannot remove a user certificate.
  @override
  Future<bool> remove(MitmCertificate ca) async {
    final der = mitmCertificateDer(ca);
    final found = await platform.locateCaCertificate(der);
    if (found.system &&
        (!found.root || !await platform.removeCaCertificateWithRoot(der))) {
      return false;
    }
    return !found.user;
  }
}

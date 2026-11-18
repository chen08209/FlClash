import 'dart:io';

import 'package:path/path.dart' as p;

import 'context.dart';
import 'steps.dart';

String linuxBundlePath(PackageContext context) {
  final flutterArch = context.arch.name == 'arm64' ? 'arm64' : 'x64';
  return context.path('build/linux/$flutterArch/release/bundle');
}

/// dpkg-deb, rpmbuild and mksquashfs record modes verbatim, and the Helper
/// refuses to install from a group-writable tree, so the builder's umask must
/// not reach the package: directories 0755, files 0644, executables kept.
Command normalizePermissions(String directory) {
  return Command('chmod', ['-R', 'u=rwX,go=rX', directory]);
}

String _desktopEntry(Map<String, Object?> fields) {
  return [
    '[Desktop Entry]',
    for (final MapEntry(:key, :value) in fields.entries)
      if (value != null) '$key=$value',
  ].join('\n');
}

String? _joined(List<String> values) {
  return values.isEmpty ? null : '${values.join(';')};';
}

String? _plainJoined(List<String> values) {
  return values.isEmpty ? null : values.join(';');
}

Map<String, String> debFiles(
  PackageContext context,
  Map<String, dynamic> config,
) {
  final binary = context.linuxBinaryName;
  final maintainer = config['maintainer'] as Map<String, dynamic>;
  final control = <String, Object?>{
    'Maintainer': '${maintainer['name']} <${maintainer['email']}>',
    'Package': config['package_name'],
    'Version': context.pubspecVersion,
    'Section': config['section'] ?? 'x11',
    'Priority': config['priority'] ?? 'optional',
    'Architecture': context.arch.name,
    'Essential': config['essential'] == true ? 'yes' : 'no',
    'Installed-Size': config['installed_size'],
    'Description': context.description,
    'Depends': stringList(config['dependencies']).join(', '),
  };
  return {
    'DEBIAN/control':
        '${[for (final MapEntry(:key, :value) in control.entries)
          if (value != null && value != '') '$key: $value'].join('\n')}\n',
    'usr/share/applications/$binary.desktop': _desktopEntry({
      'Type': 'Application',
      'Name': config['display_name'],
      'GenericName': config['generic_name'],
      'Icon': binary,
      'Exec': '$binary %U',
      'MimeType': _joined(stringList(config['supported_mime_type'])),
      'Categories': _joined(stringList(config['categories'])),
      'Keywords': _joined(stringList(config['keywords'])),
      'StartupNotify': config['startup_notify'],
      'StartupWMClass': context.linuxApplicationId,
    }),
    'DEBIAN/postinst': [
      '#!/usr/bin/env sh',
      'ln -s /opt/$binary/$binary /usr/bin/$binary',
      'chmod +x /usr/bin/$binary',
      ...stringList(config['postinstall_scripts']),
      'exit 0',
    ].join('\n'),
    'DEBIAN/postrm': [
      '#!/usr/bin/env sh',
      'rm -f /usr/bin/$binary',
      ...stringList(config['postuninstall_scripts']),
      'exit 0',
    ].join('\n'),
  };
}

TargetPlan planDeb(PackageContext context) {
  final config = context.makeConfig('deb');
  final binary = context.linuxBinaryName;
  final stage = context.stagingPath('deb');
  final name = context.assetName(context.arch, 'deb');
  final icon = config['icon'] as String?;

  return TargetPlan(
    steps: [
      Task('stage the deb tree in $stage', () async {
        await recreateDirectory(stage);
        Directory(p.join(stage, 'opt', binary)).createSync(recursive: true);
        for (final MapEntry(:key, :value) in debFiles(
          context,
          config,
        ).entries) {
          final file = File(p.join(stage, key));
          file.parent.createSync(recursive: true);
          file.writeAsStringSync(value);
        }
        if (icon != null) {
          for (final size in ['128x128', '256x256']) {
            final dir = p.join(stage, 'usr/share/icons/hicolor/$size/apps');
            Directory(dir).createSync(recursive: true);
            File(
              context.path(icon),
            ).copySync(p.join(dir, '$binary${p.extension(icon)}'));
          }
        }
      }),
      Command('chmod', [
        '+x',
        '$stage/DEBIAN/postinst',
        '$stage/DEBIAN/postrm',
      ]),
      Command('cp', [
        '-fr',
        '${linuxBundlePath(context)}/.',
        '$stage/opt/$binary/',
      ]),
      normalizePermissions(stage),
      // Ubuntu 21.10+ defaults to zstd, which the dpkg of Debian derivatives
      // such as UOS cannot unpack.
      Command('dpkg-deb', [
        '--build',
        '--root-owner-group',
        '-Zxz',
        stage,
        context.outputPath(name),
      ]),
    ],
    artifacts: [PlannedArtifact(name: name, arch: context.arch)],
  );
}

String rpmArch(PackageContext context) {
  return context.arch.name == 'arm64' ? 'aarch64' : 'x86_64';
}

// appimagetool takes ARCH only under its own names, and it reads AppRun, a
// shell script, as armhf: an ARCH it rejects fails on arm64 as a mixed AppDir.
String appImageArch(PackageContext context) {
  return context.arch.name == 'arm64' ? 'arm_aarch64' : 'x86_64';
}

String rpmSpec(PackageContext context, Map<String, dynamic> config) {
  final binary = context.linuxBinaryName;
  final packager = config['packager'] as String?;
  final email =
      (config['packagerEmail'] ?? config['packager_email']) as String?;
  final preamble = <String, Object?>{
    'Name': config['package_name'] ?? binary,
    'Version': context.pubspecVersion,
    'Release': '${context.buildNumber}%{?dist}',
    'Summary': config['summary'] ?? context.description,
    'Group': config['group'],
    'Packager': email != null ? '$packager <$email>' : packager,
    'License': config['license'],
    'Requires': stringList(config['requires']).join(', '),
    'BuildArch': rpmArch(context),
  };
  final body = <String, String>{
    '%description': context.description,
    '%install': [
      'mkdir -p %{buildroot}%{_bindir}',
      'mkdir -p %{buildroot}%{_datadir}/%{name}',
      'mkdir -p %{buildroot}%{_datadir}/applications',
      'mkdir -p %{buildroot}%{_datadir}/metainfo',
      'mkdir -p %{buildroot}%{_datadir}/pixmaps',
      'cp -r $binary/* %{buildroot}%{_datadir}/%{name}',
      'ln -s %{_datadir}/%{name}/$binary %{buildroot}%{_bindir}/%{name}',
      'cp -r $binary.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop',
      'cp -r $binary.png %{buildroot}%{_datadir}/pixmaps/%{name}.png',
      'cp -r $binary*.xml %{buildroot}%{_datadir}/metainfo/%{name}.appdata.xml || :',
    ].join('\n'),
    '%post': [
      'update-mime-database %{_datadir}/mime &> /dev/null || :',
      ...stringList(config['postinstall_scripts']),
    ].join('\n'),
    '%postun': [
      'update-mime-database %{_datadir}/mime &> /dev/null || :',
      ...stringList(config['postuninstall_scripts']),
    ].join('\n'),
    '%files': [
      '%{_bindir}/%{name}',
      '%{_datadir}/%{name}',
      '%{_datadir}/applications/%{name}.desktop',
      '%{_datadir}/metainfo',
    ].join('\n'),
  };
  final macros = stringList(config['spec_macros']);
  return [
    if (macros.isNotEmpty) '${macros.join('\n')}\n\n',
    [
      for (final MapEntry(:key, :value) in preamble.entries)
        if (value != null && value != '') '$key: $value',
    ].join('\n'),
    '\n\n',
    [
      for (final MapEntry(:key, :value) in body.entries) '$key\n$value\n',
    ].join('\n'),
    '\n\n',
    '%defattr(-,root,root)\n',
    '\n',
    '%attr(4755, root, root) %{_datadir}/pixmaps/%{name}.png\n',
  ].join();
}

String rpmDesktopEntry(PackageContext context, Map<String, dynamic> config) {
  final name = (config['package_name'] ?? context.linuxBinaryName) as String;
  return _desktopEntry({
    'Type': 'Application',
    'Name': config['display_name'],
    'GenericName': config['generic_name'],
    'Icon': name,
    'Exec': '$name %U',
    'MimeType': _joined(stringList(config['supported_mime_type'])),
    'Categories': _joined(stringList(config['categories'])),
    'Keywords': _joined(stringList(config['keywords'])),
    'StartupNotify': config['startup_notify'],
    'StartupWMClass': context.linuxApplicationId,
  });
}

TargetPlan planRpm(PackageContext context) {
  final config = context.makeConfig('rpm');
  final binary = context.linuxBinaryName;
  final stage = context.stagingPath('rpm');
  final top = p.join(stage, 'rpmbuild');
  final build = p.join(top, 'BUILD');
  final buildRoot = p.join(build, binary);
  final spec = p.join(top, 'SPECS', '$binary.spec');
  final name = context.assetName(context.arch, 'rpm');
  final icon = config['icon'] as String?;

  return TargetPlan(
    steps: [
      Task('stage the rpmbuild tree in $top', () async {
        await recreateDirectory(stage);
        for (final dir in [
          'BUILD',
          'BUILDROOT',
          'RPMS',
          'SOURCES',
          'SPECS',
          'SRPMS',
        ]) {
          Directory(p.join(top, dir)).createSync(recursive: true);
        }
        Directory(buildRoot).createSync(recursive: true);
        if (icon != null) {
          File(
            context.path(icon),
          ).copySync(p.join(build, '$binary${p.extension(icon)}'));
        }
        File(spec).writeAsStringSync(rpmSpec(context, config));
        File(
          p.join(build, '$binary.desktop'),
        ).writeAsStringSync(rpmDesktopEntry(context, config));
      }),
      Command('cp', ['-r', '${linuxBundlePath(context)}/.', buildRoot]),
      normalizePermissions(buildRoot),
      Task('point every absolute RUNPATH in lib/*.so at \$ORIGIN '
          '(flutter/flutter#65400)', () async {
        for (final file in Directory(p.join(buildRoot, 'lib')).listSync()) {
          if (file is! File || !file.path.endsWith('.so')) continue;
          final rpath = await capture('patchelf', ['--print-rpath', file.path]);
          final sanitized = sanitizeRpath(rpath);
          if (sanitized != rpath) {
            await Command('patchelf', [
              '--set-rpath',
              sanitized,
              file.path,
            ]).run(verbose: false);
          }
        }
      }),
      Command(
        'rpmbuild',
        ['--define', '_topdir $top', '-bb', spec],
        environment: {'QA_RPATHS': '${0x0001 | 0x0010}'},
      ),
      Task('copy the rpm to ${context.outputPath(name)}', () async {
        final rpms = Directory(
          p.join(top, 'RPMS', rpmArch(context)),
        ).listSync().whereType<File>().toList();
        if (rpms.length != 1) {
          throw PackageError('rpmbuild wrote ${rpms.length} rpms, expected 1');
        }
        rpms.single.copySync(context.outputPath(name));
      }),
    ],
    artifacts: [PlannedArtifact(name: name, arch: context.arch)],
  );
}

String sanitizeRpath(String rpath) {
  final entries = <String>[];
  for (final entry in rpath.split(':')) {
    final sanitized = p.posix.isAbsolute(entry) ? r'$ORIGIN' : entry;
    if (!entries.contains(sanitized)) entries.add(sanitized);
  }
  return entries.join(':');
}

/// Libraries every target system provides and that must come from it, after
/// the AppImage project's excludelist. A bundled libstdc++ older than the
/// host's breaks the host's Mesa drivers, which load into the same process.
const appImageSystemLibraries = {
  'ld-linux-x86-64.so.2',
  'ld-linux-aarch64.so.1',
  'libc.so.6',
  'libdl.so.2',
  'libm.so.6',
  'libmvec.so.1',
  'libpthread.so.0',
  'libresolv.so.2',
  'librt.so.1',
  'libutil.so.1',
  'libstdc++.so.6',
  'libgcc_s.so.1',
  'libGL.so.1',
  'libEGL.so.1',
  'libGLdispatch.so.0',
  'libGLX.so.0',
  'libOpenGL.so.0',
  'libgbm.so.1',
  'libdrm.so.2',
  'libglapi.so.0',
  'libxcb.so.1',
  'libX11.so.6',
  'libX11-xcb.so.1',
  'libwayland-client.so.0',
  'libwayland-egl.so.1',
  'libasound.so.2',
  'libfontconfig.so.1',
  'libfreetype.so.6',
  'libharfbuzz.so.0',
  'libexpat.so.1',
  'libz.so.1',
};

Set<String> bundledLibraries(String lddOutput) {
  return {
    for (final line in lddOutput.split('\n'))
      if (line.contains('=>') && line.trim().startsWith('lib'))
        line.split(' => ')[1].trim().split(' ').first.trim(),
  }..removeWhere((path) => appImageSystemLibraries.contains(p.basename(path)));
}

String appImageDesktopEntry(
  PackageContext context,
  Map<String, dynamic> config,
) {
  final binary = context.linuxBinaryName;
  return '${_desktopEntry({'Name': config['display_name'], 'GenericName': config['generic_name'] ?? 'A Flutter Application', 'Exec': 'LD_LIBRARY_PATH=usr/lib $binary %u', 'Icon': binary, 'Type': 'Application', 'StartupNotify': config['startup_notify'] == true ? 'true' : 'false', 'StartupWMClass': context.linuxApplicationId, 'MimeType': _joined(stringList(config['supported_mime_type'])), 'Categories': _plainJoined(stringList(config['categories'])), 'Keywords': _plainJoined(stringList(config['keywords']))})}\n\n';
}

String appImageAppRun(String binary) {
  return '''
#!/bin/bash

cd "\$(dirname "\$0")"
export LD_LIBRARY_PATH="\$PWD/usr/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec ./$binary "\$@"
''';
}

TargetPlan planAppImage(PackageContext context) {
  final config = context.makeConfig('appimage');
  if (stringList(config['include']).isNotEmpty) {
    throw const PackageError('appimage include is not supported');
  }
  final binary = context.linuxBinaryName;
  final stage = context.stagingPath('appimage');
  final appDir = p.join(stage, '$binary.AppDir');
  final icon = config['icon'] as String;
  final name = context.assetName(context.arch, 'AppImage');

  return TargetPlan(
    steps: [
      Task('recreate $stage', () => recreateDirectory(stage)),
      Command('cp', ['-r', linuxBundlePath(context), appDir]),
      normalizePermissions(appDir),
      Task('write the desktop entry, AppRun and icons into $appDir', () async {
        File(
          p.join(appDir, '$binary.desktop'),
        ).writeAsStringSync(appImageDesktopEntry(context, config));
        File(
          p.join(appDir, 'AppRun'),
        ).writeAsStringSync(appImageAppRun(binary));
        final iconFile = File(context.path(icon));
        iconFile.copySync(p.join(appDir, '$binary${p.extension(icon)}'));
        for (final size in ['128x128', '256x256']) {
          final dir = p.join(appDir, 'usr/share/icons/hicolor/$size/apps');
          Directory(dir).createSync(recursive: true);
          iconFile.copySync(p.join(dir, '$binary${p.extension(icon)}'));
        }
      }),
      Command('chmod', ['+x', p.join(appDir, 'AppRun')]),
      Task('copy the libraries lib/*.so need beyond libflutter_linux_gtk.so '
          'and the host system into usr/lib', () async {
        final usrLib = p.join(appDir, 'usr/lib');
        Directory(usrLib).createSync(recursive: true);
        Future<Set<String>> deps(String so) async =>
            bundledLibraries(await capture('ldd', ['-d', so]));
        final flutterDeps = await deps(
          p.join(appDir, 'lib/libflutter_linux_gtk.so'),
        );
        const skipped = {
          'libapp.so',
          'libflutter_linux_gtk.so',
          'libgtk-3.so.0',
        };
        for (final so in Directory(p.join(appDir, 'lib')).listSync()) {
          if (so is! File || skipped.contains(p.basename(so.path))) continue;
          final needed = (await deps(so.path)).difference(flutterDeps)
            ..removeWhere((lib) => lib.contains('libflutter_linux_gtk.so'));
          for (final lib in needed) {
            File(lib).copySync(p.join(usrLib, p.basename(lib)));
          }
        }
      }),
      Command(
        'appimagetool',
        ['--no-appstream', appDir, context.outputPath(name)],
        environment: {'ARCH': appImageArch(context)},
      ),
    ],
    artifacts: [PlannedArtifact(name: name, arch: context.arch)],
  );
}

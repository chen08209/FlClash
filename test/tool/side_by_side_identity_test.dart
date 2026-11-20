import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

T _pick<T>(T rs, T flClash) => rsSideBySide ? rs : flClash;

final _packageName = _pick('FlClash RS', 'FlClash');

String _read(String path) => File(path).readAsStringSync();

YamlMap _yaml(String path) => loadYaml(_read(path)) as YamlMap;

String? _rustConst(String path, String name) {
  return RegExp(
    'const $name: &str = r?"([^"]+)";',
  ).firstMatch(_read(path))?.group(1);
}

void main() {
  test('the app, the package and side-by-side entries keep their names', () {
    expect(appName, 'FlClash');
    expect(packageDisplayName, _packageName);
    expect(sideBySideName, _pick('FlClash rs', 'FlClash'));
    final installer = _yaml('windows/packaging/exe/make_config.yaml');
    expect(
      (installer['display_name'] as String).toLowerCase(),
      sideBySideName.toLowerCase(),
      reason: 'the installer repoints the autostart Run value by this name',
    );
  });

  test('macOS names and labels the bundle as the package', () {
    expect(
      _read('macos/Runner/Configs/AppInfo.xcconfig'),
      contains('PRODUCT_NAME = $_packageName\n'),
    );
    final displayName = _pick('"$_packageName"', _packageName);
    expect(
      'INFOPLIST_KEY_CFBundleDisplayName = $displayName;'
          .allMatches(_read('macos/Runner.xcodeproj/project.pbxproj'))
          .length,
      3,
    );
    final dmg = _yaml('macos/packaging/dmg/make_config.yaml');
    expect(dmg['title'], _packageName);
    expect(
      (dmg['contents'] as YamlList).map((item) => item['path']),
      contains('$_packageName.app'),
    );
  });

  test('Windows keeps its own installer, folders and data directory', () {
    final productDirectory = _pick('clash.rs', 'clash');
    final binary = _pick('FlClash-RS', 'FlClash');
    expect(
      _read('windows/CMakeLists.txt'),
      contains('set(BINARY_NAME "$binary")'),
    );
    final runner = _read('windows/runner/Runner.rc');
    expect(runner, contains('"FileDescription", "$_packageName"'));
    expect(runner, contains('"ProductName", "$productDirectory"'));
    expect(runner, contains('"OriginalFilename", "$binary.exe"'));
    expect(
      runner,
      contains('"InternalName", "${_pick('FlClash-RS', 'clash')}"'),
    );
    expect(
      _read('windows/runner/main.cpp'),
      contains('window.Create(L"$_packageName"'),
    );

    final installer = _yaml('windows/packaging/exe/make_config.yaml');
    expect(installer['app_name'], _packageName);
    expect(installer['display_name'], _packageName);
    expect(installer['executable_name'], '$binary.exe');
    expect(
      installer['app_id'],
      _pick(
        'F353B6F4-AA56-4EC4-86F0-AEA464099350',
        '728B3532-C74B-4870-9068-BE70FE12A3E6',
      ),
    );
    expect(
      installer['install_dir_name'],
      _pick(r'{autopf64}\FlClash rs', null),
    );
    expect(
      _read('windows/packaging/exe/inno_setup.iss'),
      contains(
        r'{userappdata}\com.follow\'
        '$productDirectory',
      ),
    );
  });

  test('the Helper registers under the names the app looks for', () {
    expect(
      _rustConst('services/helper/src/service/windows.rs', 'SERVICE_NAME'),
      helperServiceName,
    );
    expect(
      _rustConst('services/helper/src/service/linux.rs', 'UNIT_PATH'),
      helperUnitPath,
    );
    expect(
      _rustConst('services/helper/src/service/linux.rs', 'SOCKET_PATH'),
      helperSocketPath,
    );
  });

  test('Linux installs under its own binary and package names', () {
    expect(
      _read('linux/CMakeLists.txt'),
      contains('set(BINARY_NAME "${_pick('FlClash-rs', 'FlClash')}")'),
    );
    expect(
      '"$_packageName"'
          .allMatches(_read('linux/runner/my_application.cc'))
          .length,
      2,
    );
    for (final format in ['deb', 'rpm', 'appimage']) {
      final config = _yaml('linux/packaging/$format/make_config.yaml');
      expect(config['display_name'], _packageName, reason: format);
      expect(config['generic_name'], _packageName, reason: format);
    }
    expect(
      _yaml('linux/packaging/deb/make_config.yaml')['package_name'],
      _pick('flclash-rs', 'FlClash'),
    );
    expect(
      _yaml('linux/packaging/rpm/make_config.yaml')['package_name'],
      _pick('flclash-rs', null),
    );
  });

  test('Android labels the launcher as the package', () {
    expect(
      _read('android/common/src/main/res/values/strings.xml'),
      contains('<string name="app_name">$_packageName</string>'),
    );
  });
}

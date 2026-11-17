import 'package:setup_hooks/src/concord_builder.dart';
import 'package:setup_hooks/src/error.dart';
import 'package:test/test.dart';

void main() {
  test('the Core Info.plist carries the bundle identifier', () {
    expect(
      coreInfoPlist('com.follow.clash.rs.core'),
      contains('<string>com.follow.clash.rs.core</string>'),
    );
  });

  test('a bundle identifier without a dot is refused', () {
    for (final id in ['FlClashCore', 'a..b', '.core', 'core.', 'a.b<c']) {
      expect(
        () => coreInfoPlist(id),
        throwsA(isA<BuildException>()),
        reason: id,
      );
    }
  });

  test('every linker flag reaches ld through its own -Xlinker', () {
    expect(infoPlistLinkArguments('/a b/core-info.plist'), [
      for (final argument in [
        '-sectcreate',
        '__TEXT',
        '__info_plist',
        '/a b/core-info.plist',
      ]) ...['-C', 'link-arg=-Xlinker', '-C', 'link-arg=$argument'],
    ]);
  });
}

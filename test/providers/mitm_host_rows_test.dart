import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/module_reads.dart';

void main() {
  MitmModuleDetails details() => moduleDetails(
    '[MITM]\nhostname = a.test, -skip.test, bad x',
    moduleRead(
      views: {
        'hostname': [
          lineEntry(
            1,
            const MitmLineView.hosts(
              entries: [
                MitmHostEntry(host: 'a.test'),
                MitmHostEntry(host: 'skip.test', exclude: true),
                MitmHostEntry(host: 'bad x', reason: 'Unsupported'),
              ],
            ),
          ),
        ],
      },
    ),
  );

  test('a module makes its host search texts once per label', () {
    final module = details();
    final texts = module.hostSearchTexts('excluded');

    expect(texts, ['a.test', 'skip.test\nexcluded', 'bad x\nunsupported']);
    expect(identical(module.hostSearchTexts('excluded'), texts), isTrue);
    expect(module.hostSearchTexts('排除')[1], 'skip.test\n排除');
    expect(SearchQuery('exc').matchesText(texts[1]), isTrue);
  });
}

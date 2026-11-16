import 'package:fl_clash/features/icloud/section.dart';
import 'package:fl_clash/features/icloud/sync.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows disabled state, pending conflict and failures', (
    tester,
  ) async {
    final sync = ICloudYamlSync();
    addTearDown(sync.dispose);
    await tester.pumpWidget(TestApp(child: ICloudSyncSection(sync: sync)));
    await tester.pumpAndSettle();
    expect(find.text('iCloud Drive · YAML'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);

    sync.folder = '/iCloud/FlClash';
    sync.conflicts['example.yaml'] = const YamlConflict(
      'example.yaml',
      'a',
      'b',
    );
    sync.error = StateError('offline');
    await tester.pumpWidget(
      TestApp(
        child: ICloudSyncSection(key: UniqueKey(), sync: sync),
      ),
    );
    expect(find.text('example.yaml'), findsOneWidget);
    expect(find.text('Local ≠ Remote'), findsOneWidget);
    expect(find.textContaining('offline'), findsOneWidget);

    sync.busy = true;
    await tester.pumpWidget(
      TestApp(
        child: ICloudSyncSection(key: UniqueKey(), sync: sync),
      ),
    );
    expect(
      tester.widget<TonalButton>(find.byType(TonalButton)).onPressed,
      isNull,
    );
  });
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/resources.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('uses decorated sections without displaying resource URLs', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DecorationListItem), findsNWidgets(6));
    expect(find.byType(ItemPositionProvider), findsNWidgets(4));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNWidgets(4));
    expect(find.byType(FutureBuilder<FileInfo?>), findsNWidgets(4));
    for (final url in defaultGeoXUrl.values) {
      expect(find.text(url), findsNothing);
    }

    final mmdbItem = find.ancestor(
      of: find.text(GeoResource.MMDB.name),
      matching: find.byType(DecorationListItem),
    );
    await tester.tap(
      find.descendant(of: mmdbItem, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.edit), findsOneWidget);
    expect(find.text(currentAppLocalizations.sync), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

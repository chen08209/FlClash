import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _HeightProbe extends ConsumerWidget {
  final double factor;

  const _HeightProbe(this.factor);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(height: ref.sheetHeight(context, factor));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(800, 600));
  });

  Future<double> pumpProbe(
    WidgetTester tester, {
    required SheetType type,
    double factor = 0.5,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SheetProvider(type: type, child: _HeightProbe(factor)),
        ),
      ),
    );
    return tester.widget<SizedBox>(find.byType(SizedBox)).height!;
  }

  testWidgets('a bottom sheet takes its share of the current view height', (
    tester,
  ) async {
    expect(await pumpProbe(tester, type: SheetType.bottomSheet), 600 * 0.5);
  });

  testWidgets('any other sheet type stays unbounded', (tester) async {
    expect(await pumpProbe(tester, type: SheetType.page), double.maxFinite);
  });

  testWidgets('a bottom sheet follows the view height while it is open', (
    tester,
  ) async {
    await pumpProbe(tester, type: SheetType.bottomSheet, factor: 0.6);

    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(800, 900));
    await tester.pump();

    expect(tester.widget<SizedBox>(find.byType(SizedBox)).height, 900 * 0.6);
  });

  testWidgets('a resize does not resize a non-bottom sheet', (tester) async {
    await pumpProbe(tester, type: SheetType.page);

    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(800, 900));
    await tester.pump();

    expect(
      tester.widget<SizedBox>(find.byType(SizedBox)).height,
      double.maxFinite,
    );
  });
}

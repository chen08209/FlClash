import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

void main() {
  testWidgets('the gaps between record cards do not misjudge the list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: SuperListView.separated(
          controller: controller,
          itemCount: 200,
          extentEstimation: recordListExtentEstimation,
          separatorBuilder: (_, _) => const SizedBox(height: recordListGap),
          itemBuilder: (_, index) =>
              SizedBox(height: 100, child: Text('$index')),
        ),
      ),
    );
    final viewport = controller.position.viewportDimension;
    const extent = 200 * 100 + 199 * recordListGap;

    expect(controller.position.maxScrollExtent, extent - viewport);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(controller.position.maxScrollExtent, extent - viewport);
    expect(controller.offset, controller.position.maxScrollExtent);
  });
}

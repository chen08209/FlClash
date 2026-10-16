import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _Form extends StatefulWidget {
  const _Form({this.onDismiss});

  final SheetDismissHandler? onDismiss;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onDismiss case final onDismiss?) {
      SheetDismissScope.of(context)!.value = onDismiss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: 'Form',
      onSave: () {},
      children: [
        generateSection(
          items: const [FormRow(title: 'Name', trailing: FormRowTextField())],
        ),
      ],
    );
  }
}

Future<void> _open(
  WidgetTester tester,
  Size size, {
  _Form form = const _Form(),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    TestApp(
      overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
      child: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                showFormSheet<void>(context: context, builder: (_) => form),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

SheetType? _sheetType(WidgetTester tester) =>
    SheetProvider.of(tester.element(find.byType(FormRowTextField)))?.type;

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('a desktop form is a card centered over the window', (
    tester,
  ) async {
    await _open(tester, const Size(1200, 800));

    expect(_sheetType(tester), SheetType.formSheet);
    final card = find
        .ancestor(of: find.byType(FormPage), matching: find.byType(Material))
        .first;
    expect(tester.getCenter(card).dx, 600);
    expect(tester.getSize(card).width, 440);
    expect(_field(tester).textAlign, TextAlign.end);
    expect(_field(tester).decoration?.border, isA<NoInputBorder>());
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
    expect(find.byTooltip('Save'), findsNothing);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('a mobile form is a bottom sheet with bare fields', (
    tester,
  ) async {
    await _open(tester, const Size(390, 844));

    expect(_sheetType(tester), SheetType.bottomSheet);
    expect(_field(tester).textAlign, TextAlign.end);
    expect(_field(tester).decoration?.border, isA<NoInputBorder>());
    expect(find.byTooltip('Save'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
  });

  testWidgets('a bare field floats no label, whose focus animation would lay '
      'the form out on every frame', (tester) async {
    await _open(tester, const Size(390, 844));

    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(
      decorator.decoration.floatingLabelBehavior,
      FloatingLabelBehavior.never,
    );
  });

  testWidgets('cancel at the foot closes the card', (tester) async {
    await _open(tester, const Size(1200, 800));

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(FormPage), findsNothing);
  });

  testWidgets('a tap outside the card closes it', (tester) async {
    await _open(tester, const Size(1200, 800));

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.byType(FormPage), findsNothing);
  });

  testWidgets('a tap outside goes to the form when it takes the dismiss', (
    tester,
  ) async {
    var asked = 0;
    await _open(
      tester,
      const Size(1200, 800),
      form: _Form(onDismiss: () async => asked++),
    );

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(asked, 1);
    expect(find.byType(FormPage), findsOneWidget);
  });
}

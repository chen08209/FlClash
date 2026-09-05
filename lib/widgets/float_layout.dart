import 'package:fl_clash/common/system.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';

class FloatLayout extends StatelessWidget {
  final Widget floatingWidget;
  final Widget child;
  final bool? isTV;

  const FloatLayout({
    super.key,
    required this.floatingWidget,
    this.isTV,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isTV ?? system.isTV) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          floatingWidget,
          Expanded(child: Center(child: child)),
        ],
      );
    }
    final bottomInset = BottomInsetScope.of(context);
    return Stack(
      fit: StackFit.loose,
      children: [
        Center(
          child: BottomInsetScope(
            inset: bottomInset + BottomInsetScope.floatingActionButtonInset,
            child: child,
          ),
        ),
        Positioned(bottom: bottomInset, right: 0, child: floatingWidget),
      ],
    );
  }
}

class FloatWrapper extends StatelessWidget {
  final Widget child;

  const FloatWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kFloatingActionButtonMargin),
      child: child,
    );
  }
}

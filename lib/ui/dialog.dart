import 'package:animations/animations.dart';
import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/view_scope.dart';
import 'package:material_ui/material_ui.dart';

Future<T?> showFloatingDialog<T>({
  required BuildContext context,
  required Widget child,
  bool dismissible = true,
}) {
  return showModal<T>(
    useRootNavigator: false,
    context: context,
    configuration: FadeScaleTransitionConfiguration(
      barrierColor: context.colorScheme.modalScrim,
      barrierDismissible: dismissible,
    ),
    builder: (context) => SurfaceScope(
      level: SurfaceLevel.floatingOf(context.colorScheme),
      child: child,
    ),
  );
}

class CommonDialog extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets? padding;

  const CommonDialog({
    super.key,
    required this.title,
    this.trailing,
    this.actions,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final size = ViewScope.sizeOf(context);
    return AlertDialog(
      title: trailing == null
          ? Text(title)
          : Row(
              children: [
                Expanded(child: Text(title)),
                trailing!,
              ],
            ),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      contentPadding: padding,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        width: size.width - 40,
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

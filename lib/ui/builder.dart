import 'package:material_ui/material_ui.dart';

typedef WidthWidgetBuilder =
    Widget Function(BuildContext context, double width);

/// A bottom sheet lays its content out at each height it is dragged through,
/// where a [LayoutBuilder] would rebuild every row below it on every frame.
class WidthBuilder extends StatefulWidget {
  final WidthWidgetBuilder builder;

  const WidthBuilder({super.key, required this.builder});

  @override
  State<WidthBuilder> createState() => _WidthBuilderState();
}

class _WidthBuilderState extends State<WidthBuilder> {
  _WidthBuilt? _built;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final built = _built;
        if (built != null &&
            built.width == width &&
            identical(built.builder, widget.builder)) {
          return built;
        }
        return _built = _WidthBuilt(width: width, builder: widget.builder);
      },
    );
  }
}

class _WidthBuilt extends StatelessWidget {
  final double width;
  final WidthWidgetBuilder builder;

  const _WidthBuilt({required this.width, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context, width);
}

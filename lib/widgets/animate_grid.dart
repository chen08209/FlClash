import 'package:flutter/material.dart';

typedef AnimatedGridBuilder<T> = Widget Function(BuildContext, T item);

class AnimateGrid<T> extends StatelessWidget {
  final int columns;
  final double itemHeight;
  final double gap;
  final List<T> items;
  final Key Function(T item) keyBuilder;
  final AnimatedGridBuilder<T> builder;
  final Duration duration;
  final Curve curve;

  const AnimateGrid({
    super.key,
    required this.items,
    required this.itemHeight,
    required this.keyBuilder,
    required this.builder,
    this.gap = 8,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.columns = 2,
  });

  int _rows(int columns, int count) => (count / columns).ceil();

  Offset _getOffset(
    int index,
    int count,
    double itemWidth,
    double itemHeight,
  ) {
    final xIndex = index % columns;
    final yIndex = (index / columns).floor();
    return Offset(
        xIndex * itemWidth + xIndex * gap, yIndex * itemHeight + yIndex * gap);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      assert(constraints.hasBoundedHeight == false);
      final gapWidth = (columns - 1) * gap;
      final width = constraints.maxWidth;
      final itemWidth = (width - gapWidth) / columns;
      final count = items.length;
      final rows = _rows(columns, count);
      final gapHeight = (rows - 1) * gap;
      final height = rows * itemHeight + gapHeight;
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            for (var i = 0; i <= count - 1; i++)
              Builder(
                key: keyBuilder(items[i]),
                builder: (context) {
                  final item = items[i];
                  final offset = _getOffset(
                    i,
                    count,
                    itemWidth,
                    itemHeight,
                  );
                  return TweenAnimationBuilder(
                    tween: Tween<Offset>(end: offset),
                    duration: duration,
                    curve: curve,
                    builder: (_, offset, child) {
                      return Transform.translate(
                        offset: offset,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      height: itemHeight,
                      width: itemWidth,
                      child: builder(
                        context,
                        item,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}

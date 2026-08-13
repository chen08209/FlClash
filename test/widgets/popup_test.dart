import 'package:fl_clash/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverflowAwareLayoutDelegate', () {
    Offset position({
      required Offset offset,
      required Size size,
      required Size childSize,
    }) {
      return OverflowAwareLayoutDelegate(
        offset: offset,
      ).getPositionForChild(size, childSize);
    }

    test('places the child to the left of the anchor', () {
      expect(
        position(
          offset: const Offset(300, 200),
          size: const Size(800, 600),
          childSize: const Size(100, 50),
        ),
        const Offset(200, 200),
      );
    });

    test('keeps the child inside the right and bottom edges', () {
      expect(
        position(
          offset: const Offset(790, 590),
          size: const Size(800, 600),
          childSize: const Size(100, 50),
        ),
        const Offset(684, 534),
      );
    });

    test('never returns a negative position', () {
      expect(
        position(
          offset: Offset.zero,
          size: const Size(800, 600),
          childSize: const Size(100, 50),
        ),
        Offset.zero,
      );
    });

    // A child larger than the viewport puts clamp's upper bound below its
    // lower one, which throws instead of laying out.
    test('does not throw when the child is wider than the viewport', () {
      expect(
        position(
          offset: const Offset(100, 100),
          size: const Size(200, 600),
          childSize: const Size(400, 50),
        ),
        const Offset(0, 100),
      );
    });

    test('does not throw when the child is taller than the viewport', () {
      expect(
        position(
          offset: const Offset(100, 100),
          size: const Size(800, 100),
          childSize: const Size(100, 400),
        ),
        const Offset(0, 0),
      );
    });

    test('does not throw when the child exactly fills the viewport', () {
      expect(
        position(
          offset: const Offset(50, 50),
          size: const Size(200, 200),
          childSize: const Size(200, 200),
        ),
        Offset.zero,
      );
    });
  });
}

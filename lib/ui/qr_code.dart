import 'package:fl_clash/ui/shape.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

/// Dark modules on white whatever the theme: camera apps read an inverted code
/// poorly, and the quiet zone the standard asks for is part of the white.
class QrCodeView extends StatelessWidget {
  final String data;
  final double size;

  const QrCodeView({super.key, required this.data, this.size = 240});

  static const _quietZone = 4;

  static QrCode? _encode(String data) {
    try {
      return QrCode(payload: QrPayload.fromString(data));
    } on InputTooLongException {
      return null;
    }
  }

  static bool fits(String data) => _encode(data) != null;

  @override
  Widget build(BuildContext context) {
    final code = _encode(data);
    if (code == null) {
      return SelectableText(data, textAlign: TextAlign.center);
    }
    final image = QrImage(code);
    return Semantics(
      image: true,
      label: data,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: const ShapeDecoration(
              shape: AppShape.md,
              color: Colors.white,
            ),
            child: CustomPaint(painter: _QrPainter(image)),
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage image;

  _QrPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final module = size.shortestSide / (count + QrCodeView._quietZone * 2);
    final origin = module * QrCodeView._quietZone;
    final path = Path();
    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        if (image.isDark(y, x)) {
          path.addRect(
            Rect.fromLTWH(
              origin + x * module,
              origin + y * module,
              module,
              module,
            ),
          );
        }
      }
    }
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}

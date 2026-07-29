import 'dart:typed_data';

import 'package:fl_clash/common/converter.dart';
import 'package:test/test.dart';

void main() {
  group('Uint8ListToListIntConverter', () {
    test('converts bytes to a growable int list copy', () {
      final source = Uint8List.fromList([1, 2, 255]);

      final result = uint8ListToListIntConverter.convert(source);
      source[0] = 9;
      result.add(3);

      expect(result, [1, 2, 255, 3]);
    });

    test('forwards chunked conversions and closes target sink', () {
      final sink = _CollectingSink();
      final converterSink = uint8ListToListIntConverter.startChunkedConversion(
        sink,
      );

      converterSink.add(Uint8List.fromList([1, 2]));
      converterSink.add(Uint8List.fromList([3]));
      converterSink.close();

      expect(sink.values, [
        [1, 2],
        [3],
      ]);
      expect(sink.isClosed, isTrue);
    });
  });
}

class _CollectingSink implements Sink<List<int>> {
  final values = <List<int>>[];
  var isClosed = false;

  @override
  void add(List<int> data) {
    values.add(data);
  }

  @override
  void close() {
    isClosed = true;
  }
}

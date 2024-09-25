import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

void main() {
  group('Test Number Transformer', () {
    test('should convert to number', () {
      var transformer = NumberTransformer();

      var result = transformer.transform('123', (_) {});

      expect(result, isA<num>());
      expect(result, equals(123));
    });

    test('should return null if value is not a number', () {
      var transformer = NumberTransformer();

      var result = transformer.transform('abc', (_) {});

      expect(result, isNull);

      result = transformer.transform(true, (_) {});

      expect(result, isNull);
    });
  });
}

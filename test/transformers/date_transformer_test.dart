import 'package:test/test.dart';
import 'package:validasi/src/transformers/date_transformer.dart';

void main() {
  group('Test Date Transformer', () {
    test('should convet to DateTime', () {
      var transformer = DateTransformer();

      var result = transformer.transform('2021-01-01');

      expect(result, isA<DateTime>());

      expect(result, equals(DateTime(2021, 1, 1)));
    });

    test('should return null if value is not a date', () {
      var transformer = DateTransformer();

      var result = transformer.transform('abc');

      expect(result, isNull);

      result = transformer.transform(true);

      expect(result, isNull);
    });
  });
}

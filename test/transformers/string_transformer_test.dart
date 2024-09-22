import 'package:test/test.dart';
import 'package:validasi/src/transformers/string_transformer.dart';

void main() {
  group('Test String Transformer', () {
    test('can convert to string', () {
      var transformer = StringTransformer();

      var result = transformer.transform(123, (_) {});

      expect(result, isA<String>());
      expect(result, equals('123'));
    });
  });
}

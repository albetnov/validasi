import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';

void main() {
  group('Generic Validation Test', () {
    test('Can create generic validation', () {
      var schema = Validasi.generic<String>();

      expect(schema, isA<GenericValidator>());
    });

    test('Can validate type check on value', () {
      var schema = Validasi.generic<String>();

      shouldNotThrow(() {
        schema.parse('a');
      });

      expect(
          () => schema.parse(1),
          throwFieldError(
            name: 'invalidType',
            message: 'Expected type String. Got int instead.',
          ));
    });

    test('Can validate type check on value with transformer', () {
      var schema = Validasi.generic<String>(transformer: StringTransformer());

      shouldNotThrow(() {
        schema.parse(1);
      });
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

void main() {
  group('Result Test', () {
    test('can make Result instance', () {
      var result = Result();

      expect(result.value, isA<dynamic>());
      expect(result.value, isNull);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('can contain the value', () {
      var result = Result(value: 'value');

      expect(result.value, isA<String?>());
      expect(result.isValid, isTrue);
      expect(result.value, equals('value'));
    });

    test('can contain errors', () {
      var errors = [FieldError(name: 'name', message: 'message', path: 'path')];
      var result = Result(value: 'example', errors: errors);

      expect(result.errors, hasLength(1));
      expect(result.errors, equals(errors));
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';

void main() {
  group('Field Error Test', () {
    test('can create FieldError instance', () {
      FieldError fieldError = FieldError(
          name: 'rule_name', message: 'example message', path: 'example_path');

      expect(fieldError.name, equals('rule_name'));
      expect(fieldError.message, equals('example message'));
      expect(fieldError.path, equals('example_path'));
      expect(fieldError, isA<Error>());
    });

    test('toString return message', () {
      FieldError fieldError = FieldError(
          name: 'rule_name', message: 'example message', path: 'example_path');

      expect("$fieldError", equals(fieldError.message));
    });

    test('can parse parent, field, and paths (nested)', () {
      var path = 'some.nested.path';

      FieldError fieldError =
          FieldError(name: 'rule_name', message: 'message', path: path);

      expect(fieldError.field, equals('path'));
      expect(fieldError.parent, equals('some'));
      expect(fieldError.paths, equals(path.split('.')));
    });

    test('can parse parent, field, and paths from invalid nested', () {
      FieldError fieldError =
          FieldError(name: 'name', message: 'message', path: 'example.');

      expect(fieldError.field, equals(''));
      expect(fieldError.parent, equals('example'));
      expect(fieldError.paths, hasLength(2));
      expect(fieldError.paths, containsAll(['example', '']));
    });

    test('contains same path if no dot (.) notation found', () {
      FieldError fieldError =
          FieldError(name: 'name', message: 'message', path: 'example');

      expect(fieldError.paths, hasLength(1));
      expect(fieldError.paths, contains('example'));
      expect(fieldError.field, equals('example'));
      expect(fieldError.parent, equals('example'));
    });
  });
}

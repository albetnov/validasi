import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/validator_rule.dart';

void main() {
  group('Validator Rule Test', () {
    test('can create ValidatorRule instance', () {
      var rule = ValidatorRule(
          name: 'required',
          test: (value) => false,
          message: 'field is required');

      expect(rule.name, equals('required'));
      expect(rule.message, equals('field is required'));
      expect(rule.test, isA<bool Function(Object? value)>());
    });

    test('can enforce type', () {
      var rule = ValidatorRule<String>(
          name: 'required',
          test: (value) {
            expect(value, isA<String?>());

            return true;
          },
          message: 'message');

      expect(rule.test, isA<bool Function(String value)>());
      expect(rule.check, isA<void Function(String value)>());
    });

    test('check correctly adjust the isPassed', () {
      var rule = ValidatorRule(
          name: 'example_fail', test: (value) => false, message: 'fail');

      rule.check('fail');

      expect(rule.passed, isFalse);

      var rule2 = ValidatorRule(
          name: 'example_valid', test: (value) => true, message: 'valid');

      rule2.check('valid');

      expect(rule2.passed, isTrue);
    });

    test('can convert to field error', () {
      var rule = ValidatorRule(
          name: 'example_fail',
          test: (value) => false,
          message: ':name message');

      var fieldError = rule.toFieldError('example');

      expect(fieldError, isA<FieldError>());
      expect(fieldError.path, equals('example'));
      expect(fieldError.message, equals('example message'));
      expect(fieldError.name, equals('example_fail'));
    });
  });
}

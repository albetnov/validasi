import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/result.dart';

import '../validators/validator_test_stub.dart';

void main() {
  group('Field Validator Test', () {
    late FieldValidator fieldValidator;
    late MockValidatorStub<int> mockValidator;

    setUp(() {
      mockValidator = MockValidatorStub();

      when(mockValidator.parse(argThat(isA<int>()), path: anyNamed('path')))
          .thenReturn(Result(value: 1));

      when(mockValidator.parseAsync(isA<int>(), path: anyNamed('path')))
          .thenAnswer((_) async => Result(value: 1));

      when(mockValidator.parse(argThat(isA<String>()), path: anyNamed('path')))
          .thenThrow(FieldError(
              name: 'example', message: 'example message', path: 'field'));

      when(mockValidator.parseAsync(argThat(isA<String>()),
              path: anyNamed('path')))
          .thenThrow(FieldError(
              name: 'example', message: 'example message', path: 'field'));

      fieldValidator = FieldValidator(mockValidator);
    });

    test('should pass for validate', () {
      fieldValidator.validate(123);

      verify(mockValidator.parse(123)).called(1);

      fieldValidator.validate(123, path: 'custom');

      verify(mockValidator.parse(123, path: 'custom')).called(1);
    });

    test('should fail for validate when rule fail', () {
      expect(fieldValidator.validate('text'), equals('example message'));
    });

    test('should pass for validateAsync', () async {
      await fieldValidator.validateAsync(123);

      verify(mockValidator.parseAsync(123)).called(1);

      await fieldValidator.validateAsync(123, path: 'custom');

      verify(mockValidator.parseAsync(123, path: 'custom')).called(1);
    });

    test('shold fail for validateAsync when rule fail', () async {
      expect(await fieldValidator.validateAsync('text'),
          equals('example message'));
    });
  });
}

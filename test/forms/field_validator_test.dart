import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/result.dart';

import '../validators/validator_test_stub.mocks.dart';

void main() {
  group('Field Validator Test', () {
    late MockValidator<int> mockValidator;

    setUp(() {
      mockValidator = MockValidator();

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
    });

    test('should pass for validate', () {
      FieldValidator(mockValidator).validate(123);

      verify(mockValidator.parse(123)).called(1);

      FieldValidator(mockValidator, path: 'custom').validate(123);

      verify(mockValidator.parse(123, path: 'custom')).called(1);
    });

    test('should fail for validate when rule fail', () {
      expect(FieldValidator(mockValidator).validate('text'),
          equals('example message'));
    });

    test('should pass for validateAsync', () async {
      await FieldValidator(mockValidator).validateAsync(123);

      verify(mockValidator.parseAsync(123)).called(1);

      await FieldValidator(mockValidator, path: 'custom').validateAsync(123);

      verify(mockValidator.parseAsync(123, path: 'custom')).called(1);
    });

    test('shold fail for validateAsync when rule fail', () async {
      expect(await FieldValidator(mockValidator).validateAsync('text'),
          equals('example message'));
    });
  });
}

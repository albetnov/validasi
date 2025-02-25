import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/group_validator.dart';
import 'package:validasi/src/result.dart';

import '../validators/validator_test_stub.mocks.dart';

void main() {
  group('Group Validator Test', () {
    late GroupValidator groupValidator;
    late MockValidator<int> mockValidatorAge;
    late MockValidator<String> mockValidatorName;

    setUp(() {
      mockValidatorAge = MockValidator();

      when(mockValidatorAge.parse(argThat(isA<int>()), path: anyNamed('path')))
          .thenReturn(Result(value: 1));

      when(mockValidatorAge.parseAsync(isA<int>(), path: anyNamed('path')))
          .thenAnswer((_) async => Result(value: 1));

      when(mockValidatorAge.parse(argThat(isA<String>()),
              path: anyNamed('path')))
          .thenThrow(FieldError(
              name: 'example', message: 'example message', path: 'field'));

      when(mockValidatorAge.parseAsync(argThat(isA<String>()),
              path: anyNamed('path')))
          .thenThrow(FieldError(
              name: 'example', message: 'example message', path: 'field'));

      mockValidatorName = MockValidator();

      when(mockValidatorName.parse(argThat(isA<String>()),
              path: anyNamed('path')))
          .thenReturn(Result(value: 'name'));

      when(mockValidatorName.parseAsync(isA<String>(), path: anyNamed('path')))
          .thenAnswer((_) async => Result(value: 'name'));

      groupValidator =
          GroupValidator({'age': mockValidatorAge, 'name': mockValidatorName});
    });

    test('should pass for validate', () {
      groupValidator.on('name').validate('Asep Surasep');

      verify(mockValidatorName.parse('Asep Surasep')).called(1);

      groupValidator.on('age').validate(25);

      verify(mockValidatorAge.parse(25)).called(1);
    });

    test('should fail when no key found for validate', () {
      expect(
          () => groupValidator.on('address').validate('Jl. Jalan'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message == 'address is not found on the schema')));
    });

    test('should fail for validate when rule fail', () {
      expect(
          groupValidator.on('age').validate('text'), equals('example message'));
    });

    test('should pass for validateAsync', () async {
      await groupValidator.on('name').validateAsync('Asep Surasep');

      verify(mockValidatorName.parseAsync('Asep Surasep')).called(1);

      await groupValidator.on('age').validateAsync(25);

      verify(mockValidatorAge.parseAsync(25)).called(1);
    });

    test('should fail when no key found for validateAsync', () async {
      await expectLater(
          () => groupValidator.on('address').validateAsync('Jl. Jalan'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message == 'address is not found on the schema')));
    });

    test('should fail for validateAsync when rule fail', () async {
      expect(await groupValidator.on('age').validateAsync('text'),
          equals('example message'));
    });
  });
}

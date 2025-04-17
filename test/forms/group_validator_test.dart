import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/group_validator.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/string_validator.dart';

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
      groupValidator.using('name').validate('Asep Surasep');

      verify(mockValidatorName.parse('Asep Surasep', path: 'name')).called(1);

      groupValidator.using('age').validate(25);

      verify(mockValidatorAge.parse(25, path: 'age')).called(1);
    });

    test('should fail when no key found for validate', () {
      expect(
          () => groupValidator.using('address').validate('Jl. Jalan'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message == 'Field \'address\' is not found in the schema')));
    });

    test('should fail for validate when rule fail', () {
      expect(groupValidator.using('age').validate('text'),
          equals('example message'));
    });

    test('should pass for validateAsync', () async {
      await groupValidator.using('name').validateAsync('Asep Surasep');

      verify(mockValidatorName.parseAsync('Asep Surasep', path: 'name'))
          .called(1);

      await groupValidator.using('age').validateAsync(25);

      verify(mockValidatorAge.parseAsync(25, path: 'age')).called(1);
    });

    test('should fail when no key found for validateAsync', () async {
      await expectLater(
          () => groupValidator.using('address').validateAsync('Jl. Jalan'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message == 'Field \'address\' is not found in the schema')));
    });

    test('should fail for validateAsync when rule fail', () async {
      expect(await groupValidator.using('age').validateAsync('text'),
          equals('example message'));
    });

    test('should pass for extend', () {
      final group = GroupValidator({
        'name': StringValidator().minLength(5),
      }).extend<StringValidator>(
          'name', (validator) => validator.maxLength(10));

      final result = group.using('name').validate('Asepe');

      expect(result, isNull);
    });

    test('should fail for extend when no key found', () {
      expect(
          () => groupValidator.extend<StringValidator>(
              'address', (validator) => validator.maxLength(10)),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message == 'Field \'address\' is not found in the schema')));
    });

    test('should fail for extend when rule fail', () {
      final group = GroupValidator({
        'name': StringValidator().minLength(5),
      }).extend<StringValidator>(
          'name', (validator) => validator.maxLength(10));

      final result = group.using('name').validate('Asep Surasep');

      expect(result, "name must not be longer than 10 characters");
    });

    test('fromMap validation non-async', () {
      final group = GroupValidator({
        'name': StringValidator().minLength(5),
        'address': StringValidator().minLength(5),
      });

      final result = group.validateMap({
        'name': 'Asep',
        'address': 'Jl. Jalan',
      });

      expect(result, {'name': "name must contains at least 5 characters"});
    });

    test('fromMap validation async', () async {
      final group = GroupValidator({
        'name': StringValidator().minLength(5),
        'address': StringValidator().minLength(5),
      });

      final result = await group.validateMapAsync({
        'name': 'Asep',
        'address': 'Jl. Jalan',
      });

      expect(result, {'name': "name must contains at least 5 characters"});
    });

    test('GroupValidatorUsing', () {
      final validator = GroupValidatorUsing(mockValidatorName, 'name');

      expect(validator.path, "name");
      expect(validator.validator, isA<MockValidator<String>>());

      validator.validate('Asep Surasep');
      verify(mockValidatorName.parse('Asep Surasep', path: 'name')).called(1);

      validator.validateAsync('Asep Surasep');
      verify(mockValidatorName.parseAsync('Asep Surasep', path: 'name'))
          .called(1);
    });
  });
}

import 'dart:io';

import 'package:test/test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

import '../lib/example.dart';

void main() {
  group('User validation', () {
    test('should pass for valid user', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
      expect(result.data, same(user));
    });

    test('should fail for too short email', () async {
      final user = User(
        email: 'ab',
        username: 'validuser',
        confirmEmail: 'ab',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(
          result.errors
              .any((e) => e.rule == 'MinLength' && e.path!.last == 'email'),
          isTrue);
    });

    test('should fail for too long email', () async {
      final longEmail = 'a' * 101;
      final user = User(
        email: longEmail,
        username: 'validuser',
        confirmEmail: longEmail,
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(
          result.errors
              .any((e) => e.rule == 'MaxLength' && e.path!.last == 'email'),
          isTrue);
    });

    test('should fail for empty tags', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: [],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['tags']));
      expect(result.errors.first.message,
          equals('List must have at least 1 items'));
    });

    test('should pass for non-empty tags', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['a', 'b'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });
  });

  group('Nested validation', () {
    test('should fail when nested car has invalid make', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'T', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['car', 'make']));
    });

    test('should fail when nested car has invalid model', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'C'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['car', 'model']));
    });

    test('should fail when nested car has multiple invalid fields', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'T', model: 'C'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(
          paths,
          containsAll([
            ['car', 'make'],
            ['car', 'model']
          ]));
    });

    test('should pass when nullable spareCar is null', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        spareCar: null,
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });

    test('should fail when nullable spareCar has invalid fields', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        spareCar: Car(make: 'T', model: 'C'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(
          paths,
          containsAll([
            ['spareCar', 'make'],
            ['spareCar', 'model']
          ]));
    });

    test('should pass when previousCars is empty', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });

    test('should pass when all previousCars are valid', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'Honda', model: 'Civic'),
          Car(make: 'Ford', model: 'Focus'),
        ],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });

    test('should fail when first previousCar has invalid make', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
          Car(make: 'Ford', model: 'Focus'),
        ],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['previousCars[0]', 'make']));
    });

    test('should fail when second previousCar has invalid model', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'Honda', model: 'Civic'),
          Car(make: 'Ford', model: 'F'),
        ],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['previousCars[1]', 'model']));
    });

    test('should fail when multiple previousCars have invalid fields',
        () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
          Car(make: 'Ford', model: 'F'),
        ],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(
          paths,
          containsAll([
            ['previousCars[0]', 'make'],
            ['previousCars[1]', 'model'],
          ]));
    });
  });

  group('Combined validation', () {
    test('should collect errors from multiple levels', () async {
      final user = User(
        email: 'ab',
        username: 'validuser',
        confirmEmail: 'ab',
        tags: [],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'T', model: 'Camry'),
        spareCar: Car(make: 'Toyota', model: 'C'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
        ],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(6));
      final paths = result.errors.map((e) => e.path).toList();
      expect(
          paths,
          containsAll([
            ['email'],
            ['tags'],
            ['car', 'make'],
            ['spareCar', 'model'],
            ['previousCars[0]', 'make'],
            ['confirmEmail'],
          ]));
    });
  });

  group('Per-field validation', () {
    test('standalone field validate succeeds for valid email', () {
      final r = UserFields.email.validate('test@example.com');
      expect(r.isValid, isTrue);
      expect(r.data, equals('test@example.com'));
    });

    test('standalone field validate reports MinLength', () {
      final r = UserFields.email.validate('ab');
      expect(r.isValid, isFalse);
      expect(r.errors, hasLength(1));
      expect(r.errors.first.rule, equals('MinLength'));
      expect(r.errors.first.path, equals(['email']));
    });

    test('standalone field validate reports MaxLength', () {
      final r = UserFields.email.validate('a' * 101);
      expect(r.isValid, isFalse);
      expect(r.errors.first.rule, equals('MaxLength'));
    });

    test('standalone field validate fails on null (required by type)', () {
      final r = UserFields.email.validate(null);
      expect(r.isValid, isFalse);
      expect(r.errors.single.rule, equals('Required'));
    });

    test('instance-driven validateField extracts and validates', () {
      final user = User(
        email: 'ab',
        username: 'validuser',
        confirmEmail: 'valid@example.com',
        tags: ['x'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: const [],
      );
      final r = user.validateField(UserFields.email);
      expect(r.isValid, isFalse);
      expect(r.errors.first.path, equals(['email']));
    });

    test('instance-driven validateField type is inferred', () async {
      final user = User(
        email: 'ok@ok.com',
        username: 'okuser',
        confirmEmail: 'ok@ok.com',
        tags: ['x'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: const [],
      );
      final ValidasiResult<String> r =
          await user.validateFieldAsync(UserFields.email);
      expect(r.isValid, isTrue);
      expect(r.data, equals('ok@ok.com'));
    });

    test('nested key validates whole sub-object and prefixes paths', () async {
      final user = User(
        email: 'ok@ok.com',
        username: 'okuser',
        confirmEmail: 'ok@ok.com',
        tags: ['x'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'T', model: 'M'),
        previousCars: const [],
      );
      final r = await user.validateFieldAsync(UserFields.car);
      expect(r.isValid, isFalse);
      expect(
          r.errors.map((e) => e.path),
          containsAll(<List<String>>[
            ['car', 'make']
          ]));
    });

    test('nullable nested key passes when value is null', () {
      final r = UserFields.spareCar.validate(null);
      expect(r.isValid, isTrue);
    });

    test('nullable nested key validates non-null value and prefixes', () async {
      final r =
          await UserFields.spareCar.validateAsync(Car(make: 'T', model: 'M'));
      expect(r.isValid, isFalse);
      expect(
          r.errors.map((e) => e.path),
          containsAll(<List<String>>[
            ['spareCar', 'make']
          ]));
    });

    test('iterable nested key prefixes with index', () async {
      final user = User(
        email: 'ok@ok.com',
        username: 'okuser',
        confirmEmail: 'ok@ok.com',
        tags: ['x'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [Car(make: 'H', model: 'Civic')],
      );
      final r = await user.validateFieldAsync(UserFields.previousCars);
      expect(r.isValid, isFalse);
      expect(r.errors.single.path, equals(['previousCars[0]', 'make']));
    });

    test('iterable nested key fails when value is null (required by type)', () {
      final r = UserFields.previousCars.validate(null);
      expect(r.isValid, isFalse);
      expect(r.errors.single.rule, equals('Required'));
    });

    test('sealed switch is exhaustive over UserFields', () {
      String label(UserFields f) => switch (f) {
            UserEmailField() => 'email',
            UserUsernameField() => 'username',
            UserConfirmEmailField() => 'confirmEmail',
            UserTagsField() => 'tags',
            UserWorkEmailField() => 'workEmail',
            UserAgeField() => 'age',
            UserCarField() => 'car',
            UserSpareCarField() => 'spareCar',
            UserPreviousCarsField() => 'previousCars',
            UserCustomDataField() => 'customData',
          };
      expect(label(UserFields.email), 'email');
      expect(label(UserFields.username), 'username');
      expect(label(UserFields.confirmEmail), 'confirmEmail');
      expect(label(UserFields.tags), 'tags');
      expect(label(UserFields.workEmail), 'workEmail');
      expect(label(UserFields.age), 'age');
      expect(label(UserFields.car), 'car');
      expect(label(UserFields.spareCar), 'spareCar');
      expect(label(UserFields.previousCars), 'previousCars');
    });

    test('generic ValidasiKey<T> infers owner type', () {
      final ValidasiKey<User> key = UserFields.email;
      expect(key, isA<UserFields>());
    });

    test('generic ValidasiKey<T> infers owner for different class', () {
      final ValidasiKey<Car> key = CarFields.make;
      expect(key, isA<CarFields>());
    });
  });

  group('Async validation', () {
    test('validateAsync passes for valid user', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });

    test('validateAsync fails when username is taken', () async {
      final user = User(
        email: 'test@example.com',
        username: 'taken',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.rule == 'async_inline'), isTrue);
      expect(
        result.errors.firstWhere((e) => e.rule == 'async_inline').path,
        equals(['username']),
      );
    });

    test('validate() throws when async rules exist', () {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      expect(() => user.validate(), throwsStateError);
    });

    test('validateFieldAsync delegates to leaf validateAsync', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateFieldAsync(UserFields.username);
      expect(result.isValid, isTrue);
    });
  });

  group('generateFields option', () {
    test('opt-out still produces a working validate()', () {
      final r = InternalFoo(code: 'x').validate();
      expect(r.isValid, isTrue);
    });

    test('opt-out still produces errors when validation fails', () {
      final r = InternalFoo(code: '').validate();
      expect(r.isValid, isFalse);
      expect(r.errors.single.rule, equals('MinLength'));
      expect(r.errors.single.path, equals(['code']));
    });

    test('opt-out suppresses XFields from generated source', () {
      final generated = File('lib/example.validasi.dart').readAsStringSync();
      expect(generated, isNot(contains('class InternalFooFields')));
      expect(generated, isNot(contains('InternalFooFields<')));
      expect(generated, isNot(contains('validateField<InternalFooFields')));
    });

    test('opt-out extension has no validateField method', () {
      final foo = InternalFoo(code: 'x');
      expect(
        () => (foo as dynamic).validateField as Function,
        throwsNoSuchMethodError,
      );
    });
  });

  group('@Refine class-level cross-field validation', () {
    test('passes when email and confirmEmail match', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'test@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isTrue);
    });

    test('fails when email and confirmEmail mismatch', () async {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        confirmEmail: 'other@example.com',
        tags: ['dart'],
        workEmail: 'user@example.com',
        age: 30,
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = await user.validateAsync();
      expect(result.isValid, isFalse);
      final refineErrors =
          result.errors.where((e) => e.rule == 'Refine').toList();
      expect(refineErrors, hasLength(1));
      expect(refineErrors.first.message, equals('Emails do not match'));
      expect(refineErrors.first.path, equals(['confirmEmail']));
    });
  });
}

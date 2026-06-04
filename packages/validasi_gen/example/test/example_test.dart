import 'package:test/test.dart';

import '../lib/example.dart';

void main() {
  group('User validation', () {
    test('should pass for valid user', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isTrue);
      expect(result.data, same(user));
    });

    test('should fail for too short email', () {
      final user = User(
        email: 'ab',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['email']));
    });

    test('should fail for too long email', () {
      final longEmail = 'a' * 101;
      final user = User(
        email: longEmail,
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MaxLength'));
    });

    test('should fail for empty tags', () {
      final user = User(
        email: 'test@example.com',
        tags: [],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['tags']));
      expect(result.errors.first.message,
          equals('List must have at least 1 items'));
    });

    test('should pass for non-empty tags', () {
      final user = User(
        email: 'test@example.com',
        tags: ['a', 'b'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isTrue);
    });
  });

  group('Nested validation', () {
    test('should fail when nested car has invalid make', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'T', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['car', 'make']));
    });

    test('should fail when nested car has invalid model', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'C'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['car', 'model']));
    });

    test('should fail when nested car has multiple invalid fields', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'T', model: 'C'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(paths, containsAll([['car', 'make'], ['car', 'model']]));
    });

    test('should pass when nullable spareCar is null', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        spareCar: null,
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isTrue);
    });

    test('should fail when nullable spareCar has invalid fields', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        spareCar: Car(make: 'T', model: 'C'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(paths, containsAll([['spareCar', 'make'], ['spareCar', 'model']]));
    });

    test('should pass when previousCars is empty', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [],
      );
      final result = user.validate();
      expect(result.isValid, isTrue);
    });

    test('should pass when all previousCars are valid', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'Honda', model: 'Civic'),
          Car(make: 'Ford', model: 'Focus'),
        ],
      );
      final result = user.validate();
      expect(result.isValid, isTrue);
    });

    test('should fail when first previousCar has invalid make', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
          Car(make: 'Ford', model: 'Focus'),
        ],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['previousCars[0]', 'make']));
    });

    test('should fail when second previousCar has invalid model', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'Honda', model: 'Civic'),
          Car(make: 'Ford', model: 'F'),
        ],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['previousCars[1]', 'model']));
    });

    test('should fail when multiple previousCars have invalid fields', () {
      final user = User(
        email: 'test@example.com',
        tags: ['dart'],
        car: Car(make: 'Toyota', model: 'Camry'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
          Car(make: 'Ford', model: 'F'),
        ],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      final paths = result.errors.map((e) => e.path).toList();
      expect(paths, containsAll([
        ['previousCars[0]', 'make'],
        ['previousCars[1]', 'model'],
      ]));
    });
  });

  group('Combined validation', () {
    test('should collect errors from multiple levels', () {
      final user = User(
        email: 'ab',
        tags: [],
        car: Car(make: 'T', model: 'Camry'),
        spareCar: Car(make: 'Toyota', model: 'C'),
        previousCars: [
          Car(make: 'H', model: 'Civic'),
        ],
      );
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(5));
      final paths = result.errors.map((e) => e.path).toList();
      expect(paths, containsAll([
        ['email'],
        ['tags'],
        ['car', 'make'],
        ['spareCar', 'model'],
        ['previousCars[0]', 'make'],
      ]));
    });
  });
}

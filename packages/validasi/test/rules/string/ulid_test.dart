import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/ulid.dart';

void main() {
  group('Ulid (String)', () {
    test('should pass with valid ULID', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('01ARZ3NDEKTSV4RRFFQ69G5FAV', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with lowercase ULID', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('01arz3ndektsv4rrffq69g5fav', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with mixed case ULID', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('01ArZ3nDeKtSv4rRfFq69G5fAv', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with invalid characters (I, L, O, U)', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('01ARZ3NDEKTSV4RRFFQ69G5FAI', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Ulid'));
      expect(state.errors.first.message, equals('Must be a valid ULID'));
    });

    test('should fail with wrong length', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('01ARZ3NDEKTSV4RRFFQ69G5FA', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with first char > 7', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('81ARZ3NDEKTSV4RRFFQ69G5FAV', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Ulid(message: 'Invalid ULID!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid ULID!'));
    });

    test('should pass with all zeros', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('00000000000000000000000000', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with max valid first char', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply('7ZZZZZZZZZZZZZZZZZZZZZZZZZ', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Ulid();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}

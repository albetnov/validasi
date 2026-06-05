import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/uuid.dart';

void main() {
  group('Uuid (String)', () {
    test('should pass with valid UUID v4', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply('550e8400-e29b-41d4-a716-446655440000', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with valid UUID v7', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply('01932c7e-8c40-7000-8000-000000000000', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with uppercase UUID', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply('550E8400-E29B-41D4-A716-446655440000', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with invalid format', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply('not-a-uuid', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Uuid'));
      expect(state.errors.first.message, equals('Must be a valid UUID'));
    });

    test('should fail with wrong variant', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply('550e8400-e29b-41d4-c716-446655440000', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with wrong version when restricted', () {
      final rule = Uuid(versions: [4]);
      final state = ValidationState();

      rule.apply('01932c7e-8c40-7000-8000-000000000000', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Must be UUID v4'));
    });

    test('should pass with v1 when allowed', () {
      final rule = Uuid(versions: [1, 4]);
      final state = ValidationState();

      rule.apply('550e8400-e29b-11d4-a716-446655440000', state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = Uuid(message: 'Invalid UUID!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid UUID!'));
    });

    test('should include versions in details', () {
      final rule = Uuid(versions: [4, 7]);
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.details?['versions'], equals('4, 7'));
    });

    test('should skip null values', () {
      final rule = Uuid();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}

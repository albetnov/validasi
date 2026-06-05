import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/equals.dart';

void main() {
  group('Equals', () {
    test('should pass when value equals expected', () {
      final rule = Equals<int>(42);
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value does not equal expected', () {
      final rule = Equals<int>(42);
      final state = ValidationState();

      rule.apply(43, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Equals'));
      expect(state.errors.first.message, equals('Value must equal 42'));
    });

    test('should use custom message', () {
      final rule = Equals<int>(42, message: 'Must be 42');
      final state = ValidationState();

      rule.apply(43, state);

      expect(state.errors.first.message, equals('Must be 42'));
    });

    test('should work with strings', () {
      final rule = Equals<String>('active');
      final state = ValidationState();

      rule.apply('active', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with different strings', () {
      final rule = Equals<String>('active');
      final state = ValidationState();

      rule.apply('inactive', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with custom equals', () {
      final rule = Equals<Map<String, dynamic>>(
        {'id': 1},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply({'id': 1, 'name': 'test'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals when not matching', () {
      final rule = Equals<Map<String, dynamic>>(
        {'id': 1},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply({'id': 2}, state);

      expect(state.errors.length, equals(1));
    });

    test('should skip null values', () {
      final rule = Equals<int>(42);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should work with booleans', () {
      final rule = Equals<bool>(true);
      final state = ValidationState();

      rule.apply(true, state);

      expect(state.errors, isEmpty);
    });
  });
}

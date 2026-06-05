import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/not_equals.dart';

void main() {
  group('NotEquals', () {
    test('should pass when value does not equal unexpected', () {
      final rule = NotEquals<int>(0);
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value equals unexpected', () {
      final rule = NotEquals<int>(0);
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('NotEquals'));
      expect(state.errors.first.message, equals('Value must not equal 0'));
    });

    test('should use custom message', () {
      final rule = NotEquals<int>(0, message: 'Cannot be zero');
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors.first.message, equals('Cannot be zero'));
    });

    test('should work with strings', () {
      final rule = NotEquals<String>('banned');
      final state = ValidationState();

      rule.apply('active', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with matching strings', () {
      final rule = NotEquals<String>('banned');
      final state = ValidationState();

      rule.apply('banned', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with custom equals', () {
      final rule = NotEquals<Map<String, dynamic>>(
        {'id': 1},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply({'id': 2, 'name': 'test'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals when matching', () {
      final rule = NotEquals<Map<String, dynamic>>(
        {'id': 1},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply({'id': 1}, state);

      expect(state.errors.length, equals(1));
    });

    test('should skip null values', () {
      final rule = NotEquals<int>(0);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should work with booleans', () {
      final rule = NotEquals<bool>(false);
      final state = ValidationState();

      rule.apply(true, state);

      expect(state.errors, isEmpty);
    });
  });
}

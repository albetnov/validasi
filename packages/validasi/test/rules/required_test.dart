import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/required.dart';

void main() {
  group('Required', () {
    test('should have runOnNull set to true', () {
      final rule = Required<String>();

      expect(rule.runOnNull, isTrue);
    });

    test('should pass for non-null value', () {
      final rule = Required<String>();
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should fail for null value', () {
      final rule = Required<String>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Required'));
      expect(state.errors.first.message, equals('Field is required'));
    });

    test('should use custom message', () {
      final rule = Required<String>(message: 'Custom required message');
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Custom required message'));
    });

    test('should work with different types', () {
      final rule = Required<int>();
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for null with any type', () {
      final rule = Required<List<int>>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass for empty string', () {
      final rule = Required<String>();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should pass for empty list', () {
      final rule = Required<List<int>>();
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero number', () {
      final rule = Required<int>();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for false boolean', () {
      final rule = Required<bool>();
      final state = ValidationState();

      rule.apply(false, state);

      expect(state.errors, isEmpty);
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/nullable.dart';

void main() {
  group('Nullable', () {
    test('should have runOnNull set to true', () {
      final rule = Nullable<String>();

      expect(rule.runOnNull, isTrue);
    });

    test('should stop context when value is null', () {
      final rule = Nullable<String>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.isStopped, isTrue);
      expect(state.errors, isEmpty);
    });

    test('should not stop context when value is non-null', () {
      final rule = Nullable<String>();
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.isStopped, isFalse);
      expect(state.errors, isEmpty);
    });

    test('should not add errors for null value', () {
      final rule = Nullable<String>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should not add errors for non-null value', () {
      final rule = Nullable<String>();
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should work with different types', () {
      final rule = Nullable<int>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.isStopped, isTrue);
    });

    test('should work with complex types', () {
      final rule = Nullable<List<int>>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.isStopped, isTrue);
    });

    test('should not stop for empty string', () {
      final rule = Nullable<String>();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.isStopped, isFalse);
    });

    test('should not stop for empty list', () {
      final rule = Nullable<List<int>>();
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.isStopped, isFalse);
    });

    test('should not stop for zero', () {
      final rule = Nullable<int>();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.isStopped, isFalse);
    });

    test('should not stop for false', () {
      final rule = Nullable<bool>();
      final state = ValidationState();

      rule.apply(false, state);

      expect(state.isStopped, isFalse);
    });
  });
}

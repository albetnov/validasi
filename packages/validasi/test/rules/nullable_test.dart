import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/nullable.dart';

void main() {
  group('Nullable', () {
    test('should have runOnNull set to true', () {
      final rule = Nullable<String>();

      expect(rule.runOnNull, isTrue);
    });

    test('should stop context when value is null', () {
      final rule = Nullable<String>();
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.isStopped, isTrue);
      expect(context.errors, isEmpty);
    });

    test('should not stop context when value is non-null', () {
      final rule = Nullable<String>();
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.isStopped, isFalse);
      expect(context.errors, isEmpty);
    });

    test('should not add errors for null value', () {
      final rule = Nullable<String>();
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should not add errors for non-null value', () {
      final rule = Nullable<String>();
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with different types', () {
      final intRule = Nullable<int>();
      final intContext = ValidationContext<int>(value: null);

      intRule.apply(intContext);

      expect(intContext.isStopped, isTrue);
    });

    test('should work with complex types', () {
      final listRule = Nullable<List<int>>();
      final listContext = ValidationContext<List<int>>(value: null);

      listRule.apply(listContext);

      expect(listContext.isStopped, isTrue);
    });

    test('should not stop for empty string', () {
      final rule = Nullable<String>();
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.isStopped, isFalse);
    });

    test('should not stop for empty list', () {
      final rule = Nullable<List<int>>();
      final context = ValidationContext<List<int>>(value: []);

      rule.apply(context);

      expect(context.isStopped, isFalse);
    });

    test('should not stop for zero', () {
      final rule = Nullable<int>();
      final context = ValidationContext<int>(value: 0);

      rule.apply(context);

      expect(context.isStopped, isFalse);
    });

    test('should not stop for false', () {
      final rule = Nullable<bool>();
      final context = ValidationContext<bool>(value: false);

      rule.apply(context);

      expect(context.isStopped, isFalse);
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/required.dart';

void main() {
  group('Required', () {
    test('should have runOnNull set to true', () {
      final rule = Required<String>();

      expect(rule.runOnNull, isTrue);
    });

    test('should pass for non-null value', () {
      final rule = Required<String>();
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail for null value', () {
      final rule = Required<String>();
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('Required'));
      expect(context.errors.first.message, equals('Field is required'));
    });

    test('should use custom message', () {
      final rule = Required<String>(message: 'Custom required message');
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.message, equals('Custom required message'));
    });

    test('should work with different types', () {
      final intRule = Required<int>();
      final intContext = ValidationContext<int>(value: 42);

      intRule.apply(intContext);

      expect(intContext.errors, isEmpty);
    });

    test('should fail for null with any type', () {
      final listRule = Required<List<int>>();
      final listContext = ValidationContext<List<int>>(value: null);

      listRule.apply(listContext);

      expect(listContext.errors.length, equals(1));
    });

    test('should pass for empty string', () {
      final rule = Required<String>();
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for empty list', () {
      final rule = Required<List<int>>();
      final context = ValidationContext<List<int>>(value: []);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for zero number', () {
      final rule = Required<int>();
      final context = ValidationContext<int>(value: 0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for false boolean', () {
      final rule = Required<bool>();
      final context = ValidationContext<bool>(value: false);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/string/min_length.dart';

void main() {
  group('MinLength (String)', () {
    test('should pass when string length equals minimum', () {
      final rule = MinLength(5);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass when string length exceeds minimum', () {
      final rule = MinLength(3);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when string length is below minimum', () {
      final rule = MinLength(10);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('MinLength'));
      expect(
        context.errors.first.message,
        equals('Minimum length is 10 characters'),
      );
    });

    test('should use custom message', () {
      final rule = MinLength(10, message: 'Too short!');
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.first.message, equals('Too short!'));
    });

    test('should include length in details', () {
      final rule = MinLength(10);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.first.details?['length'], equals('10'));
    });

    test('should work with empty string', () {
      final rule = MinLength(1);
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with zero minimum', () {
      final rule = MinLength(0);
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with long strings', () {
      final rule = MinLength(100);
      final longString = 'a' * 150;
      final context = ValidationContext<String>(value: longString);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with unicode characters', () {
      final rule = MinLength(5);
      final context = ValidationContext<String>(value: '👋🌍🎉💻🚀');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with whitespace', () {
      final rule = MinLength(5);
      final context = ValidationContext<String>(value: '     ');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

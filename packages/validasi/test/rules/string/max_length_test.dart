import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/rules/string/max_length.dart';

void main() {
  group('MaxLength (String)', () {
    test('should pass when string length equals maximum', () {
      final rule = MaxLength(5);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass when string length is below maximum', () {
      final rule = MaxLength(10);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when string length exceeds maximum', () {
      final rule = MaxLength(3);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('MaxLength'));
      expect(
        context.errors.first.message,
        equals('Maximum length is 3 characters'),
      );
    });

    test('should use custom message', () {
      final rule = MaxLength(3, message: 'Too long!');
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.first.message, equals('Too long!'));
    });

    test('should include length in details', () {
      final rule = MaxLength(3);
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.errors.first.details?['length'], equals('3'));
    });

    test('should work with empty string', () {
      final rule = MaxLength(0);
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail for non-empty string with zero max', () {
      final rule = MaxLength(0);
      final context = ValidationContext<String>(value: 'a');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with long strings', () {
      final rule = MaxLength(50);
      final longString = 'a' * 100;
      final context = ValidationContext<String>(value: longString);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with unicode characters', () {
      final rule = MaxLength(3);
      final context = ValidationContext<String>(value: '👋🌍🎉💻');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with whitespace', () {
      final rule = MaxLength(3);
      final context = ValidationContext<String>(value: '     ');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should allow max length boundary', () {
      final rule = MaxLength(5);
      final context = ValidationContext<String>(value: '12345');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

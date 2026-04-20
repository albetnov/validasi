import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/rules/map/conditional_field.dart';

void main() {
  group('ConditionalFieldContext', () {
    test('get should return value for existing key', () {
      final map = {'name': 'John', 'age': 30};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.get<String>('name'), equals('John'));
      expect(ctx.get<int>('age'), equals(30));
    });

    test('get should return null for non-existent key', () {
      final map = {'name': 'John'};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.get<String>('age'), isNull);
    });

    test('has should return true for existing key', () {
      final map = {'name': 'John'};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.has('name'), isTrue);
    });

    test('has should return false for non-existent key', () {
      final map = {'name': 'John'};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.has('age'), isFalse);
    });

    test('check should return true when key exists with correct type', () {
      final map = {'name': 'John', 'age': 30};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.check<String>('name'), isTrue);
      expect(ctx.check<int>('age'), isTrue);
    });

    test('check should return false when key exists with wrong type', () {
      final map = {'name': 'John', 'age': 30};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.check<int>('name'), isFalse);
      expect(ctx.check<String>('age'), isFalse);
    });

    test('check should return false when key does not exist', () {
      final map = {'name': 'John'};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.check<String>('age'), isFalse);
    });

    test('isEmpty should return true for empty map', () {
      final map = <String, dynamic>{};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.isEmpty(), isTrue);
    });

    test('isEmpty should return false for non-empty map', () {
      final map = {'name': 'John'};
      final ctx = ConditionalFieldContext<dynamic>(map);

      expect(ctx.isEmpty(), isFalse);
    });
  });

  group('ConditionalField', () {
    test('should pass when callback returns null', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) => null,
      );
      final context = ValidationContext<Map<String, int>>(
        value: {'age': 30},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when callback returns error message', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) => 'Too young',
      );
      final context = ValidationContext<Map<String, int>>(
        value: {'age': 15},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('conditionalField'));
      expect(context.errors.first.message, equals('Too young'));
    });

    test('should provide field value to callback', () {
      int? receivedValue;
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) {
          receivedValue = value;
          return null;
        },
      );
      final context = ValidationContext<Map<String, int>>(
        value: {'age': 30},
      );

      rule.apply(context);

      expect(receivedValue, equals(30));
    });

    test('should provide context to callback', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) {
          if (ctx.has('verified') && value! < 18) {
            return 'Must be 18 or older when verified';
          }
          return null;
        },
      );

      final validContext = ValidationContext<Map<String, int>>(
        value: {'age': 20, 'verified': 1},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<Map<String, int>>(
        value: {'age': 15, 'verified': 1},
      );
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with missing field', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) => value == null ? 'Age is required' : null,
      );
      final context = ValidationContext<Map<String, int>>(
        value: {'other': 0},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.message, equals('Age is required'));
    });

    test('should work with complex validation logic', () {
      final rule = ConditionalField<dynamic>(
        'email',
        (ctx, value) {
          if (ctx.get('requireEmail') == true && value == null) {
            return 'Email is required';
          }
          if (value != null && value is String && !value.contains('@')) {
            return 'Invalid email format';
          }
          return null;
        },
      );

      final validContext1 = ValidationContext<Map<String, dynamic>>(
        value: {'requireEmail': false},
      );
      rule.apply(validContext1);
      expect(validContext1.errors, isEmpty);

      final validContext2 = ValidationContext<Map<String, dynamic>>(
        value: {'requireEmail': true, 'email': 'test@example.com'},
      );
      rule.apply(validContext2);
      expect(validContext2.errors, isEmpty);

      final invalidContext1 = ValidationContext<Map<String, dynamic>>(
        value: {'requireEmail': true},
      );
      rule.apply(invalidContext1);
      expect(invalidContext1.errors.length, equals(1));

      final invalidContext2 = ValidationContext<Map<String, dynamic>>(
        value: {'requireEmail': true, 'email': 'invalid'},
      );
      rule.apply(invalidContext2);
      expect(invalidContext2.errors.length, equals(1));
    });

    test('should work with type checking in callback', () {
      final rule = ConditionalField<dynamic>(
        'value',
        (ctx, value) {
          if (ctx.check<int>('value')) {
            return value < 0 ? 'Must be positive' : null;
          }
          return 'Must be an integer';
        },
      );

      final validContext = ValidationContext<Map<String, dynamic>>(
        value: {'value': 10},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext1 = ValidationContext<Map<String, dynamic>>(
        value: {'value': -5},
      );
      rule.apply(invalidContext1);
      expect(invalidContext1.errors.length, equals(1));
      expect(invalidContext1.errors.first.message, equals('Must be positive'));

      final invalidContext2 = ValidationContext<Map<String, dynamic>>(
        value: {'value': 'string'},
      );
      rule.apply(invalidContext2);
      expect(invalidContext2.errors.length, equals(1));
      expect(
          invalidContext2.errors.first.message, equals('Must be an integer'));
    });

    test('should work with dependent fields', () {
      final rule = ConditionalField<int>(
        'maxValue',
        (ctx, maxValue) {
          final minValue = ctx.get<int>('minValue');
          if (maxValue != null && minValue != null && maxValue < minValue) {
            return 'Max must be greater than min';
          }
          return null;
        },
      );

      final validContext = ValidationContext<Map<String, int>>(
        value: {'minValue': 10, 'maxValue': 20},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<Map<String, int>>(
        value: {'minValue': 20, 'maxValue': 10},
      );
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with isEmpty check', () {
      final rule = ConditionalField<String>(
        'name',
        (ctx, value) {
          if (ctx.isEmpty()) {
            return 'At least one field is required';
          }
          return null;
        },
      );

      final validContext = ValidationContext<Map<String, String>>(
        value: {'name': 'John'},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<Map<String, String>>(
        value: {},
      );
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });
  });
}

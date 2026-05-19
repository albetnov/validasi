import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
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
      final state = ValidationState();

      rule.apply({'age': 30}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when callback returns error message', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) => 'Too young',
      );
      final state = ValidationState();

      rule.apply({'age': 15}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('conditionalField'));
      expect(state.errors.first.message, equals('Too young'));
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
      final state = ValidationState();

      rule.apply({'age': 30}, state);

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

      var state = ValidationState();
      rule.apply({'age': 20, 'verified': 1}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply({'age': 15, 'verified': 1}, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with missing field', () {
      final rule = ConditionalField<int>(
        'age',
        (ctx, value) => value == null ? 'Age is required' : null,
      );
      final state = ValidationState();

      rule.apply({'other': 0}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Age is required'));
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

      var state = ValidationState();
      rule.apply({'requireEmail': false}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply({'requireEmail': true, 'email': 'test@example.com'}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply({'requireEmail': true}, state);
      expect(state.errors.length, equals(1));

      state = ValidationState();
      rule.apply({'requireEmail': true, 'email': 'invalid'}, state);
      expect(state.errors.length, equals(1));
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

      var state = ValidationState();
      rule.apply({'value': 10}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply({'value': -5}, state);
      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Must be positive'));

      state = ValidationState();
      rule.apply({'value': 'string'}, state);
      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Must be an integer'));
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

      var state = ValidationState();
      rule.apply({'minValue': 10, 'maxValue': 20}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply({'minValue': 20, 'maxValue': 10}, state);
      expect(state.errors.length, equals(1));
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

      var state = ValidationState();
      rule.apply({'name': 'John'}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(<String, String>{}, state);
      expect(state.errors.length, equals(1));
    });
  });
}

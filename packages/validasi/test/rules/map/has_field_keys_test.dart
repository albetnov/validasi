import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/rules/map/has_field_keys.dart';

void main() {
  group('HasFieldKeys', () {
    test('should pass when all keys are present', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c'});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2, 'c': 3},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass when extra keys are present', () {
      final rule = HasFieldKeys<int>({'a', 'b'});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2, 'c': 3, 'd': 4},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when a key is missing', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c'});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('hasFieldKeys'));
      expect(context.errors.first.message, contains('Missing required fields'));
      expect(context.errors.first.message, contains('c'));
    });

    test('should fail with multiple missing keys', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c', 'd'});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.message, contains('c'));
      expect(context.errors.first.message, contains('d'));
    });

    test('should work with empty key set', () {
      final rule = HasFieldKeys<int>({});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with empty map', () {
      final rule = HasFieldKeys<int>({'a'});
      final context = ValidationContext<Map<String, int>>(value: {});

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with different value types', () {
      final stringRule = HasFieldKeys<String>({'name', 'email'});
      final stringContext = ValidationContext<Map<String, String>>(
        value: {'name': 'John', 'email': 'john@example.com'},
      );

      stringRule.apply(stringContext);

      expect(stringContext.errors, isEmpty);
    });

    test('should work with nullable values', () {
      final rule = HasFieldKeys<int?>({'a', 'b'});
      final context = ValidationContext<Map<String, int?>>(
        value: {'a': null, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should be case sensitive', () {
      final rule = HasFieldKeys<int>({'Name'});
      final context = ValidationContext<Map<String, int>>(
        value: {'name': 1},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with single required key', () {
      final rule = HasFieldKeys<int>({'id'});

      final validContext = ValidationContext<Map<String, int>>(
        value: {'id': 1, 'other': 2},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<Map<String, int>>(
        value: {'other': 2},
      );
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with many required keys', () {
      final keys = Set<String>.from(List.generate(50, (i) => 'key$i'));
      final rule = HasFieldKeys<int>(keys);
      final map = <String, int>{};
      for (var i = 0; i < 50; i++) {
        map['key$i'] = 1;
      }
      final context = ValidationContext<Map<String, int>>(value: map);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should handle special characters in keys', () {
      final rule = HasFieldKeys<int>({'key-1', 'key_2', 'key.3'});
      final context = ValidationContext<Map<String, int>>(
        value: {'key-1': 1, 'key_2': 2, 'key.3': 3},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

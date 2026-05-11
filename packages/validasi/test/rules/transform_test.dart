import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/transform.dart';

void main() {
  group('Transform', () {
    test('should have runOnNull set to true', () {
      final rule = Transform<String>((value) => value);

      expect(rule.runOnNull, isTrue);
    });

    test('should transform value', () {
      final rule = Transform<String>((value) => value?.toUpperCase());
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.value, equals('TEST'));
      expect(context.errors, isEmpty);
    });

    test('should not add errors', () {
      final rule = Transform<String>((value) => value?.toUpperCase());
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should handle null input', () {
      final rule = Transform<String>((value) => value ?? 'default');
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.value, equals('default'));
    });

    test('should allow transformation to null', () {
      final rule = Transform<String>((value) => null);
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.value, isNull);
    });

    test('should work with numbers', () {
      final rule = Transform<int>((value) => value != null ? value * 2 : null);
      final context = ValidationContext<int>(value: 5);

      rule.apply(context);

      expect(context.value, equals(10));
    });

    test('should work with lists', () {
      final rule = Transform<List<int>>(
        (value) => value?.map((e) => e * 2).toList(),
      );
      final context = ValidationContext<List<int>>(value: [1, 2, 3]);

      rule.apply(context);

      expect(context.value, equals([2, 4, 6]));
    });

    test('should work with maps', () {
      final rule = Transform<Map<String, int>>(
        (value) {
          if (value == null) return null;
          return value.map((key, val) => MapEntry(key.toUpperCase(), val));
        },
      );
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.value, equals({'A': 1, 'B': 2}));
    });

    test('should chain transformations', () {
      final rule1 = Transform<String>((value) => value?.toUpperCase());
      final rule2 = Transform<String>((value) => '$value!');
      final context = ValidationContext<String>(value: 'test');

      rule1.apply(context);
      rule2.apply(context);

      expect(context.value, equals('TEST!'));
    });

    test('should handle identity transformation', () {
      final rule = Transform<String>((value) => value);
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.value, equals('test'));
    });

    test('should trim strings', () {
      final rule = Transform<String>((value) => value?.trim());
      final context = ValidationContext<String>(value: '  test  ');

      rule.apply(context);

      expect(context.value, equals('test'));
    });

    test('should parse strings to numbers', () {
      final rule = Transform<dynamic>((value) {
        if (value is String) {
          return int.tryParse(value);
        }
        return value;
      });
      final context = ValidationContext<dynamic>(value: '42');

      rule.apply(context);

      expect(context.value, equals(42));
      expect(context.value, isA<int>());
    });

    test('should convert to lowercase', () {
      final rule = Transform<String>((value) => value?.toLowerCase());
      final context = ValidationContext<String>(value: 'TEST');

      rule.apply(context);

      expect(context.value, equals('test'));
    });

    test('should work with complex transformations', () {
      final rule = Transform<String>((value) {
        if (value == null) return null;
        return value.split('').reversed.join();
      });
      final context = ValidationContext<String>(value: 'hello');

      rule.apply(context);

      expect(context.value, equals('olleh'));
    });
  });
}

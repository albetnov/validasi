import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/transform.dart';

void main() {
  group('Transform', () {
    test('should have runOnNull set to true', () {
      final rule = Transform<String>((value) => value);

      expect(rule.runOnNull, isTrue);
    });

    test('should transform value', () {
      final rule = Transform<String>((value) => value?.toUpperCase());
      String? value = 'test';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals('TEST'));
      expect(state.errors, isEmpty);
    });

    test('should not add errors', () {
      final rule = Transform<String>((value) => value?.toUpperCase());
      String? value = 'test';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(state.errors, isEmpty);
    });

    test('should handle null input', () {
      final rule = Transform<String>((value) => value ?? 'default');
      final state = ValidationState();

      var value = rule.apply(null, state);

      expect(value, equals('default'));
    });

    test('should allow transformation to null', () {
      final rule = Transform<String>((value) => null);
      String? value = 'test';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, isNull);
    });

    test('should work with numbers', () {
      final rule = Transform<int>((value) => value != null ? value * 2 : null);
      int? value = 5;
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals(10));
    });

    test('should work with lists', () {
      final rule = Transform<List<int>>(
        (value) => value?.map((e) => e * 2).toList(),
      );
      List<int>? value = [1, 2, 3];
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals([2, 4, 6]));
    });

    test('should work with maps', () {
      final rule = Transform<Map<String, int>>(
        (value) {
          if (value == null) return null;
          return value.map((key, val) => MapEntry(key.toUpperCase(), val));
        },
      );
      Map<String, int>? value = {'a': 1, 'b': 2};
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals({'A': 1, 'B': 2}));
    });

    test('should chain transformations', () {
      final rule1 = Transform<String>((value) => value?.toUpperCase());
      final rule2 = Transform<String>((value) => '$value!');
      String? value = 'test';
      final state = ValidationState();

      value = rule1.apply(value, state);
      value = rule2.apply(value, state);

      expect(value, equals('TEST!'));
    });

    test('should handle identity transformation', () {
      final rule = Transform<String>((value) => value);
      String? value = 'test';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals('test'));
    });

    test('should trim strings', () {
      final rule = Transform<String>((value) => value?.trim());
      String? value = '  test  ';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals('test'));
    });

    test('should parse strings to numbers', () {
      final rule = Transform<dynamic>((value) {
        if (value is String) {
          return int.tryParse(value);
        }
        return value;
      });
      dynamic value = '42';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals(42));
      expect(value, isA<int>());
    });

    test('should convert to lowercase', () {
      final rule = Transform<String>((value) => value?.toLowerCase());
      String? value = 'TEST';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals('test'));
    });

    test('should work with complex transformations', () {
      final rule = Transform<String>((value) {
        if (value == null) return null;
        return value.split('').reversed.join();
      });
      String? value = 'hello';
      final state = ValidationState();

      value = rule.apply(value, state);

      expect(value, equals('olleh'));
    });
  });
}

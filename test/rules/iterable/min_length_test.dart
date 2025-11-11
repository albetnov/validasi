import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/rules/iterable/min_length.dart';

void main() {
  group('MinLength (List)', () {
    test('should pass when list length equals minimum', () {
      final rule = MinLength<int>(3);
      final context = ValidationContext<List<int>>(value: [1, 2, 3]);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass when list length exceeds minimum', () {
      final rule = MinLength<int>(2);
      final context = ValidationContext<List<int>>(value: [1, 2, 3, 4]);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when list length is below minimum', () {
      final rule = MinLength<int>(5);
      final context = ValidationContext<List<int>>(value: [1, 2, 3]);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('MinLength'));
      expect(
        context.errors.first.message,
        equals('List must have at least 5 items'),
      );
    });

    test('should use custom message', () {
      final rule = MinLength<int>(5, message: 'Need more items');
      final context = ValidationContext<List<int>>(value: [1, 2]);

      rule.apply(context);

      expect(context.errors.first.message, equals('Need more items'));
    });

    test('should work with empty list', () {
      final rule = MinLength<int>(1);
      final context = ValidationContext<List<int>>(value: []);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with zero minimum', () {
      final rule = MinLength<int>(0);
      final context = ValidationContext<List<int>>(value: []);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with different element types', () {
      final stringRule = MinLength<String>(2);
      final stringContext = ValidationContext<List<String>>(
        value: ['a', 'b', 'c'],
      );

      stringRule.apply(stringContext);

      expect(stringContext.errors, isEmpty);
    });

    test('should work with large lists', () {
      final rule = MinLength<int>(100);
      final largeList = List.generate(150, (i) => i);
      final context = ValidationContext<List<int>>(value: largeList);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with lists containing nulls', () {
      final rule = MinLength<int?>(3);
      final context = ValidationContext<List<int?>>(value: [1, null, 3]);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

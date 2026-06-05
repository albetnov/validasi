import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/mutually_exclusive.dart';

void main() {
  group('MutuallyExclusive', () {
    test('should pass when only first field is present', () {
      final rule = MutuallyExclusive<String>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'discount': '10%'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when only second field is present', () {
      final rule = MutuallyExclusive<String>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'memberPrice': '9.99'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when neither field is present', () {
      final rule = MutuallyExclusive<String>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'name': 'Product'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = MutuallyExclusive<String>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when both fields are present', () {
      final rule = MutuallyExclusive<String>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'discount': '10%', 'memberPrice': '9.99'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MutuallyExclusive'));
      expect(state.errors.first.message, contains('discount'));
      expect(state.errors.first.message, contains('memberPrice'));
    });

    test('should pass when both fields exist with null values', () {
      final rule = MutuallyExclusive<String?>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'discount': null, 'memberPrice': null}, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when one field exists with null value', () {
      final rule = MutuallyExclusive<String?>('discount', 'memberPrice');
      final state = ValidationState();

      rule.apply({'discount': null}, state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule =
          MutuallyExclusive<String>('a', 'b', message: 'Cannot have both');
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2'}, state);

      expect(state.errors.first.message, equals('Cannot have both'));
    });

    test('should work with different value types', () {
      final rule = MutuallyExclusive<int>('x', 'y');
      final state = ValidationState();

      rule.apply({'x': 1, 'y': 2}, state);

      expect(state.errors.length, equals(1));
    });
  });
}

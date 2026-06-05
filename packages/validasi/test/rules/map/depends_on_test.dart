import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/depends_on.dart';

void main() {
  group('DependsOn', () {
    test('should pass when both fields are present', () {
      final rule = DependsOn<String>('city', 'country');
      final state = ValidationState();

      rule.apply({'city': 'NYC', 'country': 'USA'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when dependent field is not present', () {
      final rule = DependsOn<String>('city', 'country');
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = DependsOn<String>('city', 'country');
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when dependent field is present but dependency is not',
        () {
      final rule = DependsOn<String>('city', 'country');
      final state = ValidationState();

      rule.apply({'city': 'NYC'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('DependsOn'));
      expect(state.errors.first.message, contains('city'));
      expect(state.errors.first.message, contains('country'));
    });

    test('should pass when dependency is present but dependent is not', () {
      final rule = DependsOn<String>('city', 'country');
      final state = ValidationState();

      rule.apply({'country': 'USA'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when field exists with null value and dependency exists',
        () {
      final rule = DependsOn<String?>('city', 'country');
      final state = ValidationState();

      rule.apply({'city': null, 'country': 'USA'}, state);

      expect(state.errors, isEmpty);
    });

    test(
        'should fail when field exists with null value and dependency is missing',
        () {
      final rule = DependsOn<String?>('city', 'country');
      final state = ValidationState();

      rule.apply({'city': null}, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule =
          DependsOn<String>('city', 'country', message: 'Need country');
      final state = ValidationState();

      rule.apply({'city': 'NYC'}, state);

      expect(state.errors.first.message, equals('Need country'));
    });

    test('should work with different value types', () {
      final rule = DependsOn<int>('a', 'b');
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors.length, equals(1));
    });
  });
}

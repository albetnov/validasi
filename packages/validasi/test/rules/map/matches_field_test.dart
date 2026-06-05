import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/matches_field.dart';

void main() {
  group('MatchesField', () {
    test('should pass when both fields have equal values', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply({'password': 'secret', 'passwordConfirm': 'secret'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when fields have different values', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply({'password': 'secret', 'passwordConfirm': 'different'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MatchesField'));
      expect(state.errors.first.message, contains('password'));
      expect(state.errors.first.message, contains('passwordConfirm'));
    });

    test('should pass when first field is not present', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply({'passwordConfirm': 'secret'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when second field is not present', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply({'password': 'secret'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when neither field is present', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = MatchesField<String>('password', 'passwordConfirm');
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when both fields have null values', () {
      final rule = MatchesField<String?>('a', 'b');
      final state = ValidationState();

      rule.apply({'a': null, 'b': null}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when one field is null and other is not', () {
      final rule = MatchesField<String?>('a', 'b');
      final state = ValidationState();

      rule.apply({'a': null, 'b': 'value'}, state);

      expect(state.errors.length, equals(1));
    });

    test('should work with custom equals', () {
      final rule = MatchesField<Map<String, dynamic>>(
        'a',
        'b',
        equals: (x, y) => x['id'] == y['id'],
      );
      final state = ValidationState();

      rule.apply({
        'a': {'id': 1, 'name': 'first'},
        'b': {'id': 1, 'name': 'second'},
      }, state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals when not matching', () {
      final rule = MatchesField<Map<String, dynamic>>(
        'a',
        'b',
        equals: (x, y) => x['id'] == y['id'],
      );
      final state = ValidationState();

      rule.apply({
        'a': {'id': 1},
        'b': {'id': 2},
      }, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = MatchesField<String>('a', 'b', message: 'Must match');
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2'}, state);

      expect(state.errors.first.message, equals('Must match'));
    });

    test('should work with different value types', () {
      final rule = MatchesField<int>('a', 'b');
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 1}, state);

      expect(state.errors, isEmpty);
    });
  });
}

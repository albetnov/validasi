import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/async_inline_rule.dart';

void main() {
  group('AsyncInlineRule', () {
    test('should have runOnNull set to true', () {
      final rule = AsyncInlineRule<String>((value) async => true);

      expect(rule.runOnNull, isTrue);
    });

    test('should pass when validator returns true', () async {
      final rule = AsyncInlineRule<String>(
          (value) async => value != null && value.isNotEmpty);
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when validator returns false', () async {
      final rule = AsyncInlineRule<String>((value) async => false);
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('async_inline_rule'));
      expect(state.errors.first.message, equals('Validation failed'));
    });

    test('should use custom message', () async {
      final rule = AsyncInlineRule<String>(
        (value) async => false,
        message: 'Custom validation message',
      );
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors.first.message, equals('Custom validation message'));
    });

    test('should use custom rule name', () async {
      final rule = AsyncInlineRule<String>(
        (value) async => false,
        name: 'custom_rule',
      );
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors.first.rule, equals('custom_rule'));
    });

    test('should handle null values', () async {
      final rule = AsyncInlineRule<String>((value) async => value == null);
      final state = ValidationState();

      await rule.applyAsync(null, state);

      expect(state.errors, isEmpty);
    });

    test('should catch exceptions in validator', () async {
      final rule = AsyncInlineRule<String>((value) async {
        throw Exception('Validator exception');
      });
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('async_inline_rule'));
    });

    test('should use custom message on exception', () async {
      final rule = AsyncInlineRule<String>(
        (value) async {
          throw Exception('Validator exception');
        },
        message: 'Custom error message',
      );
      final state = ValidationState();

      await rule.applyAsync('test', state);

      expect(state.errors.first.message, equals('Custom error message'));
    });

    test('should throw on sync apply', () {
      final rule = AsyncInlineRule<String>((value) async => true);
      final state = ValidationState();

      expect(
        () => rule.apply('test', state),
        throwsStateError,
      );
    });
  });
}

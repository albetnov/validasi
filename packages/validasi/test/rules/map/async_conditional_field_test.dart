import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/async_conditional_field.dart';

void main() {
  group('AsyncConditionalField', () {
    test('should pass when callback returns null', () async {
      final rule = AsyncConditionalField<String>(
        'password',
        (context, value) async => null,
      );
      final state = ValidationState();

      await rule.applyAsync(
        <String, String>{'password': 'secret'},
        state,
      );

      expect(state.errors, isEmpty);
    });

    test('should fail when callback returns error message', () async {
      final rule = AsyncConditionalField<String>(
        'password',
        (context, value) async => 'Password is too weak',
      );
      final state = ValidationState();

      await rule.applyAsync(
        <String, String>{'password': 'secret'},
        state,
      );

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('conditionalField'));
      expect(state.errors.first.message, equals('Password is too weak'));
    });

    test('should access other fields through context', () async {
      final rule = AsyncConditionalField<String>(
        'confirmPassword',
        (context, value) async {
          final password = context.get<String>('password');
          if (password != value) {
            return 'Passwords do not match';
          }
          return null;
        },
      );

      var state = ValidationState();
      await rule.applyAsync(
        <String, String>{'password': 'secret', 'confirmPassword': 'secret'},
        state,
      );
      expect(state.errors, isEmpty);

      state = ValidationState();
      await rule.applyAsync(
        <String, String>{'password': 'secret', 'confirmPassword': 'wrong'},
        state,
      );
      expect(state.errors.length, equals(1));
    });

    test('should skip when value is null', () async {
      final rule = AsyncConditionalField<String>(
        'password',
        (context, value) async => 'Should not run',
      );
      final state = ValidationState();

      await rule.applyAsync(null, state);

      expect(state.errors, isEmpty);
    });

    test('should propagate exceptions from callback', () async {
      final rule = AsyncConditionalField<String>(
        'password',
        (context, value) async {
          throw Exception('Callback failed');
        },
      );
      final state = ValidationState();

      expect(
        () => rule.applyAsync(
          <String, String>{'password': 'secret'},
          state,
        ),
        throwsException,
      );
    });

    test('should throw on sync apply', () {
      final rule = AsyncConditionalField<String>(
        'password',
        (context, value) async => null,
      );
      final state = ValidationState();

      expect(
        () => rule.apply(
          <String, String>{'password': 'secret'},
          state,
        ),
        throwsStateError,
      );
    });
  });
}

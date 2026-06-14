import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/async_transform.dart';

void main() {
  group('AsyncTransform', () {
    test('should have runOnNull set to true', () {
      final rule = AsyncTransform<String>((value) async => value);

      expect(rule.runOnNull, isTrue);
    });

    test('should transform value asynchronously', () async {
      final rule =
          AsyncTransform<String>((value) async => value?.toUpperCase());
      final state = ValidationState();

      final result = await rule.applyAsync('test', state);

      expect(result, equals('TEST'));
      expect(state.errors, isEmpty);
    });

    test('should handle null input', () async {
      final rule = AsyncTransform<String>((value) async => 'default');
      final state = ValidationState();

      final result = await rule.applyAsync(null, state);

      expect(result, equals('default'));
      expect(state.errors, isEmpty);
    });

    test('should allow transformation to null', () async {
      final rule = AsyncTransform<String>((value) async => null);
      final state = ValidationState();

      final result = await rule.applyAsync('test', state);

      expect(result, isNull);
      expect(state.errors, isEmpty);
    });

    test('should propagate exceptions from transformer', () async {
      final rule = AsyncTransform<String>((value) async {
        throw Exception('Transform failed');
      });
      final state = ValidationState();

      expect(
        () => rule.applyAsync('test', state),
        throwsException,
      );
    });

    test('should throw on sync apply', () {
      final rule = AsyncTransform<String>((value) async => value);
      final state = ValidationState();

      expect(
        () => rule.apply('test', state),
        throwsStateError,
      );
    });
  });
}

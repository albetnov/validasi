import 'package:test/test.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

void main() {
  group('ValidasiEngine async', () {
    test('should validate successfully with async rule', () async {
      final engine = ValidasiEngine<String, String>(
        rules: [_AsyncPassRule<String>()],
      );

      final result = await engine.validateAsync('test');

      expect(result.isValid, isTrue);
      expect(result.data, equals('test'));
      expect(result.errors, isEmpty);
    });

    test('should validate successfully with only sync rules', () async {
      final engine = ValidasiEngine<String, String>(
        rules: [_SyncPassRule<String>()],
      );

      final result = await engine.validateAsync('test');

      expect(result.isValid, isTrue);
      expect(result.data, equals('test'));
      expect(result.errors, isEmpty);
    });

    test('should fail validation with async rule', () async {
      final engine = ValidasiEngine<String, String>(
        rules: [_AsyncFailRule<String>()],
      );

      final result = await engine.validateAsync('test');

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
      expect(result.errors.first.rule, equals('AsyncFailRule'));
    });

    test('should throw when validate() is used with async rule', () {
      final engine = ValidasiEngine<String, String>(
        rules: [_AsyncPassRule<String>()],
      );

      expect(
        () => engine.validate('test'),
        throwsStateError,
      );
    });

    test('should run async rules sequentially', () async {
      final calls = <String>[];
      final engine = ValidasiEngine<String, String>(rules: [
        _AsyncTrackRule<String>('first', calls),
        _AsyncTrackRule<String>('second', calls),
      ]);

      await engine.validateAsync('test');

      expect(calls, equals(['first', 'second']));
    });

    test('should stop pipeline when state is stopped', () async {
      final engine = ValidasiEngine<String, String>(rules: [
        _AsyncStopRule<String>(),
        _AsyncFailRule<String>(),
      ]);

      final result = await engine.validateAsync('test');

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('should skip async rules on null when runOnNull is false', () async {
      final engine = ValidasiEngine<String, String>(
        rules: [_AsyncFailRule<String>()],
      );

      final result = await engine.validateAsync(null);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('should run async rules on null when runOnNull is true', () async {
      final engine = ValidasiEngine<String, String>(
        rules: [_AsyncRunOnNullRule<String>()],
      );

      final result = await engine.validateAsync(null);

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
    });
  });
}

class _AsyncPassRule<T> extends AsyncRule<T> {
  @override
  Future<T?> applyAsync(T? value, ValidationState state) async => value;
}

class _AsyncFailRule<T> extends AsyncRule<T> {
  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    state.addError(ValidationError(
      rule: 'AsyncFailRule',
      message: 'Async validation failed',
    ));
    return value;
  }
}

class _SyncPassRule<T> extends Rule<T> {
  @override
  T? apply(T? value, ValidationState state) => value;
}

class _AsyncTrackRule<T> extends AsyncRule<T> {
  _AsyncTrackRule(this.name, this.calls);

  final String name;
  final List<String> calls;

  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    calls.add(name);
    return value;
  }
}

class _AsyncStopRule<T> extends AsyncRule<T> {
  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    state.isStopped = true;
    return value;
  }
}

class _AsyncRunOnNullRule<T> extends AsyncRule<T> {
  @override
  bool get runOnNull => true;

  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    state.addError(ValidationError(
      rule: 'AsyncRunOnNullRule',
      message: 'Failed on null',
    ));
    return value;
  }
}

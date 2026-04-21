import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

void main() {
  group('ValidasiEngine', () {
    group('constructor', () {
      test('should create engine with no rules', () {
        final engine = ValidasiEngine<String, String>();

        expect(engine.rules, isNull);
        expect(engine.preprocess, isNull);
        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with rules', () {
        final rule = _TestRule<String>();
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache disabled', () {
        final engine = ValidasiEngine<String, String>(cacheEnabled: false);

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('withPreprocess', () {
      test('should add preprocess transformation', () {
        final engine = ValidasiEngine<int, int>();
        final transformation = ValidasiTransformation<String, int>(
          (input) => int.parse(input),
        );

        final newEngine = engine.withPreprocess(transformation);

        expect(newEngine.preprocess, isNotNull);
        expect(newEngine.rules, equals(engine.rules));
        expect(newEngine.cacheEnabled, equals(engine.cacheEnabled));
      });

      test('should preserve rules when adding preprocess', () {
        final rule = _TestRule<int>();
        final engine = ValidasiEngine<int, int>(rules: [rule]);
        final transformation = ValidasiTransformation<String, int>(
          (input) => int.parse(input),
        );

        final newEngine = engine.withPreprocess(transformation);

        expect(newEngine.rules, equals(engine.rules));
      });

      test('should preserve cache setting when adding preprocess', () {
        final engine = ValidasiEngine<int, int>(cacheEnabled: false);
        final transformation = ValidasiTransformation<String, int>(
          (input) => int.parse(input),
        );

        final newEngine = engine.withPreprocess(transformation);

        expect(newEngine.cacheEnabled, isFalse);
      });
    });

    group('validate', () {
      test('should validate successfully with no rules', () {
        final engine = ValidasiEngine<String, String>();

        final result = engine.validate('test');

        expect(result.isValid, isTrue);
        expect(result.data, equals('test'));
        expect(result.errors, isEmpty);
      });

      test('should validate with single rule passing', () {
        final rule = _TestRule<String>(shouldPass: true);
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        final result = engine.validate('test');

        expect(result.isValid, isTrue);
        expect(result.data, equals('test'));
        expect(result.errors, isEmpty);
      });

      test('should validate with single rule failing', () {
        final rule = _TestRule<String>(shouldPass: false);
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        final result = engine.validate('test');

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first.rule, equals('TestRule'));
      });

      test('should validate with multiple rules', () {
        final rule1 = _TestRule<String>(shouldPass: true, ruleName: 'Rule1');
        final rule2 = _TestRule<String>(shouldPass: true, ruleName: 'Rule2');
        final engine = ValidasiEngine<String, String>(rules: [rule1, rule2]);

        final result = engine.validate('test');

        expect(result.isValid, isTrue);
      });

      test('should collect errors from multiple failing rules', () {
        final rule1 = _TestRule<String>(shouldPass: false, ruleName: 'Rule1');
        final rule2 = _TestRule<String>(shouldPass: false, ruleName: 'Rule2');
        final engine = ValidasiEngine<String, String>(rules: [rule1, rule2]);

        final result = engine.validate('test');

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(2));
        expect(result.errors[0].rule, equals('Rule1'));
        expect(result.errors[1].rule, equals('Rule2'));
      });

      test('should stop validation when context is stopped', () {
        final rule1 = _TestRule<String>(shouldStop: true, ruleName: 'Rule1');
        final rule2 = _TestRule<String>(shouldPass: false, ruleName: 'Rule2');
        final engine = ValidasiEngine<String, String>(rules: [rule1, rule2]);

        final result = engine.validate('test');

        expect(result.isValid, isTrue); // No errors since rule2 wasn't run
      });

      test('should skip rules on null value if runOnNull is false', () {
        final rule =
            _TestRule<String>(shouldPass: false, runOnNullValue: false);
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        final result = engine.validate(null);

        expect(result.isValid, isTrue); // Rule was skipped
      });

      test('should run rules on null value if runOnNull is true', () {
        final rule = _TestRule<String>(
          shouldPass: false,
          runOnNullValue: true,
          ruleName: 'NullRule',
        );
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        final result = engine.validate(null);

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(1));
      });

      test('should validate with preprocess transformation', () {
        final transformation = ValidasiTransformation<String, int>(
          (input) => int.parse(input),
        );
        final engine =
            ValidasiEngine<int, int>().withPreprocess(transformation);

        final result = engine.validate('42');

        expect(result.isValid, isTrue);
        expect(result.data, equals(42));
      });

      test('should fail validation if preprocess fails', () {
        final transformation = ValidasiTransformation<String, int>(
          (input) => int.parse(input),
        );
        final engine =
            ValidasiEngine<int, int>().withPreprocess(transformation);

        final result = engine.validate('not a number');

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first.rule, equals('Preprocess'));
        expect(
            result.errors.first.message, equals('Failed to preprocess value'));
      });

      test('should fail validation with type mismatch', () {
        final engine = ValidasiEngine<String, dynamic>();
        final dynamic invalidValue = 42;

        final result = engine.validate(invalidValue);

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first.rule, equals('TypeCheck'));
      });

      test('should allow null for nullable types', () {
        final engine = ValidasiEngine<String?, String?>();

        final result = engine.validate(null);

        expect(result.isValid, isTrue);
        expect(result.data, isNull);
      });

      test('should apply rule that modifies value', () {
        final rule = _ModifyRule<String>();
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        final result = engine.validate('test');

        expect(result.isValid, isTrue);
        expect(result.data, equals('TEST'));
      });
    });

    group('caching', () {
      test('should cache validation results', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);
        final engine =
            ValidasiEngine<String, String>(rules: [rule], cacheEnabled: true);

        engine.validate('test');
        engine.validate('test');

        expect(callCount, equals(1)); // Rule only called once
      });

      test('should not cache when disabled', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);
        final engine = ValidasiEngine<String, String>(
          rules: [rule],
          cacheEnabled: false,
        );

        engine.validate('test');
        engine.validate('test');

        expect(callCount, equals(2)); // Rule called twice
      });

      test('should cache different values separately', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);
        final engine =
            ValidasiEngine<String, String>(rules: [rule], cacheEnabled: true);

        engine.validate('test1');
        engine.validate('test2');
        engine.validate('test1');
        engine.validate('test2');

        expect(callCount, equals(2)); // One call per unique value
      });

      test('clearCache should clear cached results', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);
        final engine =
            ValidasiEngine<String, String>(rules: [rule], cacheEnabled: true);

        engine.validate('test');
        engine.clearCache();
        engine.validate('test');

        expect(callCount, equals(2)); // Called again after cache clear
      });

      test('should cache preprocess failures', () {
        var callCount = 0;
        final transformation = ValidasiTransformation<String, int>(
          (input) {
            callCount++;
            return int.parse(input);
          },
        );
        final engine =
            ValidasiEngine<int, int>().withPreprocess(transformation);

        engine.validate('not a number');
        engine.validate('not a number');

        expect(callCount, equals(1)); // Transformation only called once
      });

      test('should cache type check failures', () {
        final engine = ValidasiEngine<String, dynamic>(cacheEnabled: true);
        final dynamic invalidValue = 42;

        final result1 = engine.validate(invalidValue);
        final result2 = engine.validate(invalidValue);

        expect(result1.isValid, isFalse);
        expect(result2.isValid, isFalse);
        // Both should come from cache (same object identity would confirm this)
      });
    });
  });
}

class _TestRule<T> extends Rule<T> {
  _TestRule({
    this.shouldPass = true,
    this.shouldStop = false,
    this.runOnNullValue = false,
    this.ruleName = 'TestRule',
  });

  final bool shouldPass;
  final bool shouldStop;
  final bool runOnNullValue;
  final String ruleName;

  @override
  bool get runOnNull => runOnNullValue;

  @override
  void apply(ValidationContext<T> context) {
    if (!shouldPass) {
      context.addError(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }

    if (shouldStop) {
      context.stop();
    }
  }
}

class _ModifyRule<T> extends Rule<T> {
  @override
  void apply(ValidationContext<T> context) {
    if (context.value is String) {
      context.setValue((context.value as String).toUpperCase() as T);
    }
  }
}

class _CountingRule<T> extends Rule<T> {
  _CountingRule(this.onCall);

  final void Function() onCall;

  @override
  void apply(ValidationContext<T> context) {
    onCall();
  }
}

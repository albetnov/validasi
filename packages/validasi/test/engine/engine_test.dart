import 'package:test/test.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

void main() {
  group('ValidasiEngine', () {
    group('constructor', () {
      test('should create engine with no rules', () {
        final engine = ValidasiEngine<String, String>();

        expect(engine.rules, isNull);
        expect(engine.preprocess, isNull);
      });

      test('should create engine with rules', () {
        final rule = _TestRule<String>();
        final engine = ValidasiEngine<String, String>(rules: [rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
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
  T? apply(T? value, ValidationState state) {
    if (!shouldPass) {
      state.addError(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }

    if (shouldStop) {
      state.isStopped = true;
    }

    return value;
  }
}

class _ModifyRule<T> extends Rule<T> {
  @override
  T? apply(T? value, ValidationState state) {
    if (value is String) {
      return (value).toUpperCase() as T;
    }
    return value;
  }
}

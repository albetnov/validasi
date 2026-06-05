import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/engine.dart';
import 'package:validasi/src/rules/map/has_fields.dart';

final mapData = <String, dynamic>{
  'name': 'Alice',
  'age': 30,
  'email': 'alice@example.com',
  'score': 95,
};

final fieldRules = HasFields({
  'name': FieldRules<String>([Rules.string.minLength(2)]),
  'age': FieldRules<int>([Rules.number.moreThanEqual(18)]),
  'email': FieldRules<String>([Rules.string.minLength(5)]),
  'score': FieldRules<int>(
      [Rules.number.moreThanEqual(0), Rules.number.lessThan(100)]),
});

class FieldRulesBenchmark extends BenchmarkBase {
  FieldRulesBenchmark() : super('FieldRules_HasFields');

  @override
  void run() {
    final state = ValidationState();
    fieldRules.apply(mapData, state);
  }
}

// Simulate old engine-based approach for comparison
final engineFields = <String, ValidasiEngine<Object?, dynamic>>{
  'name': ValidasiEngine<Object?, dynamic>(
    rules: [Rules.string.minLength(2)],
  ),
  'age': ValidasiEngine<Object?, dynamic>(
    rules: [Rules.number.moreThanEqual(18)],
  ),
  'email': ValidasiEngine<Object?, dynamic>(
    rules: [Rules.string.minLength(5)],
  ),
  'score': ValidasiEngine<Object?, dynamic>(
    rules: [Rules.number.moreThanEqual(0), Rules.number.lessThan(100)],
  ),
};

class EngineHasFieldsBenchmark extends BenchmarkBase {
  EngineHasFieldsBenchmark() : super('Engine_HasFields');

  @override
  void run() {
    final state = ValidationState();
    for (final entry in engineFields.entries) {
      entry.value.execute(mapData[entry.key], state);
    }
  }
}

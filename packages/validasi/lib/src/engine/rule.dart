import 'package:validasi/src/engine/state.dart';

abstract class Rule<T> {
  const Rule({this.message});

  final String? message;

  final bool runOnNull = false;



  T? apply(T? value, ValidationState state);
}

@pragma('vm:prefer-inline')
T? applyRules<T>(T? value, List<Rule<T>>? rules, ValidationState state) {
  for (final rule in rules ?? const []) {
    if (value == null && !rule.runOnNull) {
      continue;
    }

    value = rule.apply(value, state);

    if (state.isStopped) {
      break;
    }
  }

  return value;
}

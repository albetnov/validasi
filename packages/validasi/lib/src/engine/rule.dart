import 'package:validasi/src/engine/state.dart';

abstract class Rule<T> {
  const Rule({this.message});

  final String? message;

  final bool runOnNull = false;

  T? apply(T? value, ValidationState state);

  Future<T?> applyAsync(T? value, ValidationState state) async =>
      apply(value, state);
}

abstract class AsyncRule<T> extends Rule<T> {
  const AsyncRule({super.message});

  @override
  T? apply(T? value, ValidationState state) {
    throw StateError(
      'Async rules cannot be used with validate(). Use validateAsync() instead.',
    );
  }

  @override
  Future<T?> applyAsync(T? value, ValidationState state);
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

@pragma('vm:prefer-inline')
Future<T?> applyRulesAsync<T>(
  T? value,
  List<Rule<T>>? rules,
  ValidationState state,
) async {
  for (final rule in rules ?? const []) {
    if (value == null && !rule.runOnNull) {
      continue;
    }

    value = await rule.applyAsync(value, state);

    if (state.isStopped) {
      break;
    }
  }

  return value;
}

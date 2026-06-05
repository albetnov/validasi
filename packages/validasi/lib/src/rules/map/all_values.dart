import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class AllValues<I> extends Rule<Map<String, I>> {
  const AllValues(this.rules);

  final List<Rule<I>> rules;

  @override
  Map<String, I>? apply(Map<String, I>? value, ValidationState state) {
    if (value == null) return null;

    for (final entry in value.entries) {
      final before = state.errors.length;
      applyRules(entry.value, rules, state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix(entry.key);
      }
    }
    return value;
  }
}

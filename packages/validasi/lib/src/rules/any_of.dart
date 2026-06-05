import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class AnyOf<T> extends Rule<T> {
  const AnyOf(this.ruleSets, {super.message});

  final List<List<Rule<T>>> ruleSets;

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null) {
      for (final ruleSet in ruleSets) {
        final testState = ValidationState();
        applyRules(value, ruleSet, testState);

        if (testState.isValid) {
          return value;
        }
      }

      state.addError(ValidationError(
        rule: 'AnyOf',
        message: message ?? 'Value must satisfy at least one rule set',
      ));
    }
    return value;
  }
}

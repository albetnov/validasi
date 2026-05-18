import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class ForEach<I> extends Rule<List<I>> {
  const ForEach(this.itemRules);

  final List<Rule<I>> itemRules;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'ForEach',
        parameters: {'itemType': '$I'},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  Map<String, Object?> get metadataChildren {
    final rules = <String, Object?>{};
    for (var i = 0; i < itemRules.length; i++) {
      rules['rule_$i'] = itemRules[i];
    }
    return rules;
  }

  @override
  List<I>? apply(List<I>? value, ValidationState state) {
    if (value == null) return null;

    for (var i = 0; i < value.length; i++) {
      final before = state.errors.length;
      value[i] = applyRules(value[i], itemRules, state) as I;
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix('[$i]');
      }
    }
    return value;
  }
}

import 'package:validasi/src/compiler/opcodes.dart';
import 'package:validasi/src/rules/rule.dart';

/// User-facing rule: `list.length >= min`
class ListMinLengthRule implements ListRule {
  const ListMinLengthRule(this.min);

  @override
  final int opcode = OpCodes.listMinLength;
  final int min;
}

/// User-facing rule: execute nested rules for every list item.
class ListForEachRule<T> implements ListRule {
  const ListForEachRule(this.rules);

  @override
  final int opcode = OpCodes.listForEach;
  final List<Rule<T>> rules;
}

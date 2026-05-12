import 'package:validasi/src/compiler/opcodes.dart';
import 'package:validasi/src/rules/rule.dart';

/// User-facing rule: `string.length >= min`
class StringMinLengthRule implements StringRule {
  const StringMinLengthRule(this.min);

  @override
  final int opcode = OpCodes.stringMinLength;
  final int min;
}

/// User-facing rule: `string.length <= max`
class StringMaxLengthRule implements StringRule {
  const StringMaxLengthRule(this.max);

  @override
  final int opcode = OpCodes.stringMaxLength;
  final int max;
}

/// User-facing rule: `string ∈ {options}`
class StringOneOfRule implements StringRule {
  const StringOneOfRule(this.options);

  @override
  final int opcode = OpCodes.stringOneOf;
  final List<String> options;
}

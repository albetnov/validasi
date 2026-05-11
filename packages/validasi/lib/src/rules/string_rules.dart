import 'package:validasi/src/compiler/opcodes.dart';

/// User-facing rule: `string.length >= min`
class StringMinLengthRule {
  const StringMinLengthRule(this.min);

  final int opcode = OpCodes.stringMinLength;
  final int min;
}

/// User-facing rule: `string.length <= max`
class StringMaxLengthRule {
  const StringMaxLengthRule(this.max);

  final int opcode = OpCodes.stringMaxLength;
  final int max;
}

/// User-facing rule: `string ∈ {options}`
class StringOneOfRule {
  const StringOneOfRule(this.options);

  final int opcode = OpCodes.stringOneOf;
  final List<String> options;
}

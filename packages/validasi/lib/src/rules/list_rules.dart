import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/compiler/opcodes.dart';

/// User-facing rule: `list.length >= min`
class ListMinLengthRule {
  const ListMinLengthRule(this.min);

  final int opcode = OpCodes.listMinLength;
  final int min;
}

/// User-facing rule: execute a nested engine for every list item.
class ListForEachRule {
  const ListForEachRule(this.itemSchema);

  final int opcode = OpCodes.listForEach;
  final ValidasiEngine<dynamic, dynamic> itemSchema;
}

import 'dart:typed_data';

/// Final compiled form: opcode + flat Int32List parameters.
///
/// Produced by the Compiler. Designed for L1-cache locality and
/// monomorphic dispatch in the Executor's switch statement.
class CompiledRule {
  const CompiledRule(this.opcode, this.params);

  final int opcode;

  /// Packed numeric parameters. Layout is opcode-specific.
  final Int32List params;
}

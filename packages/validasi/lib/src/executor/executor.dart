import 'package:validasi/src/compiler/compiled_rule.dart';
import 'package:validasi/src/compiler/opcodes.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/executor/execution_context.dart';
import 'package:validasi/src/executor/executor_list.dart';
import 'package:validasi/src/executor/executor_string.dart';

class Executor<T> {
  const Executor({
    required this.rules,
    required this.stringTable,
    required this.nestedRules,
  });

  final List<CompiledRule> rules;
  final List<String> stringTable;
  final List<List<CompiledRule>> nestedRules;

  ValidasiResult<T> validate(T value) {
    final ctx = ExecutionContext();
    final errors = <ValidationError>[];
    for (final rule in rules) {
      final msgs = dispatch(rule, value, ctx);
      if (msgs != null) {
        final name = _ruleName(rule.opcode);
        for (final msg in msgs) {
          errors.add(ValidationError(rule: name, message: msg));
        }
      }
      if (ctx.isStopped) break;
    }
    return ValidasiResult<T>(
      isValid: errors.isEmpty,
      errors: errors,
      data: value,
    );
  }

  @pragma('vm:inline')
  List<String>? dispatch(
      CompiledRule rule, dynamic value, ExecutionContext ctx) {
    switch (rule.opcode) {
      case OpCodes.stringMinLength:
        return executeStringMinLength(rule.params, value as String, ctx);
      case OpCodes.stringMaxLength:
        return executeStringMaxLength(rule.params, value as String, ctx);
      case OpCodes.stringOneOf:
        return executeStringOneOf(
            rule.params, value as String, stringTable, ctx);
      case OpCodes.listMinLength:
        return executeListMinLength(rule.params, value as List, ctx);
      case OpCodes.listForEach:
        return executeListForEach(rule.params, value as List, ctx);
      default:
        throw ArgumentError('Unknown opcode: ${rule.opcode}');
    }
  }

  static String _ruleName(int opcode) {
    switch (opcode) {
      case OpCodes.stringMinLength:
        return 'StringMinLength';
      case OpCodes.stringMaxLength:
        return 'StringMaxLength';
      case OpCodes.stringOneOf:
        return 'StringOneOf';
      case OpCodes.listMinLength:
        return 'ListMinLength';
      case OpCodes.listForEach:
        return 'ListForEach';
      default:
        return 'Rule_$opcode';
    }
  }
}

import 'dart:typed_data';

import 'package:validasi/src/executor/execution_context.dart';
import 'package:validasi/src/executor/executor.dart';

extension ListRuleExecutor<T> on Executor<T> {
  @pragma('vm:inline')
  List<String>? executeListMinLength(
    Int32List params,
    List value,
    ExecutionContext ctx,
  ) =>
      value.length >= params[0]
          ? null
          : ['List must have at least ${params[0]} items'];

  @pragma('vm:inline')
  List<String>? executeListForEach(
    Int32List params,
    List value,
    ExecutionContext ctx,
  ) {
    final rules = nestedRules[params[0]];
    final errors = <String>[];
    for (var i = 0; i < value.length; i++) {
      final itemCtx = ExecutionContext();
      for (final rule in rules) {
        final msgs = dispatch(rule, value[i], itemCtx);
        if (msgs != null) {
          for (final msg in msgs) {
            errors.add('[$i]$msg');
          }
        }
        if (itemCtx.isStopped) break;
      }
      if (itemCtx.isStopped) {
        ctx.isStopped = true;
        break;
      }
    }
    return errors.isEmpty ? null : errors;
  }
}

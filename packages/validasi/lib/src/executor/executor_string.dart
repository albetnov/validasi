import 'dart:typed_data';

import 'package:validasi/src/executor/execution_context.dart';
import 'package:validasi/src/executor/executor.dart';

extension StringRuleExecutor<T> on Executor<T> {
  @pragma('vm:inline')
  List<String>? executeStringMinLength(
    Int32List params,
    String value,
    ExecutionContext ctx,
  ) =>
      value.length >= params[0]
          ? null
          : ['Minimum length is ${params[0]} characters'];

  @pragma('vm:inline')
  List<String>? executeStringMaxLength(
    Int32List params,
    String value,
    ExecutionContext ctx,
  ) =>
      value.length <= params[0]
          ? null
          : ['Maximum length is ${params[0]} characters'];

  @pragma('vm:inline')
  List<String>? executeStringOneOf(
    Int32List params,
    String value,
    List<String> stringTable,
    ExecutionContext ctx,
  ) {
    for (var i = 0; i < params.length; i++) {
      if (value == stringTable[params[i]]) return null;
    }
    return ['Value must be one of the allowed options'];
  }
}

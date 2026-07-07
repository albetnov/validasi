import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class ExactLengthGen extends RuleGen {
  @override
  String get name => 'ExactLength';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.iterable};

  @override
  void validateType(FieldContext context, FieldElement field) {
    if (!supportedContexts.contains(context)) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${field.type.getDisplayString()}'. "
        'Supported: ${supportedContexts.map((c) => c.name)}',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    final length = rule.read('length').intValue;
    return RuleInfo(
        'ExactLength', {'length': length}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final length = info.params['length'] as int;
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr.length != $length';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.iterable]) {
    return 'List must have exactly ${info.params['length']} items';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.iterable]) {
    return '_Errors.exactLength($pathExpr, ${info.params['length']}$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'exactLength':
            "static ValidationError exactLength(List<String> path, int length, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'ExactLength',\n"
                "        message: message ?? 'List must have exactly \$length items',\n"
                '        path: path,\n'
                '      );',
      };
}

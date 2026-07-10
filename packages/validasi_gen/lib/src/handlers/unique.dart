import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class UniqueGen extends RuleGen {
  @override
  String get name => 'Unique';

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
    return RuleInfo('Unique', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr.toSet().length != $expr.length';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.iterable]) =>
      'List must contain only unique items';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.iterable]) =>
      '_Errors.unique($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'unique':
            "static ValidationError unique(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Unique',\n"
                "        message: message ?? 'List must contain only unique items',\n"
                '        path: path,\n'
                '      );',
      };
}

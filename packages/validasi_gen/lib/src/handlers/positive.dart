import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class PositiveGen extends RuleGen {
  @override
  String get name => 'Positive';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.generic};

  @override
  void validateType(FieldContext context, FieldElement field) {
    final type = field.type;
    if (!type.isDartCoreInt && !type.isDartCoreDouble) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${type.getDisplayString()}'. "
        'Supported: int, double',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Positive', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr <= 0';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must be positive';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.positive($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'positive':
            "static ValidationError positive(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Positive',\n"
                "        message: message ?? 'Value must be positive',\n"
                '        path: path,\n'
                '      );',
      };
}

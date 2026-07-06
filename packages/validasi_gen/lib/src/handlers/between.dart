import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class BetweenGen extends RuleGen {
  @override
  String get name => 'Between';

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
    final min = literalForConstant(rule.read('min'));
    final max = literalForConstant(rule.read('max'));
    return RuleInfo('Between', {'min': min, 'max': max},
        rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final min = info.params['min'];
    final max = info.params['max'];
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard($fieldName < $min || $fieldName > $max)';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.generic]) {
    return 'Value must be between ${info.params['min']} and ${info.params['max']}';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.generic]) {
    return '_Errors.between($pathExpr, ${info.params['min']}, ${info.params['max']}$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'between':
            "static ValidationError between(List<String> path, num min, num max, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Between',\n"
                "        message: message ?? 'Value must be between \$min and \$max',\n"
                '        path: path,\n'
                '      );',
      };
}

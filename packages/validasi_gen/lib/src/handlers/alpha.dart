import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class AlphaGen extends RuleGen {
  static const _pattern = r'^[a-zA-Z]+$';

  @override
  String get name => 'Alpha';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

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
    return RuleInfo('Alpha', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard!RegExp(${escapeDartString(_pattern)}).hasMatch($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must contain only letters';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.alpha($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'alpha':
            "static ValidationError alpha(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Alpha',\n"
                "        message: message ?? 'Must contain only letters',\n"
                '        path: path,\n'
                '      );',
      };
}

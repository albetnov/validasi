import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class RegexGen extends RuleGen {
  @override
  String get name => 'Regex';

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
    final pattern = rule.read('pattern').stringValue;
    return RuleInfo(
        'Regex', {'pattern': pattern}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final pattern = info.params['pattern'] as String;
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard!RegExp(${escapeDartString(pattern)}).hasMatch($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final pattern = info.params['pattern'] as String;
    return 'Must match pattern "$pattern"';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final pattern = info.params['pattern'] as String;
    return '_Errors.regex($pathExpr, ${escapeDartString(pattern)}$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'regex':
            "static ValidationError regex(List<String> path, String pattern, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Regex',\n"
                "        message: message ?? 'Must match pattern \"\$pattern\"',\n"
                "        details: {'pattern': pattern},\n"
                '        path: path,\n'
                '      );',
      };
}

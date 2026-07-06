import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class LowercaseGen extends RuleGen {
  @override
  String get name => 'Lowercase';

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
    return RuleInfo('Lowercase', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName != $fieldName.toLowerCase()';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be lowercase';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.lowercase($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'lowercase':
            "static ValidationError lowercase(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Lowercase',\n"
                "        message: message ?? 'Must be lowercase',\n"
                '        path: path,\n'
                '      );',
      };
}

class UppercaseGen extends RuleGen {
  @override
  String get name => 'Uppercase';

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
    return RuleInfo('Uppercase', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName != $fieldName.toUpperCase()';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be uppercase';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.uppercase($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'uppercase':
            "static ValidationError uppercase(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Uppercase',\n"
                "        message: message ?? 'Must be uppercase',\n"
                '        path: path,\n'
                '      );',
      };
}

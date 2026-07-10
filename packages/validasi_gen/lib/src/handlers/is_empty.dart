import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class IsEmptyGen extends RuleGen {
  @override
  String get name => 'IsEmpty';

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
    return RuleInfo('IsEmpty', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr.isNotEmpty';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.iterable]) =>
      'List must be empty';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.iterable]) =>
      '_Errors.isEmpty($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'isEmpty':
            "static ValidationError isEmpty(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'IsEmpty',\n"
                "        message: message ?? 'List must be empty',\n"
                '        path: path,\n'
                '      );',
      };
}

class IsNotEmptyGen extends RuleGen {
  @override
  String get name => 'IsNotEmpty';

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
    return RuleInfo('IsNotEmpty', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr.isEmpty';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.iterable]) =>
      'List must not be empty';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.iterable]) =>
      '_Errors.isNotEmpty($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'isNotEmpty':
            "static ValidationError isNotEmpty(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'IsNotEmpty',\n"
                "        message: message ?? 'List must not be empty',\n"
                '        path: path,\n'
                '      );',
      };
}

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class ContainsGen extends RuleGen {
  @override
  String get name => 'Contains';

  @override
  Set<FieldContext> get supportedContexts =>
      {FieldContext.string, FieldContext.iterable};

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
    final value = _literal(rule.read('value'));
    return RuleInfo(
        'Contains', {'value': value}, rule.peek('message')?.stringValue);
  }

  String _literal(ConstantReader reader) {
    if (reader.isNull) return 'null';
    final type = reader.objectValue.type;
    if (type == null) return 'null';
    if (type.isDartCoreString) return escapeDartString(reader.stringValue);
    if (type.isDartCoreInt) return reader.intValue.toString();
    if (type.isDartCoreDouble) return reader.doubleValue.toString();
    if (type.isDartCoreBool) return reader.boolValue.toString();
    if (type is InterfaceType && type.element is EnumElement) {
      return reader.revive().accessor;
    }
    return escapeDartString(reader.objectValue.toString());
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final value = info.params['value'] as String;
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!$expr.contains($value)';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final value = info.params['value'] as String;
    return context == FieldContext.iterable
        ? 'List must contain $value'
        : 'Must contain "$value"';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final value = info.params['value'] as String;
    final helper = context == FieldContext.iterable ? 'itContains' : 'contains';
    return '_Errors.$helper($pathExpr, $value$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'contains':
            "static ValidationError contains(List<String> path, Object? value, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Contains',\n"
                "        message: message ?? 'Must contain \"\$value\"',\n"
                '        path: path,\n'
                '      );',
        'itContains':
            "static ValidationError itContains(List<String> path, Object? value, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Contains',\n"
                "        message: message ?? 'List must contain \$value',\n"
                '        path: path,\n'
                '      );',
      };
}

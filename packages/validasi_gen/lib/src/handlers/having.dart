import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class HavingGen extends RuleGen {
  @override
  String get name => 'Having';

  @override
  RuleInfo parse(ConstantReader rule) {
    final validValues = rule
        .read('validValues')
        .listValue
        .map((v) => _literal(ConstantReader(v)))
        .toList();
    return RuleInfo('Having', {'validValues': validValues},
        rule.peek('message')?.stringValue);
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

  // Having always runs, even on null values (mirrors validasi's runOnNull).
  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final validValues = info.params['validValues'] as List<String>;
    return '![${validValues.join(', ')}].contains($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.generic]) {
    final validValues = info.params['validValues'] as List<String>;
    return 'Value must be one of: ${validValues.join(', ')}';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.generic]) {
    final validValues = info.params['validValues'] as List<String>;
    return '_Errors.having($pathExpr, [${validValues.join(', ')}]$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'having':
            "static ValidationError having(List<String> path, List<Object?> validValues, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Having',\n"
                "        message: message ?? 'Value must be one of: \${validValues.join(\", \")}',\n"
                '        path: path,\n'
                '      );',
      };

  @override
  void validateType(FieldContext context, FieldElement field) {}
}

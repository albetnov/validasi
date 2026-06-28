import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class OneOfGen extends RuleGen {
  @override
  String get name => 'OneOf';

  @override
  RuleInfo parse(ConstantReader rule) {
    final optionsList = rule.read('options').listValue;
    final options = <String>[];
    for (final o in optionsList) {
      options.add(_literalForOption(ConstantReader(o)));
    }
    return RuleInfo(
      'OneOf',
      {'options': options},
      rule.peek('message')?.stringValue,
      typeArg: typeArgOf(rule),
    );
  }

  String _literalForOption(ConstantReader reader) {
    final type = reader.objectValue.type;
    if (reader.isNull) return 'null';
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
  void validateType(DartType? typeArg, FieldElement field) {}

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final options = info.params['options'] as List<String>;
    final items = options.join(', ');
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard![$items].contains($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info, [String context = '']) {
    final options = info.params['options'] as List<String>;
    final display = options.map((o) {
      if (o.startsWith("'")) {
        return o.substring(1, o.length - 1);
      }
      return o;
    }).join(', ');
    return 'Value must be one of: $display';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [String context = '']) {
    final options = info.params['options'] as List<String>;
    final optionsExpr = '[${options.join(', ')}]';
    return '_Errors.oneOf($pathExpr, $optionsExpr$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'oneOf':
            "static ValidationError oneOf(List<String> path, List<Object?> options, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'OneOf',\n"
                "        message: message ?? 'Value must be one of: \${options.join(\", \")}',\n"
                "        details: {'options': '\${options.join(\",\")}'},\n"
                '        path: path,\n'
                '      );',
      };
}

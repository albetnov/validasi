import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class EndsWithGen extends RuleGen {
  @override
  String get name => 'EndsWith';

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
    final suffix = rule.read('suffix').stringValue;
    return RuleInfo(
        'EndsWith', {'suffix': suffix}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final suffix = info.params['suffix'] as String;
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard!$fieldName.endsWith(${escapeDartString(suffix)})';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final suffix = info.params['suffix'] as String;
    return 'Must end with "$suffix"';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final suffix = info.params['suffix'] as String;
    return '_Errors.endsWith($pathExpr, ${escapeDartString(suffix)}$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'endsWith':
            "static ValidationError endsWith(List<String> path, String suffix, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'EndsWith',\n"
                "        message: message ?? 'Must end with \"\$suffix\"',\n"
                "        details: {'suffix': suffix},\n"
                '        path: path,\n'
                '      );',
      };
}

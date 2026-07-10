import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class UuidGen extends RuleGen {
  static const _pattern =
      r'^[0-9a-f]{8}-[0-9a-f]{4}-([0-9a-f])[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

  @override
  String get name => 'Uuid';

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
    final versions = rule
        .read('versions')
        .listValue
        .map((v) => ConstantReader(v).intValue)
        .toList();
    return RuleInfo(
        'Uuid', {'versions': versions}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final versions = info.params['versions'] as List<int>;
    final versionsLiteral = '[${versions.join(', ')}]';
    final guard = nullable ? '$fieldName != null && ' : '';
    final patternLiteral = escapeDartString(_pattern);
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard(!RegExp($patternLiteral, caseSensitive: false).hasMatch($expr) || '
        '!$versionsLiteral.contains(int.parse(RegExp($patternLiteral, caseSensitive: false).firstMatch($expr)!.group(1)!, radix: 16)))';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final versions = info.params['versions'] as List<int>;
    return 'Must be a valid UUID (v${versions.join("/v")})';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final versions = info.params['versions'] as List<int>;
    final versionsLiteral = '[${versions.join(', ')}]';
    return '_Errors.uuid($pathExpr, $versionsLiteral$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'uuid': "static ValidationError uuid(List<String> path, List<int> versions, {String? message}) =>\n"
            '      ValidationError(\n'
            "        rule: 'Uuid',\n"
            "        message: message ?? 'Must be a valid UUID (v\${versions.join(\"/v\")})',\n"
            "        details: {'versions': versions.join(', ')},\n"
            '        path: path,\n'
            '      );',
      };
}

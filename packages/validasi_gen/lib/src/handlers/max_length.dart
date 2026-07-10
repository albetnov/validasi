import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class MaxLengthGen extends RuleGen {
  @override
  String get name => 'MaxLength';

  @override
  Set<FieldContext> get supportedContexts =>
      {FieldContext.string, FieldContext.iterable};

  static const _errorNames = {
    FieldContext.string: 'maxLength',
    FieldContext.iterable: 'itMaxLength',
  };

  static const _messages = {
    FieldContext.string: 'Maximum length is %s characters',
    FieldContext.iterable: 'List must have at most %s items',
  };

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
    final length = rule.read('length').intValue;
    return RuleInfo(
      'MaxLength',
      {'length': length},
      rule.peek('message')?.stringValue,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final length = info.params['length'] as int;
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard$expr.length > $length';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final length = info.params['length'];
    return (_messages[context] ?? _messages[FieldContext.string]!)
        .replaceFirst('%s', length.toString());
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final length = info.params['length'] as int;
    final helper = _errorNames[context] ?? _errorNames[FieldContext.string]!;
    return '_Errors.$helper($pathExpr, $length$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'maxLength':
            "static ValidationError maxLength(List<String> path, int length, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'MaxLength',\n"
                "        message: message ?? 'Maximum length is \$length characters',\n"
                "        details: {'length': '\$length'},\n"
                '        path: path,\n'
                '      );',
        'itMaxLength':
            "static ValidationError itMaxLength(List<String> path, int length, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'MaxLength',\n"
                "        message: message ?? 'List must have at most \$length items',\n"
                "        details: {'length': '\$length'},\n"
                '        path: path,\n'
                '      );',
      };
}

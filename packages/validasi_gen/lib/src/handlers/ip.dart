import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

const _ipv4Pattern =
    r'^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$';

const _ipv6Pattern = r'^('
    r'([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|'
    r'([0-9a-fA-F]{1,4}:){1,7}:|'
    r'([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|'
    r'([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|'
    r'([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|'
    r'([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|'
    r'([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|'
    r'[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|'
    r':((:[0-9a-fA-F]{1,4}){1,7}|:)'
    r')$';

void _validateStringType(String name, FieldContext context, FieldElement field,
    Set<FieldContext> supported) {
  if (!supported.contains(context)) {
    throw InvalidGenerationSourceError(
      "$name is not supported on type '${field.type.getDisplayString()}'. "
      'Supported: ${supported.map((c) => c.name)}',
      element: field,
    );
  }
}

class Ipv4Gen extends RuleGen {
  @override
  String get name => 'Ipv4';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  void validateType(FieldContext context, FieldElement field) =>
      _validateStringType(name, context, field, supportedContexts);

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Ipv4', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!RegExp(${escapeDartString(_ipv4Pattern)}).hasMatch($expr)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid IPv4 address';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.ipv4($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'ipv4':
            "static ValidationError ipv4(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Ipv4',\n"
                "        message: message ?? 'Must be a valid IPv4 address',\n"
                '        path: path,\n'
                '      );',
      };
}

class Ipv6Gen extends RuleGen {
  @override
  String get name => 'Ipv6';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  void validateType(FieldContext context, FieldElement field) =>
      _validateStringType(name, context, field, supportedContexts);

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Ipv6', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!RegExp(${escapeDartString(_ipv6Pattern)}).hasMatch($expr)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid IPv6 address';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.ipv6($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'ipv6':
            "static ValidationError ipv6(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Ipv6',\n"
                "        message: message ?? 'Must be a valid IPv6 address',\n"
                '        path: path,\n'
                '      );',
      };
}

class IpGen extends RuleGen {
  @override
  String get name => 'Ip';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  void validateType(FieldContext context, FieldElement field) =>
      _validateStringType(name, context, field, supportedContexts);

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Ip', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!RegExp(${escapeDartString(_ipv4Pattern)}).hasMatch($expr) && '
        '!RegExp(${escapeDartString(_ipv6Pattern)}).hasMatch($expr)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid IP address';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.ip($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'ip':
            "static ValidationError ip(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Ip',\n"
                "        message: message ?? 'Must be a valid IP address',\n"
                '        path: path,\n'
                '      );',
      };
}

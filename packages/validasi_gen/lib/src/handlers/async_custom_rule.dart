import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class AsyncCustomRuleGen extends RuleGen {
  @override
  String get name => 'AsyncCustomRule';

  @override
  bool get isAsync => true;

  @override
  RuleInfo parse(ConstantReader rule) {
    final type = rule.objectValue.type;
    final typeElement = type!.element as ClassElement;
    final ruleName = rule.read('name').stringValue;
    final message = rule.peek('message')?.stringValue;
    final runOnNull = rule.peek('runOnNull')?.boolValue ?? false;
    final typeArg = typeArgOfBase(rule, 'AsyncCustomRule');

    final checkMethod = _findStaticCheck(typeElement);
    if (checkMethod == null) {
      throw InvalidGenerationSourceError(
        'AsyncCustomRule subclass must define a static check method: '
        'static FutureOr<bool> check(T? value, {required ...})',
        element: typeElement,
      );
    }

    _validateCheckFirstParam(checkMethod);
    _validateCheckReturnAsync(checkMethod);

    final config = <String, String>{};
    final paramNames = <String>[];
    final userFields = typeElement.fields
        .where((f) => f.enclosingElement == typeElement)
        .toList();
    final userFieldNames = userFields.map((f) => f.name).toSet();

    for (var i = 1; i < checkMethod.formalParameters.length; i++) {
      final p = checkMethod.formalParameters[i];
      if (!p.isNamed) {
        throw InvalidGenerationSourceError(
          'Config parameters of check(...) must be named',
          element: checkMethod,
        );
      }
      final pName = p.name!;
      if (!userFieldNames.contains(pName)) {
        throw InvalidGenerationSourceError(
          "No field '$pName' found on the rule class. "
          'Config parameters must match field names.',
          element: checkMethod,
        );
      }
      final fieldReader = rule.read(pName);
      config[pName] = literalForConstant(fieldReader);
      paramNames.add(pName);
    }

    return RuleInfo(
      'AsyncCustomRule',
      {
        'ruleName': ruleName,
        'className': typeElement.name!,
        'runOnNull': runOnNull,
        'config': config,
        'paramNames': paramNames,
      },
      message,
      isAsync: true,
      typeArg: typeArg,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    return 'false';
  }

  @override
  String? asyncCall(RuleInfo info, String fieldName) {
    final className = info.params['className'] as String;
    final config = (info.params['config'] as Map?)?.cast<String, String>() ??
        <String, String>{};
    final paramNames =
        (info.params['paramNames'] as List?)?.cast<String>() ?? <String>[];

    final args = StringBuffer();
    for (final name in paramNames) {
      args.write(', $name: ${config[name]}');
    }

    return '$className.check($fieldName$args)';
  }

  @override
  String defaultMessage(RuleInfo info, [String context = '']) {
    final ruleName = info.params['ruleName'] as String? ?? '';
    return '$ruleName: validation failed.';
  }

  @override
  void validateType(DartType? typeArg, FieldElement field) {}

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [String context = '']) {
    final ruleName = _errorRuleName(info);
    final message = info.message != null
        ? escapeDartString(info.message!)
        : escapeDartString(defaultMessage(info, context));
    return "_Errors.inline($pathExpr, '$ruleName', $message)";
  }

  @override
  Map<String, String> get helperMethods => {
        'inline':
            "static ValidationError inline(List<String> path, String rule, String message) =>\n"
                '      ValidationError(rule: rule, message: message, path: path);',
      };

  static String _errorRuleName(RuleInfo rule) {
    return (rule.params['ruleName'] as String?) ??
        (rule.params['customName'] as String?) ??
        rule.name;
  }

  static MethodElement? _findStaticCheck(ClassElement cls) {
    for (final method in cls.methods) {
      if (method.name == 'check' && method.isStatic) return method;
    }
    return null;
  }

  static void _validateCheckFirstParam(MethodElement method) {
    final params = method.formalParameters;
    if (params.isEmpty || params.first.isNamed) {
      throw InvalidGenerationSourceError(
        'The first parameter of check(...) must be a positional parameter '
        'accepting the value to validate.',
        element: method,
      );
    }
  }

  static void _validateCheckReturnAsync(MethodElement method) {
    final display = method.returnType.getDisplayString();
    if (!display.startsWith('Future<') &&
        !display.startsWith('FutureOr<') &&
        display != 'Future') {
      throw InvalidGenerationSourceError(
        'check(...) must return Future<bool> or FutureOr<bool>, '
        'got $display',
        element: method,
      );
    }
  }
}

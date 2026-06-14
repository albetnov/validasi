import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _snippets = FieldRuleSnippets();

String generateFieldsClass(
  String className,
  List<FieldRules> fields, {
  List<CrossFieldInfo> crossFields = const [],
}) {
  final buf = StringBuffer();
  final fieldsClassName = '${className}Fields';
  final leafClassNames = <String, String>{};

  final crossByField = <String, CrossFieldInfo>{};
  for (final cf in crossFields) {
    crossByField[cf.field.name!] = cf;
  }

  buf.writeln();
  buf.writeln(
      'sealed class $fieldsClassName<V> extends ValidasiKey<$className> implements ValidasiField<$className, V> {');
  buf.writeln('  const $fieldsClassName._();');
  buf.writeln();
  for (final ctx in fields) {
    final fieldName = ctx.field.name!;
    final leafName = '$className${_capitalize(fieldName)}Field';
    leafClassNames[fieldName] = leafName;
    final staticType = ctx.dartTypeDisplay;
    buf.writeln(
        '  static const $fieldsClassName<$staticType> $fieldName = $leafName();');
  }
  buf.writeln('}');
  buf.writeln();

  for (final ctx in fields) {
    final fieldName = ctx.field.name!;
    final leafName = leafClassNames[fieldName]!;
    final crossInfo = crossByField[fieldName];
    _emitLeaf(buf, className, fieldsClassName, leafName, fieldName, ctx,
        crossInfo: crossInfo);
    buf.writeln();
  }

  return buf.toString();
}

void _emitLeaf(
  StringBuffer buf,
  String className,
  String fieldsClassName,
  String leafName,
  String fieldName,
  FieldRules ctx, {
  CrossFieldInfo? crossInfo,
}) {
  final valueType = ctx.dartTypeDisplay;
  final typeArgForLeaf = valueType;

  buf.writeln('class $leafName extends $fieldsClassName<$typeArgForLeaf> {');
  buf.writeln('  const $leafName() : super._();');
  buf.writeln();
  buf.writeln("  @override String get name => '$fieldName';");
  buf.writeln();
  buf.writeln(
      '  @override $valueType extract($className owner) => owner.$fieldName;');

  if (ctx.isNested) {
    _emitNestedValidate(
        buf, className, fieldsClassName, leafName, valueType, ctx);
  } else {
    _emitLeafValidate(buf, fieldsClassName, valueType, ctx);
  }

  if (crossInfo != null) {
    _emitCrossFieldOverrides(buf, className, fieldsClassName, crossInfo);
  } else {
    _emitDefaultCrossFieldOverrides(buf, className);
  }

  buf.writeln('}');
}

void _emitDefaultCrossFieldOverrides(
  StringBuffer buf,
  String className,
) {
  buf.writeln();
  buf.writeln('  @override');
  buf.writeln('  CrossFieldKey<$className>? get crossFieldKey => null;');
  buf.writeln();
  buf.writeln('  @override');
  buf.writeln('  List<ValidationError> Function(');
  buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
  buf.writeln('  )? get crossValidator => null;');
  buf.writeln();
  buf.writeln('  @override');
  buf.writeln('  Future<List<ValidationError>> Function(');
  buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
  buf.writeln('  )? get crossValidatorAsync => null;');
  buf.writeln();
  buf.writeln('  @override');
  buf.writeln('  Set<ValidasiField<$className, dynamic>> get crossDependsOn =>'
      ' const <ValidasiField<$className, dynamic>>{};');
}

void _emitCrossFieldOverrides(
  StringBuffer buf,
  String className,
  String fieldsClassName,
  CrossFieldInfo crossInfo,
) {
  final crossClassName = '${className}CrossFields';
  final validatorFunc = crossInfo.functionName;
  final ruleName = crossInfo.isAsync ? 'ValidateWithAsync' : 'ValidateWith';

  buf.writeln();
  buf.writeln('  @override');
  buf.writeln(
      '  CrossFieldKey<$className> get crossFieldKey => $crossClassName.${crossInfo.field.name};');
  buf.writeln();
  buf.writeln('  @override');
  buf.writeln('  Set<ValidasiField<$className, dynamic>> get crossDependsOn {');
  if (crossInfo.dependsOn.isEmpty) {
    buf.writeln('    return const <ValidasiField<$className, dynamic>>{};');
  } else {
    buf.write('    return const <ValidasiField<$className, dynamic>>{');
    final deps =
        crossInfo.dependsOn.map((d) => '$fieldsClassName.$d').join(', ');
    buf.writeln('$deps};');
  }
  buf.writeln('  }');

  if (crossInfo.isAsync) {
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln('  List<ValidationError> Function(');
    buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
    buf.writeln('  )? get crossValidator => null;');
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln('  Future<List<ValidationError>> Function(');
    buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
    buf.writeln('  ) get crossValidatorAsync {');
    buf.writeln('    return (getField) async {');
    buf.writeln('      final result = await $validatorFunc(getField);');
    buf.writeln('      if (result != null) {');
    buf.writeln(
        "        return [ValidationError(rule: '$ruleName', message: result, path: ['${crossInfo.field.name}'])];");
    buf.writeln('      }');
    buf.writeln('      return [];');
    buf.writeln('    };');
    buf.writeln('  }');
  } else {
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln('  List<ValidationError> Function(');
    buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
    buf.writeln('  ) get crossValidator {');
    buf.writeln('    return (getField) {');
    buf.writeln('      final result = $validatorFunc(getField);');
    buf.writeln('      if (result != null) {');
    buf.writeln(
        "        return [ValidationError(rule: '$ruleName', message: result, path: ['${crossInfo.field.name}'])];");
    buf.writeln('      }');
    buf.writeln('      return [];');
    buf.writeln('    };');
    buf.writeln('  }');
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln('  Future<List<ValidationError>> Function(');
    buf.writeln('    V? Function<V>(ValidasiField<$className, V>)');
    buf.writeln('  )? get crossValidatorAsync => null;');
  }
}

String _nullableParam(String type) {
  if (type.endsWith('?')) return type;
  return '$type?';
}

void _emitLeafValidate(
  StringBuffer buf,
  String fieldsClassName,
  String valueType,
  FieldRules ctx,
) {
  if (ctx.hasAsyncRule) {
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln(
        '  ValidasiResult<$valueType> validate(${_nullableParam(valueType)} value) {');
    buf.writeln(
        "    throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');");
    buf.writeln('  }');
  } else {
    buf.writeln();
    buf.writeln('  @override');
    buf.writeln(
        '  ValidasiResult<$valueType> validate(${_nullableParam(valueType)} value) {');
    buf.writeln('    final \$errors = <ValidationError>[];');
    _snippets.emitInline(
      buf,
      ctx,
      indent: '    ',
      accessor: 'value',
      pathExpr: '[name]',
    );
    buf.writeln('    if (\$errors.isNotEmpty) {');
    buf.writeln(
        '      return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
    buf.writeln('  }');
  }

  buf.writeln();
  buf.writeln('  @override');
  if (ctx.hasAsyncRule) {
    buf.writeln(
        '  Future<ValidasiResult<$valueType>> validateAsync(${_nullableParam(valueType)} value) async {');
    buf.writeln('    final \$errors = <ValidationError>[];');
    _snippets.emitInline(
      buf,
      ctx,
      indent: '    ',
      accessor: 'value',
      pathExpr: '[name]',
      async: true,
    );
    buf.writeln('    if (\$errors.isNotEmpty) {');
    buf.writeln(
        '      return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
    buf.writeln('  }');
  } else {
    buf.writeln(
        '  Future<ValidasiResult<$valueType>> validateAsync(${_nullableParam(valueType)} value) async {');
    buf.writeln('    return validate(value);');
    buf.writeln('  }');
  }
}

void _emitNestedValidate(
  StringBuffer buf,
  String className,
  String fieldsClassName,
  String leafName,
  String valueType,
  FieldRules ctx,
) {
  final isIterable = ctx.isNestedIterable;
  final indexVar = '\$${ctx.field.name}Index';
  final itemVar = '\$${ctx.field.name}Item';
  final resultVar = '\$${ctx.field.name}Result';

  buf.writeln();
  buf.writeln('  @override');
  buf.writeln(
      '  ValidasiResult<$valueType> validate(${_nullableParam(valueType)} value) {');
  buf.writeln('    if (value == null) {');
  buf.writeln('      return const ValidasiResult(errors: [], isValid: true);');
  buf.writeln('    }');

  if (!isIterable) {
    buf.writeln('    final $resultVar = value.validate();');
    buf.writeln('    if (!$resultVar.isValid) {');
    buf.writeln('      return ValidasiResult(');
    buf.writeln(
        '        errors: $resultVar.errors.map((e) => e.withPrefix(name)).toList(),');
    buf.writeln('        isValid: false,');
    buf.writeln('      );');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
  } else {
    buf.writeln('    final \$errors = <ValidationError>[];');
    buf.writeln(
        '    for (var $indexVar = 0; $indexVar < value.length; $indexVar++) {');
    buf.writeln('      final $itemVar = value[$indexVar];');
    buf.writeln('      final $resultVar = $itemVar.validate();');
    buf.writeln('      if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix("\$name[\${$indexVar}]")));');
    buf.writeln('      }');
    buf.writeln('    }');
    buf.writeln('    if (\$errors.isNotEmpty) {');
    buf.writeln(
        '      return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
  }

  buf.writeln('  }');

  buf.writeln();
  buf.writeln('  @override');
  buf.writeln(
      '  Future<ValidasiResult<$valueType>> validateAsync(${_nullableParam(valueType)} value) async {');
  buf.writeln('    if (value == null) {');
  buf.writeln('      return const ValidasiResult(errors: [], isValid: true);');
  buf.writeln('    }');

  if (!isIterable) {
    buf.writeln('    final $resultVar = await value.validateAsync();');
    buf.writeln('    if (!$resultVar.isValid) {');
    buf.writeln('      return ValidasiResult(');
    buf.writeln(
        '        errors: $resultVar.errors.map((e) => e.withPrefix(name)).toList(),');
    buf.writeln('        isValid: false,');
    buf.writeln('      );');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
  } else {
    buf.writeln('    final \$errors = <ValidationError>[];');
    buf.writeln(
        '    for (var $indexVar = 0; $indexVar < value.length; $indexVar++) {');
    buf.writeln('      final $itemVar = value[$indexVar];');
    buf.writeln('      final $resultVar = await $itemVar.validateAsync();');
    buf.writeln('      if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix("\$name[\${$indexVar}]")));');
    buf.writeln('      }');
    buf.writeln('    }');
    buf.writeln('    if (\$errors.isNotEmpty) {');
    buf.writeln(
        '      return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: value);');
  }

  buf.writeln('  }');
}

String _capitalize(String name) {
  if (name.isEmpty) return name;
  return name[0].toUpperCase() + name.substring(1);
}

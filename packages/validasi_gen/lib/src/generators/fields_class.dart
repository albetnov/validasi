import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _snippets = FieldRuleSnippets();

String generateFieldsClass(String className, List<FieldRules> fields) {
  final buf = StringBuffer();
  final fieldsClassName = '${className}Fields';
  final leafClassNames = <String, String>{};

  buf.writeln();
  buf.writeln(
      'sealed class $fieldsClassName<V> extends ValidasiKey<$className> {');
  buf.writeln('  const $fieldsClassName._();');
  buf.writeln();
  buf.writeln('  String get name;');
  buf.writeln('  V? extract($className owner);');
  buf.writeln('  ValidasiResult<V> validate(V? value);');
  buf.writeln();
  for (final ctx in fields) {
    final fieldName = ctx.field.name;
    final leafName = '$className${_capitalize(fieldName)}Field';
    leafClassNames[fieldName] = leafName;
    final staticType = ctx.dartTypeDisplay;
    buf.writeln(
        '  static const $fieldsClassName<$staticType> $fieldName = $leafName();');
  }
  buf.writeln('}');
  buf.writeln();

  for (final ctx in fields) {
    final fieldName = ctx.field.name;
    final leafName = leafClassNames[fieldName]!;
    _emitLeaf(buf, className, fieldsClassName, leafName, fieldName, ctx);
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
  FieldRules ctx,
) {
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

  buf.writeln('}');
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
  buf.writeln('      return ValidasiResult(errors: \$errors, isValid: false);');
  buf.writeln('    }');
  buf.writeln(
      '    return ValidasiResult(errors: const [], isValid: true, data: value);');
  buf.writeln('  }');
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
}

String _capitalize(String name) {
  if (name.isEmpty) return name;
  return name[0].toUpperCase() + name.substring(1);
}

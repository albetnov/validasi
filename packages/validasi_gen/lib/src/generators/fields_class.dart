import 'package:code_builder/code_builder.dart';
import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _snippets = FieldRuleSnippets();

DartEmitter get _emitter => DartEmitter(allocator: Allocator.none);

String generateFieldsClass(
  String className,
  List<FieldRules> fields, {
  bool generateIndexedFields = false,
}) {
  final fieldsClassName = '${className}Fields';
  final leafClassNames = <String, String>{};

  final sealedClass = Class((c) {
    c.sealed = true;
    c.name = fieldsClassName;
    c.types.add(refer('V'));
    c.extend = refer('ValidasiKey<$className>');
    c.implements.add(refer('ValidasiField<$className, V>'));
    c.constructors.add(Constructor((con) {
      con.name = '_';
      con.constant = true;
    }));

    for (final ctx in fields) {
      final fieldName = ctx.field.name!;
      final leafName = '$className${_capitalize(fieldName)}Field';
      leafClassNames[fieldName] = leafName;
      final staticType = ctx.dartTypeDisplay;
      c.fields.add(Field((f) {
        f.name = fieldName;
        f.modifier = FieldModifier.constant;
        f.static = true;
        f.type = refer('$fieldsClassName<$staticType>');
        f.assignment = refer(leafName).call([]).code;
      }));
    }

    if (generateIndexedFields) {
      c.methods.add(_buildIndexedFieldsMethod(
          className, fieldsClassName, fields, leafClassNames));
      c.methods.add(_buildReconstructItemMethod(
          className, fieldsClassName, fields, leafClassNames));
      c.methods.add(_buildReconstructAllMethod(
          className, fieldsClassName, fields, leafClassNames));
    }
  });

  final buf = StringBuffer();
  buf.writeln();
  buf.write(sealedClass.accept(_emitter));
  buf.writeln();

  for (final ctx in fields) {
    final fieldName = ctx.field.name!;
    final leafName = leafClassNames[fieldName]!;
    buf.write(_buildLeafClass(
      className,
      fieldsClassName,
      leafName,
      fieldName,
      ctx,
    ));
    buf.writeln();
  }

  return buf.toString();
}

String _buildLeafClass(
  String className,
  String fieldsClassName,
  String leafName,
  String fieldName,
  FieldRules ctx,
) {
  final valueType = ctx.dartTypeDisplay;

  final leafClass = Class((c) {
    c.name = leafName;
    c.extend = refer('$fieldsClassName<$valueType>');
    c.constructors.add(Constructor((con) {
      con.constant = true;
      con.initializers.add(Code('super._()'));
    }));

    c.methods.add(Method((m) {
      m.name = 'name';
      m.type = MethodType.getter;
      m.returns = refer('String');
      m.annotations.add(refer('override'));
      m.body = Code("return '$fieldName';");
    }));

    c.methods.add(Method((m) {
      m.name = 'extract';
      m.returns = refer(valueType);
      m.annotations.add(refer('override'));
      m.requiredParameters.add(Parameter((p) {
        p.name = 'owner';
        p.type = refer(className);
      }));
      m.body = Code('return owner.$fieldName;');
    }));

    if (ctx.isNested) {
      _addNestedValidate(c, valueType, ctx);
    } else {
      _addLeafValidate(c, valueType, ctx);
    }
  });

  return leafClass.accept(_emitter).toString();
}

void _addLeafValidate(ClassBuilder c, String valueType, FieldRules ctx) {
  final nullableType = valueType.endsWith('?') ? valueType : '$valueType?';

  if (ctx.hasAsyncRule) {
    c.methods.add(Method((m) {
      m.name = 'validate';
      m.returns = refer('ValidasiResult<$valueType>');
      m.annotations.add(refer('override'));
      m.requiredParameters.add(Parameter((p) {
        p.name = 'value';
        p.type = refer(nullableType);
      }));
      m.body = Code(
          "throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');");
    }));
  } else {
    final buf = StringBuffer();
    buf.writeln('final \$errors = <ValidationError>[];');
    final innerBuf = StringBuffer();
    _snippets.emitInline(innerBuf, ctx,
        indent: '', accessor: 'value', pathExpr: '[name]');
    buf.write(innerBuf);
    buf.writeln('if (\$errors.isNotEmpty) {');
    buf.writeln('return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('}');
    buf.writeln(
        'return ValidasiResult(errors: const [], isValid: true, data: value);');

    c.methods.add(Method((m) {
      m.name = 'validate';
      m.returns = refer('ValidasiResult<$valueType>');
      m.annotations.add(refer('override'));
      m.requiredParameters.add(Parameter((p) {
        p.name = 'value';
        p.type = refer(nullableType);
      }));
      m.body = Code(buf.toString());
    }));
  }

  final asyncBuf = StringBuffer();
  if (ctx.hasAsyncRule) {
    asyncBuf.writeln('final \$errors = <ValidationError>[];');
    final innerBuf = StringBuffer();
    _snippets.emitInline(innerBuf, ctx,
        indent: '', accessor: 'value', pathExpr: '[name]', async: true);
    asyncBuf.write(innerBuf);
    asyncBuf.writeln('if (\$errors.isNotEmpty) {');
    asyncBuf
        .writeln('return ValidasiResult(errors: \$errors, isValid: false);');
    asyncBuf.writeln('}');
    asyncBuf.writeln(
        'return ValidasiResult(errors: const [], isValid: true, data: value);');
  } else {
    asyncBuf.writeln('return validate(value);');
  }

  c.methods.add(Method((m) {
    m.name = 'validateAsync';
    m.modifier = MethodModifier.async;
    m.returns = refer('Future<ValidasiResult<$valueType>>');
    m.annotations.add(refer('override'));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'value';
      p.type = refer(nullableType);
    }));
    m.body = Code(asyncBuf.toString());
  }));
}

void _addNestedValidate(ClassBuilder c, String valueType, FieldRules ctx) {
  final isIterable = ctx.isNestedIterable;
  final nullableType = valueType.endsWith('?') ? valueType : '$valueType?';
  final fieldName = ctx.field.name!;
  final indexVar = '\$${fieldName}Index';
  final itemVar = '\$${fieldName}Item';
  final resultVar = '\$${fieldName}Result';

  // Add both validate and validateAsync using a shared body builder
  c.methods.add(_buildNestedMethod(
    'validate',
    'ValidasiResult<$valueType>',
    nullableType,
    isIterable,
    indexVar,
    itemVar,
    resultVar,
    fieldName,
    isAsync: false,
  ));
  c.methods.add(_buildNestedMethod(
    'validateAsync',
    'Future<ValidasiResult<$valueType>>',
    nullableType,
    isIterable,
    indexVar,
    itemVar,
    resultVar,
    fieldName,
    isAsync: true,
  ));
}

Method _buildNestedMethod(
  String methodName,
  String returnType,
  String nullableType,
  bool isIterable,
  String indexVar,
  String itemVar,
  String resultVar,
  String fieldName, {
  required bool isAsync,
}) {
  final validateMethod = isAsync ? 'validateAsync' : 'validate';
  final awaitKw = isAsync ? 'await ' : '';

  final buf = StringBuffer();
  buf.writeln('if (value == null) {');
  buf.writeln('return const ValidasiResult(errors: [], isValid: true);');
  buf.writeln('}');

  if (!isIterable) {
    buf.writeln('final $resultVar = ${awaitKw}value.$validateMethod();');
    buf.writeln('if (!$resultVar.isValid) {');
    buf.writeln('return ValidasiResult(');
    buf.writeln(
        'errors: $resultVar.errors.map((e) => e..prefix(name)).toList(),');
    buf.writeln('isValid: false,');
    buf.writeln(');');
    buf.writeln('}');
    buf.writeln(
        'return ValidasiResult(errors: const [], isValid: true, data: value);');
  } else {
    buf.writeln('final \$errors = <ValidationError>[];');
    buf.writeln(
        'for (var $indexVar = 0; $indexVar < value.length; $indexVar++) {');
    buf.writeln('final $itemVar = value[$indexVar];');
    buf.writeln('final $resultVar = $awaitKw$itemVar.$validateMethod();');
    buf.writeln('if (!$resultVar.isValid) {');
    buf.writeln(
        '\$errors.addAll($resultVar.errors.map((e) => e..prefix("\$name[\${$indexVar}]")));');
    buf.writeln('}');
    buf.writeln('}');
    buf.writeln('if (\$errors.isNotEmpty) {');
    buf.writeln('return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('}');
    buf.writeln(
        'return ValidasiResult(errors: const [], isValid: true, data: value);');
  }

  return Method((m) {
    m.name = methodName;
    if (isAsync) m.modifier = MethodModifier.async;
    m.returns = refer(returnType);
    m.annotations.add(refer('override'));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'value';
      p.type = refer(nullableType);
    }));
    m.body = Code(buf.toString());
  });
}

Method _buildIndexedFieldsMethod(
  String className,
  String fieldsClassName,
  List<FieldRules> fields,
  Map<String, String> leafClassNames,
) {
  final entries = <String>[];
  for (final ctx in fields) {
    final fieldName = ctx.field.name!;
    final leafName = leafClassNames[fieldName]!;
    final valueType = ctx.dartTypeDisplay;
    entries.add(
      'IndexedField<FormType, $valueType>(\n'
      '        fieldName: \'$fieldName\',\n'
      '        parentPath: parentPath,\n'
      '        index: index,\n'
      '        validate: (v) => $leafName().validate(v),\n'
      '        validateAsync: (v) => $leafName().validateAsync(v),\n'
      '        extractFromItem: (item) => (item as $className).$fieldName,\n'
      '      )',
    );
  }

  final body = StringBuffer();
  body.writeln('return <ValidasiField<FormType, dynamic>>[');
  for (var i = 0; i < entries.length; i++) {
    body.write(entries[i]);
    if (i < entries.length - 1) {
      body.writeln(',');
    } else {
      body.writeln();
    }
  }
  body.writeln('];');

  return Method((m) {
    m.name = 'indexedFields';
    m.static = true;
    m.types.add(refer('FormType'));
    m.returns = refer('List<ValidasiField<FormType, dynamic>>');
    m.requiredParameters.add(Parameter((p) {
      p.name = 'parentPath';
      p.type = refer('String');
    }));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'index';
      p.type = refer('int');
    }));
    m.body = Code(body.toString());
  });
}

Method _buildReconstructItemMethod(
  String className,
  String fieldsClassName,
  List<FieldRules> fields,
  Map<String, String> leafClassNames,
) {
  final constructorArgs = <String>[];
  for (final ctx in fields) {
    final fieldName = ctx.field.name!;
    final valueType = ctx.dartTypeDisplay;
    final isNullable = valueType.endsWith('?');
    constructorArgs.add(
      '$fieldName: ctrl.getValue('
      'ctrl.getArraySubField(field, index, \'$fieldName\'))'
      '${isNullable ? '' : ' as $valueType'}',
    );
  }

  final body = StringBuffer();
  body.writeln('return $className(');
  for (var i = 0; i < constructorArgs.length; i++) {
    body.write('      ${constructorArgs[i]}');
    if (i < constructorArgs.length - 1) {
      body.writeln(',');
    } else {
      body.writeln();
    }
  }
  body.write('    );');

  return Method((m) {
    m.name = 'reconstructItem';
    m.static = true;
    m.types.add(refer('FormType'));
    m.returns = refer(className);
    m.requiredParameters.add(Parameter((p) {
      p.name = 'ctrl';
      p.type = refer('ValidasiFormController<FormType>');
    }));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'field';
      p.type = refer('ValidasiField<FormType, List<$className>>');
    }));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'index';
      p.type = refer('int');
    }));
    m.body = Code(body.toString());
  });
}

Method _buildReconstructAllMethod(
  String className,
  String fieldsClassName,
  List<FieldRules> fields,
  Map<String, String> leafClassNames,
) {
  final body = StringBuffer();
  body.writeln('final count = ctrl.getArrayItemCount(field);');
  body.writeln(
      'return List.generate(count, (i) => reconstructItem(ctrl, field, i));');

  return Method((m) {
    m.name = 'reconstructAll';
    m.static = true;
    m.types.add(refer('FormType'));
    m.returns = refer('List<$className>');
    m.requiredParameters.add(Parameter((p) {
      p.name = 'ctrl';
      p.type = refer('ValidasiFormController<FormType>');
    }));
    m.requiredParameters.add(Parameter((p) {
      p.name = 'field';
      p.type = refer('ValidasiField<FormType, List<$className>>');
    }));
    m.body = Code(body.toString());
  });
}

String _capitalize(String name) {
  if (name.isEmpty) return name;
  return name[0].toUpperCase() + name.substring(1);
}

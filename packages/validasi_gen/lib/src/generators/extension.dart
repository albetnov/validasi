import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _snippets = FieldRuleSnippets();

String generateValidateExtension(
  String className,
  List<FieldRules> fields, {
  List<CrossFieldInfo> crossFields = const [],
  bool includeValidateField = true,
}) {
  final buf = StringBuffer();
  final fieldsClassName = '${className}Fields';
  final classHasAsync =
      fields.any((f) => f.hasAsyncRule) || crossFields.any((c) => c.isAsync);

  buf.writeln();
  buf.writeln('extension \$${className}Validasi on $className {');
  buf.writeln('  ValidasiResult<$className> validate() {');
  if (classHasAsync) {
    buf.writeln(
        "    throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');");
  } else {
    buf.writeln("    final \$errors = <ValidationError>[];");
    buf.writeln();

    for (final ctx in fields) {
      _generateFieldValidation(buf, ctx);
    }

    _emitSyncCrossValidators(buf, className, fieldsClassName, crossFields);

    buf.writeln("    if (\$errors.isNotEmpty) {");
    buf.writeln(
        "      return ValidasiResult(errors: \$errors, isValid: false);");
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: const [], isValid: true, data: this);');
  }
  buf.writeln('  }');

  buf.writeln();
  buf.writeln('  Future<ValidasiResult<$className>> validateAsync() async {');
  buf.writeln("    final \$errors = <ValidationError>[];");
  buf.writeln();

  for (final ctx in fields) {
    _generateFieldValidationAsync(buf, ctx);
  }

  _emitAsyncCrossValidators(buf, className, fieldsClassName, crossFields);

  buf.writeln("    if (\$errors.isNotEmpty) {");
  buf.writeln("      return ValidasiResult(errors: \$errors, isValid: false);");
  buf.writeln('    }');
  buf.writeln(
      '    return ValidasiResult(errors: const [], isValid: true, data: this);');
  buf.writeln('  }');

  if (includeValidateField) {
    buf.writeln();
    buf.writeln(
        '  ValidasiResult<V> validateField<V>($fieldsClassName<V> field) {');
    buf.writeln('    return field.validate(field.extract(this));');
    buf.writeln('  }');
    buf.writeln();
    buf.writeln(
        '  Future<ValidasiResult<V>> validateFieldAsync<V>($fieldsClassName<V> field) async {');
    buf.writeln('    return field.validateAsync(field.extract(this));');
    buf.writeln('  }');
  }

  buf.writeln('}');

  return buf.toString();
}

void _emitSyncCrossValidators(
  StringBuffer buf,
  String className,
  String fieldsClassName,
  List<CrossFieldInfo> crossFields,
) {
  if (crossFields.isEmpty) return;
  final syncFields = crossFields.where((c) => !c.isAsync).toList();
  if (syncFields.isEmpty) return;

  buf.writeln('    // Cross-field validators');
  buf.writeln(
      '    V? getField<V>(ValidasiField<$className, V> field) => field.extract(this);');
  for (final cf in syncFields) {
    final fieldName = cf.field.name!;
    buf.writeln('    {');
    buf.writeln(
        '      final field = $fieldsClassName.$fieldName as ValidasiField<$className, dynamic>;');
    buf.writeln('      final cv = field.crossValidator;');
    buf.writeln('      if (cv != null) {');
    buf.writeln('        \$errors.addAll(cv(getField));');
    buf.writeln('      }');
    buf.writeln('    }');
  }
  buf.writeln();
}

void _emitAsyncCrossValidators(
  StringBuffer buf,
  String className,
  String fieldsClassName,
  List<CrossFieldInfo> crossFields,
) {
  if (crossFields.isEmpty) return;
  final asyncFields = crossFields.where((c) => c.isAsync).toList();
  final syncFields = crossFields.where((c) => !c.isAsync).toList();
  if (asyncFields.isEmpty && syncFields.isEmpty) return;

  buf.writeln('    // Cross-field validators');
  buf.writeln(
      '    V? getField<V>(ValidasiField<$className, V> field) => field.extract(this);');
  for (final cf in syncFields) {
    final fieldName = cf.field.name!;
    buf.writeln('    {');
    buf.writeln(
        '      final field = $fieldsClassName.$fieldName as ValidasiField<$className, dynamic>;');
    buf.writeln('      final cv = field.crossValidator;');
    buf.writeln('      if (cv != null) {');
    buf.writeln('        \$errors.addAll(cv(getField));');
    buf.writeln('      }');
    buf.writeln('    }');
  }
  for (final cf in asyncFields) {
    final fieldName = cf.field.name!;
    buf.writeln('    {');
    buf.writeln(
        '      final field = $fieldsClassName.$fieldName as ValidasiField<$className, dynamic>;');
    buf.writeln('      final cv = field.crossValidatorAsync;');
    buf.writeln('      if (cv != null) {');
    buf.writeln('        \$errors.addAll(await cv(getField));');
    buf.writeln('      }');
    buf.writeln('    }');
  }
  buf.writeln();
}

void _generateFieldValidation(StringBuffer buf, FieldRules ctx) {
  if (ctx.isNested) {
    _generateNestedValidation(buf, ctx);
    return;
  }

  if (ctx.hasAsyncRule) {
    return;
  }

  final fieldName = ctx.field.name!;
  buf.writeln('    // Field: $fieldName');
  _snippets.emitInline(
    buf,
    ctx,
    indent: '    ',
    accessor: fieldName,
    pathExpr: "['$fieldName']",
  );
  buf.writeln();
}

void _generateFieldValidationAsync(StringBuffer buf, FieldRules ctx) {
  if (ctx.isNested) {
    _generateNestedValidationAsync(buf, ctx);
    return;
  }

  final fieldName = ctx.field.name!;
  buf.writeln('    // Field: $fieldName');
  _snippets.emitInline(
    buf,
    ctx,
    indent: '    ',
    accessor: fieldName,
    pathExpr: "['$fieldName']",
    async: true,
  );
  buf.writeln();
}

void _generateNestedValidation(StringBuffer buf, FieldRules ctx) {
  final fieldName = ctx.field.name!;
  final nestedClassName = ctx.nestedClassName!;
  final isIterable = ctx.isNestedIterable;
  final isNullable = ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;

  buf.writeln('    // Field: $fieldName (nested $nestedClassName)');

  if (isIterable) {
    _generateNestedIterableValidation(
        buf, fieldName, nestedClassName, isNullable);
  } else {
    _generateNestedObjectValidation(
        buf, fieldName, nestedClassName, isNullable);
  }

  buf.writeln();
}

void _generateNestedValidationAsync(StringBuffer buf, FieldRules ctx) {
  final fieldName = ctx.field.name!;
  final nestedClassName = ctx.nestedClassName!;
  final isIterable = ctx.isNestedIterable;
  final isNullable = ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;

  buf.writeln('    // Field: $fieldName (nested $nestedClassName)');

  if (isIterable) {
    _generateNestedIterableValidationAsync(
        buf, fieldName, nestedClassName, isNullable);
  } else {
    _generateNestedObjectValidationAsync(
        buf, fieldName, nestedClassName, isNullable);
  }

  buf.writeln();
}

void _generateNestedObjectValidation(StringBuffer buf, String fieldName,
    String nestedClassName, bool isNullable) {
  final resultVar = '\$${fieldName}Result';

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    buf.writeln('      final $resultVar = $localVar.validate();');
    buf.writeln('      if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('      }');
    buf.writeln('    }');
  } else {
    buf.writeln('    final $resultVar = $fieldName.validate();');
    buf.writeln('    if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('    }');
  }
}

void _generateNestedObjectValidationAsync(StringBuffer buf, String fieldName,
    String nestedClassName, bool isNullable) {
  final resultVar = '\$${fieldName}Result';

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    buf.writeln('      final $resultVar = await $localVar.validateAsync();');
    buf.writeln('      if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('      }');
    buf.writeln('    }');
  } else {
    buf.writeln('    final $resultVar = await $fieldName.validateAsync();');
    buf.writeln('    if (!$resultVar.isValid) {');
    buf.writeln(
        '        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('    }');
  }
}

void _generateNestedIterableValidation(StringBuffer buf, String fieldName,
    String nestedClassName, bool isNullable) {
  final indexVar = '\$${fieldName}Index';
  final itemVar = '\$${fieldName}Item';
  final resultVar = '\$${fieldName}ItemResult';

  void generateBody(String indent, String collectionName) {
    buf.writeln(
        '${indent}for (var $indexVar = 0; $indexVar < $collectionName.length; $indexVar++) {');
    buf.writeln('$indent  final $itemVar = $collectionName[$indexVar];');
    buf.writeln('$indent  final $resultVar = $itemVar.validate();');
    buf.writeln('$indent  if (!$resultVar.isValid) {');
    buf.writeln(
        '$indent    \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName[\${$indexVar}]\')));');
    buf.writeln('$indent  }');
    buf.writeln('$indent}');
  }

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    generateBody('      ', localVar);
    buf.writeln('    }');
  } else {
    generateBody('    ', fieldName);
  }
}

void _generateNestedIterableValidationAsync(StringBuffer buf, String fieldName,
    String nestedClassName, bool isNullable) {
  final indexVar = '\$${fieldName}Index';
  final itemVar = '\$${fieldName}Item';
  final resultVar = '\$${fieldName}ItemResult';

  void generateBody(String indent, String collectionName) {
    buf.writeln(
        '${indent}for (var $indexVar = 0; $indexVar < $collectionName.length; $indexVar++) {');
    buf.writeln('$indent  final $itemVar = $collectionName[$indexVar];');
    buf.writeln('$indent  final $resultVar = await $itemVar.validateAsync();');
    buf.writeln('$indent  if (!$resultVar.isValid) {');
    buf.writeln(
        '$indent    \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName[\${$indexVar}]\')));');
    buf.writeln('$indent  }');
    buf.writeln('$indent}');
  }

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    generateBody('      ', localVar);
    buf.writeln('    }');
  } else {
    generateBody('    ', fieldName);
  }
}

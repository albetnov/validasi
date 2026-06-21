import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _snippets = FieldRuleSnippets();

DartEmitter get _emitter => DartEmitter(allocator: Allocator.none);

String generateValidateExtension(
  String className,
  List<FieldRules> fields, {
  bool includeValidateField = true,
}) {
  final fieldsClassName = '${className}Fields';
  final classHasAsync = fields.any((f) => f.hasAsyncRule);

  final ext = Extension((e) {
    e.name = '\$${className}Validasi';
    e.on = refer(className);

    e.methods.add(Method((m) {
      m.name = 'validate';
      m.returns = refer('ValidasiResult<$className>');

      if (classHasAsync) {
        m.body = Code(
            "throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');");
      } else {
        final buf = StringBuffer();
        buf.writeln('final \$errors = <ValidationError>[];');
        for (final ctx in fields) {
          _generateFieldBody(buf, ctx, isAsync: false);
        }
        buf.writeln('if (\$errors.isNotEmpty) {');
        buf.writeln('return ValidasiResult(errors: \$errors, isValid: false);');
        buf.writeln('}');
        buf.writeln(
            'return ValidasiResult(errors: const [], isValid: true, data: this);');
        m.body = Code(buf.toString());
      }
    }));

    e.methods.add(Method((m) {
      m.name = 'validateAsync';
      m.modifier = MethodModifier.async;
      m.returns = refer('Future<ValidasiResult<$className>>');

      final buf = StringBuffer();
      buf.writeln('final \$errors = <ValidationError>[];');
      for (final ctx in fields) {
        _generateFieldBody(buf, ctx, isAsync: true);
      }
      buf.writeln('if (\$errors.isNotEmpty) {');
      buf.writeln('return ValidasiResult(errors: \$errors, isValid: false);');
      buf.writeln('}');
      buf.writeln(
          'return ValidasiResult(errors: const [], isValid: true, data: this);');
      m.body = Code(buf.toString());
    }));

    if (includeValidateField) {
      e.methods.add(Method((m) {
        m.name = 'validateField';
        m.returns = refer('ValidasiResult<V>');
        m.types.add(refer('V'));
        m.requiredParameters.add(Parameter((p) {
          p.name = 'field';
          p.type = refer('$fieldsClassName<V>');
        }));
        m.body = Code('return field.validate(field.extract(this));');
      }));

      e.methods.add(Method((m) {
        m.name = 'validateFieldAsync';
        m.modifier = MethodModifier.async;
        m.returns = refer('Future<ValidasiResult<V>>');
        m.types.add(refer('V'));
        m.requiredParameters.add(Parameter((p) {
          p.name = 'field';
          p.type = refer('$fieldsClassName<V>');
        }));
        m.body = Code('return field.validateAsync(field.extract(this));');
      }));
    }
  });

  final buf = StringBuffer();
  buf.writeln();
  buf.write(ext.accept(_emitter));
  return buf.toString();
}

void _generateFieldBody(
  StringBuffer buf,
  FieldRules ctx, {
  required bool isAsync,
}) {
  if (ctx.isNested) {
    _generateNestedBody(buf, ctx, isAsync: isAsync);
    return;
  }

  if (!isAsync && ctx.hasAsyncRule) {
    return;
  }

  final fieldName = ctx.field.name!;
  buf.writeln('// Field: $fieldName');
  _snippets.emitInline(
    buf,
    ctx,
    indent: '',
    accessor: fieldName,
    pathExpr: "['$fieldName']",
    async: isAsync,
  );
}

void _generateNestedBody(
  StringBuffer buf,
  FieldRules ctx, {
  required bool isAsync,
}) {
  final fieldName = ctx.field.name!;
  final nestedClassName = ctx.nestedClassName!;
  final isIterable = ctx.isNestedIterable;
  final isNullable = ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;

  buf.writeln('// Field: $fieldName (nested $nestedClassName)');

  if (isIterable) {
    _generateNestedIterableBody(
      buf,
      fieldName,
      nestedClassName,
      isNullable,
      isAsync: isAsync,
    );
  } else {
    _generateNestedObjectBody(
      buf,
      fieldName,
      nestedClassName,
      isNullable,
      isAsync: isAsync,
    );
  }
}

void _generateNestedObjectBody(
  StringBuffer buf,
  String fieldName,
  String nestedClassName,
  bool isNullable, {
  required bool isAsync,
}) {
  final resultVar = '\$${fieldName}Result';

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    final validateCall =
        isAsync ? 'await $localVar.validateAsync()' : '$localVar.validate()';
    buf.writeln('final $localVar = $fieldName;');
    buf.writeln('if ($localVar != null) {');
    buf.writeln('final $resultVar = $validateCall;');
    buf.writeln('if (!$resultVar.isValid) {');
    buf.writeln(
        '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName\')));');
    buf.writeln('}');
    buf.writeln('}');
  } else {
    final validateCall =
        isAsync ? 'await $fieldName.validateAsync()' : '$fieldName.validate()';
    buf.writeln('final $resultVar = $validateCall;');
    buf.writeln('if (!$resultVar.isValid) {');
    buf.writeln(
        '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName\')));');
    buf.writeln('}');
  }
}

void _generateNestedIterableBody(
  StringBuffer buf,
  String fieldName,
  String nestedClassName,
  bool isNullable, {
  required bool isAsync,
}) {
  final indexVar = '\$${fieldName}Index';
  final itemVar = '\$${fieldName}Item';
  final resultVar = '\$${fieldName}ItemResult';
  final validateSuffix = isAsync ? 'validateAsync()' : 'validate()';
  final awaitPrefix = isAsync ? 'await ' : '';

  void generateBody(String collectionName) {
    buf.writeln(
        'for (var $indexVar = 0; $indexVar < $collectionName.length; $indexVar++) {');
    buf.writeln('final $itemVar = $collectionName[$indexVar];');
    buf.writeln('final $resultVar = $awaitPrefix$itemVar.$validateSuffix;');
    buf.writeln('if (!$resultVar.isValid) {');
    buf.writeln(
        '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName[\${$indexVar}]\')));');
    buf.writeln('}');
    buf.writeln('}');
  }

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('final $localVar = $fieldName;');
    buf.writeln('if ($localVar != null) {');
    generateBody(localVar);
    buf.writeln('}');
  } else {
    generateBody(fieldName);
  }
}

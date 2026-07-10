import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:validasi_gen/src/generators/refine.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

DartEmitter get _emitter => DartEmitter(allocator: Allocator.none);

String generateValidateForm(
  String className,
  List<FieldRules> fields, {
  List<RefineMethodInfo> refines = const [],
}) {
  final fieldsClassName = '${className}Fields';
  final classHasAsync =
      fields.any((f) => f.hasAsyncRule) || refines.any((r) => r.isAsync);

  // Build a map of field name -> form-level accessor expression.
  // ctrl.getValue returns dynamic, so we cast to the field's declared type.
  final formAccessors = <String, String>{};
  for (final ctx in fields) {
    final name = ctx.field.name!;
    final type = ctx.field.type.getDisplayString();
    final nullableType = type.endsWith('?') ? type : '$type?';
    formAccessors[name] =
        'ctrl.getValue($fieldsClassName.${ctx.accessorName}) as $nullableType';
  }

  final fn = Method((m) {
    m.name = 'validateForm_$className';
    if (classHasAsync) m.modifier = MethodModifier.async;
    m.returns = classHasAsync
        ? refer('Future<ValidasiResult<$className>>')
        : refer('ValidasiResult<$className>');
    m.requiredParameters.add(Parameter((p) {
      p.name = 'ctrl';
      p.type = refer('ValidasiFormController<$className>');
    }));

    final buf = StringBuffer();
    buf.writeln('final \$errors = <ValidationError>[];');
    for (final ctx in fields) {
      _generateFormFieldBody(buf, ctx, fieldsClassName, isAsync: classHasAsync);
    }
    for (final r in refines) {
      buf.write(emitRefineInvocation(
        info: r,
        fieldAccessors: formAccessors,
        isFormContext: true,
        isAsync: r.isAsync,
      ));
    }
    buf.writeln('if (\$errors.isNotEmpty) {');
    buf.writeln('return ValidasiResult(errors: \$errors, isValid: false);');
    buf.writeln('}');
    buf.writeln('return ValidasiResult(errors: const [], isValid: true);');

    m.body = Code(buf.toString());
  });

  final buf = StringBuffer();
  buf.writeln();
  buf.write(fn.accept(_emitter));
  return buf.toString();
}

void _generateFormFieldBody(
  StringBuffer buf,
  FieldRules ctx,
  String fieldsClassName, {
  required bool isAsync,
}) {
  final fieldName = ctx.field.name!;

  if (ctx.isNested) {
    // Nested objects and iterables: call their own validateForm(ctrl) and
    // prefix errors. The nested class will be a generated sibling that
    // expects a ValidasiFormController<NestedClass>.
    final resultVar = '\$${fieldName}Result';
    final awaitKw = isAsync ? 'await ' : '';
    final validateCall = isAsync ? 'validateFormAsync' : 'validateForm';
    final castCtrl = 'ctrl as ValidasiFormController<${ctx.nestedClassName}>';

    if (ctx.isNestedIterable) {
      final indexVar = '\$${fieldName}Index';
      final itemVar = '\$${fieldName}Item';
      final isNullable =
          ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;

      void generateBody(String collection) {
        buf.writeln(
            'for (var $indexVar = 0; $indexVar < $collection.length; $indexVar++) {');
        buf.writeln('final $itemVar = $collection[$indexVar];');
        buf.writeln(
            'final $resultVar = $awaitKw$itemVar.$validateCall($castCtrl);');
        buf.writeln('if (!$resultVar.isValid) {');
        buf.writeln(
            '\$errors.addAll($resultVar.errors.map((e) => e..prefix("$fieldName[\${$indexVar}]")));');
        buf.writeln('}');
        buf.writeln('}');
      }

      if (isNullable) {
        final localVar = '\$${fieldName}Value';
        buf.writeln(
            'final $localVar = ctrl.getValue($fieldsClassName.${ctx.accessorName}) as List<${ctx.nestedClassName}>?;');
        buf.writeln('if ($localVar != null) {');
        generateBody(localVar);
        buf.writeln('}');
      } else {
        buf.writeln(
            'final ${'\$${fieldName}List'} = ctrl.getValue($fieldsClassName.${ctx.accessorName}) as List<${ctx.nestedClassName}>;');
        generateBody('\$${fieldName}List');
      }
    } else {
      final isNullable =
          ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;
      if (isNullable) {
        final localVar = '\$${fieldName}Value';
        buf.writeln(
            'final $localVar = ctrl.getValue($fieldsClassName.${ctx.accessorName}) as ${ctx.nestedClassName}?;');
        buf.writeln('if ($localVar != null) {');
        buf.writeln(
            'final $resultVar = $awaitKw$localVar.$validateCall($castCtrl);');
        buf.writeln('if (!$resultVar.isValid) {');
        buf.writeln(
            '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName\')));');
        buf.writeln('}');
        buf.writeln('}');
      } else {
        buf.writeln(
            'final $resultVar = $awaitKw(ctrl.getValue($fieldsClassName.${ctx.accessorName}) as ${ctx.nestedClassName}).$validateCall($castCtrl);');
        buf.writeln('if (!$resultVar.isValid) {');
        buf.writeln(
            '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName\')));');
        buf.writeln('}');
      }
    }
    return;
  }

  // Simple field
  final resultVar = '\$${fieldName}Result';
  final awaitKw = isAsync ? 'await ' : '';
  final validateMethod = isAsync ? 'validateAsync' : 'validate';

  buf.writeln('// Field: $fieldName');
  buf.writeln('{');
  buf.writeln(
      'final $resultVar = $awaitKw$fieldsClassName.${ctx.accessorName}.$validateMethod(ctrl.getValue<${ctx.dartTypeDisplay}>($fieldsClassName.${ctx.accessorName}));');
  buf.writeln('if (!$resultVar.isValid) {');
  buf.writeln(
      '\$errors.addAll($resultVar.errors.map((e) => e..prefix(\'$fieldName\')));');
  buf.writeln('}');
  buf.writeln('}');
}

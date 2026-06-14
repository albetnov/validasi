import 'package:validasi_gen/src/parsers/rules.dart';

String generateCrossFieldsClass(
  String className,
  List<CrossFieldInfo> crossFields,
) {
  if (crossFields.isEmpty) return '';

  final buf = StringBuffer();
  final crossClassName = '${className}CrossFields';

  buf.writeln();
  buf.writeln(
      'sealed class $crossClassName extends CrossFieldKey<$className> {');
  buf.writeln('  const $crossClassName._(super.name);');

  for (final cf in crossFields) {
    final constName = cf.field.name;
    final leafName = '_${className}_${constName}_CrossField';
    buf.writeln('  static const $crossClassName $constName = $leafName();');
  }

  buf.writeln('}');
  buf.writeln();

  for (final cf in crossFields) {
    final leafName = '_${className}_${cf.field.name}_CrossField';
    buf.writeln('class $leafName extends $crossClassName {');
    buf.writeln("  const $leafName() : super._('${cf.field.name}');");
    buf.writeln('}');
    buf.writeln();
  }

  return buf.toString();
}

String generateFromForm(
  String className,
  List<FieldRules> allFields,
) {
  final buf = StringBuffer();
  final fieldsClassName = '${className}Fields';

  buf.writeln();
  buf.writeln('$className assemble_$className(');
  buf.writeln('    ValidasiFormController<$className> ctrl) => $className(');
  for (final f in allFields) {
    final fieldName = f.field.name;
    final typeName = f.dartTypeDisplay;
    buf.writeln(
        '    $fieldName: ctrl.getValue($fieldsClassName.$fieldName) as $typeName,');
  }
  buf.writeln('  );');

  return buf.toString();
}

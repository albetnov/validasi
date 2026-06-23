import 'package:code_builder/code_builder.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

DartEmitter get _emitter => DartEmitter(allocator: Allocator.none);

String generateFromForm(
  String className,
  List<FieldRules> allFields,
) {
  final fieldsClassName = '${className}Fields';

  final body = StringBuffer();
  body.writeln('return $className(');
  for (final f in allFields) {
    if (f.isNested) continue;
    final fieldName = f.field.name!;
    final typeName = f.dartTypeDisplay;
    body.writeln(
        '$fieldName: ctrl.getValue($fieldsClassName.$fieldName) as $typeName,');
  }
  body.write(');');

  final fn = Method((m) {
    m.name = 'assemble_$className';
    m.returns = refer(className);
    m.requiredParameters.add(Parameter((p) {
      p.name = 'ctrl';
      p.type = refer('ValidasiFormController<$className>');
    }));
    m.body = Code(body.toString());
  });

  final buf = StringBuffer();
  buf.writeln();
  buf.write(fn.accept(_emitter));
  return buf.toString();
}

import 'package:code_builder/code_builder.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

DartEmitter get _emitter => DartEmitter(allocator: Allocator.none);

String generateSchemaClass(
  String className,
  List<FieldRules> allFields,
) {
  final fieldsClassName = '${className}Fields';
  final schemaClassName = '_${className}Schema';

  final body = StringBuffer();
  body.writeln('return $className(');
  for (final f in allFields) {
    if (f.isNested) continue;
    final fieldName = f.field.name!;
    final typeName = f.dartTypeDisplay;
    body.writeln(
        '$fieldName: reader.getValue($fieldsClassName.$fieldName) as $typeName,');
  }
  body.write(');');

  final schemaClass = Class((c) {
    c.name = schemaClassName;
    c.extend = refer('ValidasiSchema<$className>');
    c.constructors.add(Constructor((con) {
      con.constant = true;
    }));

    c.methods.add(Method((m) {
      m.name = 'allocate';
      m.returns = refer(className);
      m.annotations.add(refer('override'));
      m.requiredParameters.add(Parameter((p) {
        p.name = 'reader';
        p.type = refer('ValidasiFieldReader<$className>');
      }));
      m.body = Code(body.toString());
    }));
  });

  final buf = StringBuffer();
  buf.writeln();
  buf.write(schemaClass.accept(_emitter));
  return buf.toString();
}

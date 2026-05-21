import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generators/extension.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

class ValidasiGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final buffer = StringBuffer();

    for (final cls in library.classes) {
      if (!_hasAnnotation(cls, 'ValidateClass')) continue;

      final fields = extractValidateFields(cls);
      if (fields.isEmpty) continue;

      buffer.write(generateValidateExtension(cls.name, fields));
    }

    return buffer.toString();
  }

  bool _hasAnnotation(ClassElement cls, String name) {
    return cls.metadata.any((meta) {
      final element = meta.element;
      return element is ConstructorElement &&
          element.enclosingElement.name == name;
    });
  }
}

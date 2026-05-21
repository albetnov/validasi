import 'dart:async';

import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_annotation/annotation.dart';

import 'package:validasi_gen/src/generators/extension.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

class ValidasiGenerator extends GeneratorForAnnotation<ValidateClass> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) return '';

    final fields = extractValidateFields(element);
    if (fields.isEmpty) return '';

    return generateValidateExtension(element.name, fields);
  }
}

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generator.dart';

Builder validasiBuilder(BuilderOptions options) => _ValidasiBuilder();

class _ValidasiBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final library = await buildStep.inputLibrary;
    final output = ValidasiGenerator().generate(
      LibraryReader(library),
      buildStep,
    );

    if (output.isEmpty) return;

    final inputFile = buildStep.inputId.pathSegments.last;
    final outputId = buildStep.inputId.changeExtension('.g.dart');

    await buildStep.writeAsString(
      outputId,
      '''// GENERATED CODE - DO NOT MODIFY BY HAND

part of '$inputFile';

$output''',
    );
  }
}

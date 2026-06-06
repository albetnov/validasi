import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generator.dart';
import 'package:validasi_gen/src/utils.dart';

Builder validasiBuilder(BuilderOptions options) => _ValidasiBuilder(options);

class _ValidasiBuilder implements Builder {
  _ValidasiBuilder(this.options);

  final BuilderOptions options;

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final library = await buildStep.inputLibrary;
    final generateFieldsDefault =
        boolOption(options.config, 'generateFields') ?? true;
    final output = ValidasiGenerator(
      generateFieldsDefault: generateFieldsDefault,
    ).generate(
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

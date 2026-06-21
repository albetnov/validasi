import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generator.dart';
import 'package:validasi_gen/src/utils.dart';

Builder validasiBuilder(BuilderOptions options) => _ValidasiBuilder(options);

class _ValidasiBuilder implements Builder {
  _ValidasiBuilder(this.options);

  final BuilderOptions options;
  final _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
    pageWidth: 80,
  );

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final library = await buildStep.inputLibrary;
    final generateFieldsDefault =
        boolOption(options.config, 'generateFields') ?? true;
    final generateAssembleDefault =
        boolOption(options.config, 'generateAssemble') ?? true;
    final generateValidateFormDefault =
        boolOption(options.config, 'generateValidateForm') ?? false;
    final generateIndexedFieldsDefault =
        boolOption(options.config, 'generateIndexedFields') ?? false;
    final output = ValidasiGenerator(
      generateFieldsDefault: generateFieldsDefault,
      generateAssembleDefault: generateAssembleDefault,
      generateValidateFormDefault: generateValidateFormDefault,
      generateIndexedFieldsDefault: generateIndexedFieldsDefault,
    ).generate(
      LibraryReader(library),
      buildStep,
    );

    if (output.isEmpty) return;

    final inputFile = buildStep.inputId.pathSegments.last;
    final outputId = buildStep.inputId.changeExtension('.g.dart');

    final unformatted = '''// GENERATED CODE - DO NOT MODIFY BY HAND

part of '$inputFile';

$output''';

    try {
      final formatted = _formatter.format(unformatted);
      await buildStep.writeAsString(outputId, formatted);
    } catch (_) {
      await buildStep.writeAsString(outputId, unformatted);
    }
  }
}

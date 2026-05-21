import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/generator.dart';

Builder validasiBuilder(BuilderOptions options) =>
    SharedPartBuilder([ValidasiGenerator()], 'validasi');

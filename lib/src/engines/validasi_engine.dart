import 'package:validasi/src/validasi_result.dart';
import 'package:validasi/src/validasi_transformation.dart';

abstract class ValidasiEngine<T> {
  const ValidasiEngine({this.preprocess});

  final ValidasiTransformation<dynamic, T>? preprocess;

  ValidasiResult<T> validate(dynamic value);
}

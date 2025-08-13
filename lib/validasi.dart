library;

import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/engines/validasi_enum.dart';
import 'package:validasi/src/engines/validasi_list.dart';
import 'package:validasi/src/rule.dart';
import 'package:validasi/src/engines/validasi_scalar.dart';

class Validasi {
  static ValidasiScalar<String> string([List<Rule<String>>? rules]) =>
      ValidasiScalar<String>(rules: rules);

  static ValidasiList<T> list<T>(ValidasiEngine<T> itemSchema) =>
      ValidasiList<T>(itemSchema);

  static ValidasiEnum enumValue(List<String> values) => ValidasiEnum(values);
}

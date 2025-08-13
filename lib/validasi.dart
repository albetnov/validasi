library;

import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/engines/validasi_list_engine.dart';
import 'package:validasi/src/rule.dart';
import 'package:validasi/src/engines/validasi_scalar.dart';

class Validasi {
  static ValidasiScalar<String> string([List<Rule<String>>? rules]) =>
      ValidasiScalar<String>(rules: rules);

  static ValidasiListEngine<T> list<T>(ValidasiEngine<T> itemSchema) =>
      ValidasiListEngine<T>(itemSchema);
}

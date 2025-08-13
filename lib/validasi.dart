library;

import 'package:validasi/src/rule.dart';
import 'package:validasi/src/validasi_engine.dart';

class Validasi {
  static ValidasiEngine<String> string(List<Rule<String>> rules) =>
      ValidasiEngine<String>.withRules(rules);
}

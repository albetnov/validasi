export 'handlers/handler.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/min_length.dart';
import 'package:validasi_gen/src/handlers/max_length.dart';
import 'package:validasi_gen/src/handlers/one_of.dart';

final Map<String, RuleGen> ruleGens = {
  for (final g in [MinLengthGen(), MaxLengthGen(), OneOfGen()]) g.name: g,
};

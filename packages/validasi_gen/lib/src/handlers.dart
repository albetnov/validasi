export 'handlers/handler.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/min_length.dart';
import 'package:validasi_gen/src/handlers/max_length.dart';
import 'package:validasi_gen/src/handlers/one_of.dart';
import 'package:validasi_gen/src/handlers/async_inline.dart';
import 'package:validasi_gen/src/handlers/custom_rule.dart';
import 'package:validasi_gen/src/handlers/async_custom_rule.dart';
import 'package:validasi_gen/src/handlers/inline.dart';

final Map<String, RuleGen> ruleGens = {
  for (final g in [
    MinLengthGen(),
    MaxLengthGen(),
    OneOfGen(),
    AsyncInlineGen(),
    CustomRuleGen(),
    AsyncCustomRuleGen(),
    InlineGen(),
  ])
    g.name: g,
};

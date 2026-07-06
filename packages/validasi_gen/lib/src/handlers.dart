export 'handlers/handler.dart'
    show RuleGen, RuleInfo, FieldContext, fieldContextFromType;

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/min_length.dart';
import 'package:validasi_gen/src/handlers/max_length.dart';
import 'package:validasi_gen/src/handlers/one_of.dart';
import 'package:validasi_gen/src/handlers/async_inline.dart';
import 'package:validasi_gen/src/handlers/custom_rule.dart';
import 'package:validasi_gen/src/handlers/async_custom_rule.dart';
import 'package:validasi_gen/src/handlers/inline.dart';
import 'package:validasi_gen/src/handlers/alpha.dart';
import 'package:validasi_gen/src/handlers/alphanumeric.dart';
import 'package:validasi_gen/src/handlers/numeric.dart';
import 'package:validasi_gen/src/handlers/case_rules.dart';
import 'package:validasi_gen/src/handlers/starts_with.dart';
import 'package:validasi_gen/src/handlers/ends_with.dart';
import 'package:validasi_gen/src/handlers/regex.dart';
import 'package:validasi_gen/src/handlers/ulid.dart';
import 'package:validasi_gen/src/handlers/uuid.dart';
import 'package:validasi_gen/src/handlers/url.dart';
import 'package:validasi_gen/src/handlers/ip.dart';
import 'package:validasi_gen/src/handlers/email.dart';
import 'package:validasi_gen/src/handlers/contains.dart';
import 'package:validasi_gen/src/handlers/between.dart';
import 'package:validasi_gen/src/handlers/less_than.dart';
import 'package:validasi_gen/src/handlers/less_than_equal.dart';
import 'package:validasi_gen/src/handlers/more_than.dart';
import 'package:validasi_gen/src/handlers/more_than_equal.dart';
import 'package:validasi_gen/src/handlers/negative.dart';
import 'package:validasi_gen/src/handlers/non_negative.dart';
import 'package:validasi_gen/src/handlers/non_positive.dart';
import 'package:validasi_gen/src/handlers/positive.dart';
import 'package:validasi_gen/src/handlers/finite.dart';
import 'package:validasi_gen/src/handlers/exact_length.dart';
import 'package:validasi_gen/src/handlers/is_empty.dart';
import 'package:validasi_gen/src/handlers/unique.dart';
import 'package:validasi_gen/src/handlers/contains_all.dart';
import 'package:validasi_gen/src/handlers/not_contains.dart';
import 'package:validasi_gen/src/handlers/equals.dart';
import 'package:validasi_gen/src/handlers/not_equals.dart';
import 'package:validasi_gen/src/handlers/having.dart';

final Map<String, RuleGen> ruleGens = {
  for (final g in [
    MinLengthGen(),
    MaxLengthGen(),
    OneOfGen(),
    AsyncInlineGen(),
    CustomRuleGen(),
    AsyncCustomRuleGen(),
    InlineGen(),
    AlphaGen(),
    AlphanumericGen(),
    NumericGen(),
    LowercaseGen(),
    UppercaseGen(),
    StartsWithGen(),
    EndsWithGen(),
    RegexGen(),
    UlidGen(),
    UuidGen(),
    UrlGen(),
    Ipv4Gen(),
    Ipv6Gen(),
    IpGen(),
    EmailGen(),
    ContainsGen(),
    BetweenGen(),
    LessThanGen(),
    LessThanEqualGen(),
    MoreThanGen(),
    MoreThanEqualGen(),
    NegativeGen(),
    NonNegativeGen(),
    NonPositiveGen(),
    PositiveGen(),
    FiniteGen(),
    ExactLengthGen(),
    IsEmptyGen(),
    IsNotEmptyGen(),
    UniqueGen(),
    ContainsAllGen(),
    NotContainsGen(),
    EqualsGen(),
    NotEqualsGen(),
    HavingGen(),
  ])
    g.name: g,
};

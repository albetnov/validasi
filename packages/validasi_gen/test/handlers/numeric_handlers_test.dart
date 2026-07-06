import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
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

void main() {
  test('BetweenGen check', () {
    final info = RuleInfo('Between', {'min': '1', 'max': '10'}, null);
    expect(BetweenGen().check(info, 'v'),
        'v != null && (v < 1 || v > 10)');
  });

  test('LessThanGen check', () {
    final info = RuleInfo('LessThan', {'max': '10'}, null);
    expect(LessThanGen().check(info, 'v'), 'v != null && v >= 10');
  });

  test('LessThanEqualGen check', () {
    final info = RuleInfo('LessThanEqual', {'max': '10'}, null);
    expect(LessThanEqualGen().check(info, 'v'), 'v != null && v > 10');
  });

  test('MoreThanGen check', () {
    final info = RuleInfo('MoreThan', {'min': '1'}, null);
    expect(MoreThanGen().check(info, 'v'), 'v != null && v <= 1');
  });

  test('MoreThanEqualGen check', () {
    final info = RuleInfo('MoreThanEqual', {'min': '1'}, null);
    expect(MoreThanEqualGen().check(info, 'v'), 'v != null && v < 1');
  });

  test('NegativeGen check', () {
    final info = RuleInfo('Negative', const {}, null);
    expect(NegativeGen().check(info, 'v'), 'v != null && v >= 0');
  });

  test('NonNegativeGen check', () {
    final info = RuleInfo('NonNegative', const {}, null);
    expect(NonNegativeGen().check(info, 'v'), 'v != null && v < 0');
  });

  test('NonPositiveGen check', () {
    final info = RuleInfo('NonPositive', const {}, null);
    expect(NonPositiveGen().check(info, 'v'), 'v != null && v > 0');
  });

  test('PositiveGen check', () {
    final info = RuleInfo('Positive', const {}, null);
    expect(PositiveGen().check(info, 'v'), 'v != null && v <= 0');
  });

  test('FiniteGen check', () {
    final info = RuleInfo('Finite', const {}, null);
    expect(FiniteGen().check(info, 'v'), 'v != null && !v.isFinite');
  });
}

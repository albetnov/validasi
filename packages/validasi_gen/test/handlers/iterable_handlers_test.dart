import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/exact_length.dart';
import 'package:validasi_gen/src/handlers/is_empty.dart';
import 'package:validasi_gen/src/handlers/unique.dart';
import 'package:validasi_gen/src/handlers/contains_all.dart';
import 'package:validasi_gen/src/handlers/not_contains.dart';

void main() {
  test('ExactLengthGen check', () {
    final info = RuleInfo('ExactLength', {'length': 3}, null);
    expect(ExactLengthGen().check(info, 'v'), 'v != null && v.length != 3');
  });

  test('IsEmptyGen check', () {
    final info = RuleInfo('IsEmpty', const {}, null);
    expect(IsEmptyGen().check(info, 'v'), 'v != null && v.isNotEmpty');
  });

  test('IsNotEmptyGen check', () {
    final info = RuleInfo('IsNotEmpty', const {}, null);
    expect(IsNotEmptyGen().check(info, 'v'), 'v != null && v.isEmpty');
  });

  test('UniqueGen check', () {
    final info = RuleInfo('Unique', const {}, null);
    expect(UniqueGen().check(info, 'v'),
        'v != null && v.toSet().length != v.length');
  });

  test('ContainsAllGen check', () {
    final info = RuleInfo('ContainsAll', {
      'elements': ["'a'", "'b'"]
    }, null);
    expect(ContainsAllGen().check(info, 'v'),
        "v != null && !['a', 'b'].every(v.contains)");
  });

  test('NotContainsGen check', () {
    final info = RuleInfo('NotContains', {'value': "'x'"}, null);
    expect(NotContainsGen().check(info, 'v'), "v != null && v.contains('x')");
  });
}

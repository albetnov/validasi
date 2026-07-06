import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/equals.dart';
import 'package:validasi_gen/src/handlers/not_equals.dart';
import 'package:validasi_gen/src/handlers/having.dart';

void main() {
  test('EqualsGen check', () {
    final info = RuleInfo('Equals', {'expected': "'a'"}, null);
    expect(EqualsGen().check(info, 'v'), "v != null && v != 'a'");
  });

  test('NotEqualsGen check', () {
    final info = RuleInfo('NotEquals', {'unexpected': "'a'"}, null);
    expect(NotEqualsGen().check(info, 'v'), "v != null && v == 'a'");
  });

  test('HavingGen check ignores nullable guard (runs on null too)', () {
    final info = RuleInfo('Having', {
      'validValues': ["'a'", "'b'"]
    }, null);
    expect(HavingGen().check(info, 'v', nullable: true),
        "!['a', 'b'].contains(v)");
  });
}

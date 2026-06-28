import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class NestedMapBenchmark extends BenchmarkBase {
  final schema = Validasi.map<dynamic>([
    Rules.map.hasFields({
      'profile': FieldRules<Map<String, dynamic>>([
        Rules.map.hasFields({
          'name': FieldRules<String>([
            Rules.string.minLength(2),
          ]),
          'age': FieldRules<int>([
            Rules.number.moreThanEqual(0),
          ]),
          'address': FieldRules<Map<String, dynamic>>([
            Rules.map.hasFields({
              'street': FieldRules<String>([
                Rules.string.minLength(3),
              ]),
              'city': FieldRules<String>([
                Rules.string.minLength(2),
              ]),
              'zip': FieldRules<String>([
                Rules.string.minLength(5),
              ]),
            }),
          ]),
        }),
      ]),
    }),
    Rules.map.conditionalField<dynamic>('profile', (ctx, value) {
      if (ctx.has('profile') &&
          ctx.get<int>('age') != null &&
          ctx.get<int>('age')! < 18) {
        return 'Must be 18 or older';
      }
      return null;
    }),
  ]);

  NestedMapBenchmark() : super('NestedMap');

  @override
  void run() {
    schema.validate({
      'profile': {
        'name': 'Alice',
        'age': 30,
        'address': {
          'street': '123 Main St',
          'city': 'Springfield',
          'zip': '12345',
        },
      },
    });
    schema.validate({
      'profile': {
        'name': 'Bob',
        'age': 15,
      },
    });
    schema.validate({});
  }
}

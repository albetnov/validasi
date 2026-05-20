import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class NestedMapBenchmark extends BenchmarkBase {
  final schema = Validasi.map<dynamic>([
    MapRules.hasFields({
      'profile': FieldRules<Map<String, dynamic>>([
        MapRules.hasFields({
          'name': FieldRules<String>([
            StringRules.minLength(2),
          ]),
          'age': FieldRules<int>([
            NumberRules.moreThanEqual(0),
          ]),
          'address': FieldRules<Map<String, dynamic>>([
            MapRules.hasFields({
              'street': FieldRules<String>([
                StringRules.minLength(3),
              ]),
              'city': FieldRules<String>([
                StringRules.minLength(2),
              ]),
              'zip': FieldRules<String>([
                StringRules.minLength(5),
              ]),
            }),
          ]),
        }),
      ]),
    }),
    MapRules.conditionalField<dynamic>('profile', (ctx, value) {
      if (ctx.has('profile') && ctx.get<int>('age') != null && ctx.get<int>('age')! < 18) {
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

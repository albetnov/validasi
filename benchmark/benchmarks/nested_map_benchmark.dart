import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class NestedMapBenchmark extends BenchmarkBase {
  final schema = Validasi.map<dynamic>([
    MapRules.hasFields<dynamic>({
      'profile': Validasi.map<dynamic>([
        MapRules.hasFields<dynamic>({
          'name': Validasi.string([
            StringRules.minLength(2),
          ]),
          'age': Validasi.number<int>([
            NumberRules.moreThanEqual(0),
          ]),
          'address': Validasi.map<dynamic>([
            MapRules.hasFields<dynamic>({
              'street': Validasi.string([
                StringRules.minLength(3),
              ]),
              'city': Validasi.string([
                StringRules.minLength(2),
              ]),
              'zip': Validasi.string([
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

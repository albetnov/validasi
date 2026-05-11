import 'dart:typed_data';

import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {

  final validator = Validasi.list([
    IterableRules.forEach(Validasi.map([
      MapRules.hasFields({
        'type': Validasi.string(),
        'value': Validasi.string([Nullable()]),
      })
    ])),
  ]);

  final payload = [
    {'type': 'email', 'value': 'foo@bar.com'},
  ];

  final duration = Duration(seconds: 1);
  int iterationCount = 0;
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < duration) {
    validator.validate(payload);
    iterationCount++;
  }

  print(
      'Array Object : Processed $iterationCount iterations in ${duration.inSeconds} seconds');
}

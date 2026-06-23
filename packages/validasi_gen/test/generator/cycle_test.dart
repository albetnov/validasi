import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'basic_test.dart' show generateForSource;

Future<void> main() async {
  group('cycle detection', () {
    test('throws InvalidGenerationSourceError on circular dependency',
        () async {
      expect(
        () => generateForSource('test/generator/src', 'cycle_source.dart'),
        throwsA(isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains('Circular dependency detected'),
        )),
      );
    });

    test('error message includes the cycle path', () async {
      expect(
        () => generateForSource('test/generator/src', 'cycle_source.dart'),
        throwsA(isA<InvalidGenerationSourceError>().having(
          (e) => e.message,
          'message',
          contains('NodeA'),
        )),
      );
    });
  });
}

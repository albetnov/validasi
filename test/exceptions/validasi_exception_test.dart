import 'package:test/test.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';

void main() {
  group('Validasi Exception Test', () {
    test('can create ValidasiException instance', () {
      var exception = ValidasiException('message');

      expect(exception, isA<Error>());
      expect(exception.message, equals('message'));
    });

    test('toString return message', () {
      var exception = ValidasiException('message');

      expect("$exception", exception.message);
    });
  });
}

import 'package:test/test.dart';
import 'package:validasi/src/transformers/transformer.dart';

class TransformerTestStub extends Transformer<int> {
  @override
  int? transform(value, fail) {
    throw UnimplementedError();
  }
}

void main() {
  group('Test Transformer', () {
    test('should inherit correct signature', () {
      var transformer = TransformerTestStub();

      expect(transformer, isA<Transformer<int>>());
    });

    test('transform method should inherit correct signature', () {
      var transformer = TransformerTestStub();

      expect(
          transformer.transform, isA<int? Function(dynamic, FailCallback)>());
    });

    test('transform method should throw UnimplementedError', () {
      var transformer = TransformerTestStub();

      expect(() => transformer.transform('', (message) {}),
          throwsUnimplementedError);
    });
  });
}

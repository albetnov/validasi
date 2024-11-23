import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';

class GenericTestingStub {
  final String value;

  GenericTestingStub(this.value);

  @override
  bool operator ==(Object other) {
    return other is GenericTestingStub && other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

void main() {
  group('Generic Validation Test', () {
    test('Can create generic validation', () {
      var schema = Validasi.generic<String>();

      expect(schema, isA<GenericValidator>());
    });

    test('Can validate type check on value', () {
      var schema = Validasi.generic<String>();

      shouldNotThrow(() {
        schema.parse('a');
      });

      expect(
          () => schema.parse(1),
          throwFieldError(
            name: 'invalidType',
            message: 'Expected type String. Got int instead.',
          ));
    });

    test('Can validate type check on value with transformer', () {
      var schema = Validasi.generic<String>(transformer: StringTransformer());

      shouldNotThrow(() {
        schema.parse(1);
      });
    });

    test('nullable should pass if value is null', () {
      var schema = Validasi.generic<String>().nullable();

      expect(schema.tryParse(null).isValid, isTrue);
    });

    test('nullable should fail if value is not null', () {
      var schema = Validasi.generic<String>();

      var result = schema.tryParse(null);

      expect(getName(result), equals('required'));
      expect(getMsg(result), equals('field is required'));
    });

    test('verify can attach custom', () async {
      testCanAttachCustom(
        valid: 'valid',
        invalid: 'invalid',
        validator: () => Validasi.generic<String>(),
      );
    });

    test('should pass for equalTo', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('a');

      var schema = Validasi.generic<GenericTestingStub>().equalTo(stub1);

      expect(schema.tryParse(stub1).isValid, isTrue);
      expect(schema.tryParse(stub2).isValid, isTrue);
    });

    test('should fail for equalTo', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema = Validasi.generic<GenericTestingStub>().equalTo(stub1);

      expect(schema.tryParse(stub2).isValid, isFalse);
    });

    test('can customize equalTo message', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema = Validasi.generic<GenericTestingStub>().equalTo(
        stub1,
        message: 'Value must be equal to $stub1',
      );

      expect(
          () => schema.parse(stub2),
          throwFieldError(
            name: 'equalTo',
            message: 'Value must be equal to $stub1',
          ));
    });

    test('should pass for notEqualTo', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema = Validasi.generic<GenericTestingStub>().notEqualTo(stub1);

      expect(schema.tryParse(stub2).isValid, isTrue);
    });

    test('should fail for notEqualTo', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('a');

      var schema = Validasi.generic<GenericTestingStub>().notEqualTo(stub1);

      expect(schema.tryParse(stub2).isValid, isFalse);
    });

    test('can customize notEqualTo message', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('a');

      var schema = Validasi.generic<GenericTestingStub>().notEqualTo(
        stub1,
        message: 'Value must not be equal to $stub1',
      );

      expect(
          () => schema.parse(stub2),
          throwFieldError(
            name: 'notEqualTo',
            message: 'Value must not be equal to $stub1',
          ));
    });

    test('should pass for oneOf', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema = Validasi.generic<GenericTestingStub>().oneOf([stub1, stub2]);

      expect(schema.tryParse(stub1).isValid, isTrue);
      expect(schema.tryParse(stub2).isValid, isTrue);
    });

    test('should fail for oneOf', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');
      var stub3 = GenericTestingStub('c');

      var schema = Validasi.generic<GenericTestingStub>().oneOf([stub1, stub2]);

      expect(schema.tryParse(stub3).isValid, isFalse);
    });

    test('can customize oneOf message', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');
      var stub3 = GenericTestingStub('c');

      var schema = Validasi.generic<GenericTestingStub>().oneOf(
        [stub1, stub2],
        message: 'Value must be one of $stub1, $stub2',
      );

      expect(
          () => schema.parse(stub3),
          throwFieldError(
            name: 'oneOf',
            message: 'Value must be one of $stub1, $stub2',
          ));
    });

    test('should pass for notOneOf', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');
      var stub3 = GenericTestingStub('c');

      var schema =
          Validasi.generic<GenericTestingStub>().notOneOf([stub1, stub2]);

      expect(schema.tryParse(stub3).isValid, isTrue);
    });

    test('should fail for notOneOf', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema =
          Validasi.generic<GenericTestingStub>().notOneOf([stub1, stub2]);

      expect(schema.tryParse(stub1).isValid, isFalse);
      expect(schema.tryParse(stub2).isValid, isFalse);
    });

    test('can customize notOneOf message', () {
      var stub1 = GenericTestingStub('a');
      var stub2 = GenericTestingStub('b');

      var schema = Validasi.generic<GenericTestingStub>().notOneOf(
        [stub1, stub2],
        message: 'Value must not be one of $stub1, $stub2',
      );

      expect(
          () => schema.parse(stub1),
          throwFieldError(
            name: 'notOneOf',
            message: 'Value must not be one of $stub1, $stub2',
          ));
    });
  });
}

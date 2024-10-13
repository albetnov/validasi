import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import 'validators/validator_test.mocks.dart';

void shouldNotThrow(void Function() callback) {
  try {
    callback();
  } catch (e) {
    fail("Should not thrown any exception, get $e instead");
  }
}

Future<void> shouldNotThrowAsync(Future<void> Function() callback) async {
  try {
    await callback();
  } catch (e) {
    fail("Should not thrown any exception, get $e instead");
  }
}

Matcher throwFieldError({String? name, String? message, String? path}) =>
    throwsA(predicate((e) =>
        e is FieldError &&
        (path != null ? e.path == path : true) &&
        (name != null ? e.name == name : true) &&
        (message != null ? e.message == message : true)));

String? getMsg(Result result) => result.errors.firstOrNull?.message;
String? getName(Result result) => result.errors.firstOrNull?.name;
String? getPath(Result result) => result.errors.firstOrNull?.path;

Future<void> testCanAttachCustom<T>({
  required T valid,
  required T invalid,
  required Validator Function() validator,
  bool Function(T oldValue, T newValue)? comparator,
}) async {
  var schema = validator().custom((value, fail) =>
      value != null &&
      (comparator != null ? comparator(value, valid) : value == valid));

  expect(schema.tryParse(invalid).isValid, isFalse);
  expect(schema.tryParse(valid).isValid, isTrue);

  var stub = MockCustomRule<T>();

  when(stub.handle(invalid, any)).thenReturn(false);
  when(stub.handle(valid, any)).thenReturn(true);

  schema.customFor(stub);

  expect(schema.tryParse(invalid).isValid, isFalse);
  expect(schema.tryParse(valid).isValid, isTrue);

  var asyncSchema = validator().custom((value, fail) async =>
      value != null &&
      (comparator != null ? comparator(value, valid) : value == valid));

  expect((await asyncSchema.tryParseAsync(invalid)).isValid, isFalse);
  expect((await asyncSchema.tryParseAsync(valid)).isValid, isTrue);

  var asyncStub = MockCustomRule<T>();

  when(asyncStub.handle(invalid, any)).thenAnswer((_) async => false);
  when(asyncStub.handle(valid, any)).thenAnswer((_) async => true);

  asyncSchema.customFor(asyncStub as dynamic);

  expect((await asyncSchema.tryParseAsync(invalid)).isValid, isFalse);
  expect((await asyncSchema.tryParseAsync(valid)).isValid, isTrue);
}

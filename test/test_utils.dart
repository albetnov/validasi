import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

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

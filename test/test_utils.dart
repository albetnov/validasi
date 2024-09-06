import 'package:test/test.dart';

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

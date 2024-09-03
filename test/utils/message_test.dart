import 'package:test/test.dart';
import 'package:validasi/src/utils/message.dart';

void main() {
  group('Message Test', () {
    test('can create Message instance', () {
      Message message = Message('path');

      expect(message.path, 'path');
      expect(message.parse, 'path is not valid');
    });

    test('can customize fallback', () {
      Message message = Message('path', fallback: ':name is required');

      expect(message.parse, equals('path is required'));
    });

    test('use message instead of callback if message exist', () {
      Message message =
          Message('asep', message: 'Hello :name!', fallback: 'fallback!');

      expect(message.parse, equals('Hello asep!'));
    });
  });
}

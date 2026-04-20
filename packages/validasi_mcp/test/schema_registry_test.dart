import 'package:test/test.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

void main() {
  group('SchemaRegistry', () {
    test('register and resolve schema', () {
      final registry = SchemaRegistry();

      registry.register(
        id: 'username',
        description: 'username schema',
        builder: () => Validasi.string([StringRules.minLength(3)]),
      );

      expect(registry.has('username'), isTrue);
      expect(registry.get('username'), isNotNull);
      expect(registry.get('username')!.description, equals('username schema'));
    });

    test('list should be sorted by id', () {
      final registry = SchemaRegistry();

      registry.register(
        id: 'b',
        builder: () => Validasi.string(),
      );
      registry.register(
        id: 'a',
        builder: () => Validasi.string(),
      );

      final ids = registry.list().map((item) => item.id).toList(growable: false);
      expect(ids, equals(<String>['a', 'b']));
    });
  });
}

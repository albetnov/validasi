import 'package:test/test.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

void main() {
  group('ValidasiMcpToolHandlers', () {
    late SchemaRegistry registry;
    late ValidasiMcpToolHandlers handlers;

    setUp(() {
      registry = SchemaRegistry();
      handlers = ValidasiMcpToolHandlers(registry: registry);

      registry.register(
        id: 'user.name',
        description: 'user name schema',
        builder: () => Validasi.string([
          StringRules.minLength(2),
        ]),
      );
    });

    test('listSchemas should return sorted schemas', () {
      registry.register(
        id: 'a.schema',
        builder: () => Validasi.string(),
      );

      final result = handlers.listSchemas();
      final schemas = result['schemas'] as List<Object?>;

      expect(result['ok'], isTrue);
      expect((schemas.first as Map<String, Object?>)['id'], equals('a.schema'));
    });

    test('describeSchema should return schema metadata', () {
      final result = handlers.describeSchema({'schema_id': 'user.name'});

      expect(result['ok'], isTrue);
      expect(result['schema_id'], equals('user.name'));
      final schema = result['schema'] as Map<String, Object?>;
      expect(schema['type'], equals('String'));
    });

    test('describeSchema should return not found error', () {
      final result = handlers.describeSchema({'schema_id': 'missing'});

      expect(result['ok'], isFalse);
      final error = result['error'] as Map<String, Object?>;
      expect(error['code'], equals('SCHEMA_NOT_FOUND'));
    });

    test('validateInput should return deterministic validation payload', () {
      final result = handlers.validateInput({
        'schema_id': 'user.name',
        'input': 'A',
      });

      expect(result['ok'], isTrue);
      final validation = result['validation'] as Map<String, Object?>;
      expect(validation['isValid'], isFalse);
      expect(validation['errorCount'], equals(1));
    });

    test('callTool should return unknown tool error', () {
      final result = handlers.callTool('not_a_tool', const {});

      expect(result['ok'], isFalse);
      final error = result['error'] as Map<String, Object?>;
      expect(error['code'], equals('UNKNOWN_TOOL'));
    });
  });
}

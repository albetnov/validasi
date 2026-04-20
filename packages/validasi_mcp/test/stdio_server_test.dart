import 'package:test/test.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

void main() {
  group('ValidasiMcpStdioServer', () {
    late SchemaRegistry registry;
    late ValidasiMcpStdioServer server;

    setUp(() {
      registry = SchemaRegistry();
      registry.register(
        id: 'username',
        builder: () => Validasi.string([StringRules.minLength(3)]),
      );
      final handlers = ValidasiMcpToolHandlers(registry: registry);
      server = ValidasiMcpStdioServer(handlers: handlers);
    });

    test('initialize request should return capabilities', () {
      final response = server.handleRequest({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
      });

      expect(response, isNotNull);
      final result = response!['result'] as Map<String, Object?>;
      expect(result['protocolVersion'], equals('2024-11-05'));
      expect(result.containsKey('capabilities'), isTrue);
    });

    test('tools/list should return tool definitions', () {
      final response = server.handleRequest({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/list',
      });

      final result = response!['result'] as Map<String, Object?>;
      final tools = result['tools'] as List<Object?>;
      expect(tools, isNotEmpty);
    });

    test('tools/call validate_input should return structured content', () {
      final response = server.handleRequest({
        'jsonrpc': '2.0',
        'id': 3,
        'method': 'tools/call',
        'params': {
          'name': 'validate_input',
          'arguments': {'schema_id': 'username', 'input': 'ab'},
        },
      });

      final result = response!['result'] as Map<String, Object?>;
      final structured = result['structuredContent'] as Map<String, Object?>;
      final validation = structured['validation'] as Map<String, Object?>;

      expect(structured['ok'], isTrue);
      expect(validation['isValid'], isFalse);
      expect(validation['errorCount'], equals(1));
    });

    test('unknown method should return json-rpc error', () {
      final response = server.handleRequest({
        'jsonrpc': '2.0',
        'id': 4,
        'method': 'unknown/method',
      });

      final error = response!['error'] as Map<String, Object?>;
      expect(error['code'], equals(-32601));
    });
  });
}

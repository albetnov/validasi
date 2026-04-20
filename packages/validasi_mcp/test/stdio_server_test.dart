import 'dart:async';
import 'dart:convert';

import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

void main() {
  group('ValidasiMcpServer', () {
    late SchemaRegistry registry;
    late ValidasiMcpServer server;
    late StreamController<String> clientToServer;
    late StreamController<String> serverToClient;
    int nextRequestId = 0;

    Future<Map<String, Object?>> sendRequest(
      String method, [
      Map<String, Object?>? params,
    ]) async {
      final responseFuture = serverToClient.stream.first;

      clientToServer.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': ++nextRequestId,
          'method': method,
          if (params != null) 'params': params,
        }),
      );

      final response = await responseFuture;
      return (jsonDecode(response) as Map).cast<String, Object?>();
    }

    void sendNotification(String method, [Map<String, Object?>? params]) {
      clientToServer.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'method': method,
          if (params != null) 'params': params,
        }),
      );
    }

    Future<Map<String, Object?>> initializeServer() async {
      final response = await sendRequest('initialize', {
        'protocolVersion': '2024-11-05',
        'capabilities': <String, Object?>{},
        'clientInfo': <String, Object?>{
          'name': 'validasi_mcp_test',
          'version': '1.0.0',
        },
      });

      sendNotification('notifications/initialized');
      return response;
    }

    setUp(() {
      registry = SchemaRegistry();
      registry.register(
        id: 'username',
        builder: () => Validasi.string([StringRules.minLength(3)]),
      );

      clientToServer = StreamController<String>();
      serverToClient = StreamController<String>.broadcast();

      final handlers = ValidasiMcpToolHandlers(registry: registry);
      server = ValidasiMcpServer.fromStreamChannel(
        StreamChannel<String>(clientToServer.stream, serverToClient.sink),
        handlers: handlers,
      );
    });

    tearDown(() async {
      await clientToServer.close();
      await server.shutdown();
      await serverToClient.close();
    });

    test('initialize request should return capabilities', () async {
      final response = await initializeServer();

      final result = response['result'] as Map<String, Object?>;
      expect(result['protocolVersion'], equals('2024-11-05'));
      expect(result.containsKey('capabilities'), isTrue);
      final capabilities = result['capabilities'] as Map<String, Object?>;
      expect(capabilities.containsKey('tools'), isTrue);
    });

    test('tools/list should return tool definitions', () async {
      await initializeServer();

      final response = await sendRequest('tools/list');

      final result = response['result'] as Map<String, Object?>;
      final tools = result['tools'] as List<Object?>;
      expect(tools, isNotEmpty);
    });

    test('tools/call validate_input should return structured content',
        () async {
      await initializeServer();

      final response = await sendRequest('tools/call', {
        'name': 'validate_input',
        'arguments': {'schema_id': 'username', 'input': 'ab'},
      });

      final result = response['result'] as Map<String, Object?>;
      final structured = result['structuredContent'] as Map<String, Object?>;
      final validation = structured['validation'] as Map<String, Object?>;

      expect(structured['ok'], isTrue);
      expect(validation['isValid'], isFalse);
      expect(validation['errorCount'], equals(1));
    });

    test('unknown method should return json-rpc error', () async {
      final response = await sendRequest('unknown/method');

      final error = response['error'] as Map<String, Object?>;
      expect(error['code'], equals(-32601));
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'mcp_tool_handlers.dart';

class ValidasiMcpStdioServer {
  const ValidasiMcpStdioServer({required this.handlers});

  final ValidasiMcpToolHandlers handlers;

  Future<void> serve() async {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.trim().isEmpty) {
        continue;
      }

      Map<String, Object?>? request;
      try {
        final decoded = jsonDecode(line);
        if (decoded is! Map) {
          stdout.writeln(jsonEncode(_jsonRpcError(
            id: null,
            code: -32600,
            message: 'Invalid Request',
          )));
          continue;
        }

        request = decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      } catch (_) {
        stdout.writeln(jsonEncode(_jsonRpcError(
          id: null,
          code: -32700,
          message: 'Parse error',
        )));
        continue;
      }

      final response = handleRequest(request);
      if (response != null) {
        stdout.writeln(jsonEncode(response));
      }
    }
  }

  Map<String, Object?>? handleRequest(Map<String, Object?> request) {
    final id = request['id'];
    final method = request['method'];
    if (method is! String) {
      return _jsonRpcError(
        id: id,
        code: -32600,
        message: 'Invalid Request',
      );
    }

    if (method == 'initialized') {
      return null;
    }

    if (method == 'initialize') {
      return <String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': <String, Object?>{
          'protocolVersion': '2024-11-05',
          'capabilities': <String, Object?>{
            'tools': <String, Object?>{},
          },
          'serverInfo': <String, Object?>{
            'name': 'validasi_mcp',
            'version': '0.1.0-beta.1',
          },
          'instructions': 'Beta server. Supports Validasi v1.0.0-dev.x only.',
        },
      };
    }

    if (method == 'tools/list') {
      return <String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': <String, Object?>{
          'tools': handlers.toolDefinitions(),
        },
      };
    }

    if (method == 'tools/call') {
      final params = _asMap(request['params']);
      final name = params['name'];
      final arguments = _asMap(params['arguments']);

      if (name is! String || name.isEmpty) {
        return _jsonRpcError(
          id: id,
          code: -32602,
          message: 'Invalid params: name is required',
        );
      }

      final toolResult = handlers.callTool(name, arguments);

      return <String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': <String, Object?>{
          'content': <Map<String, Object?>>[
            <String, Object?>{
              'type': 'text',
              'text': jsonEncode(toolResult),
            },
          ],
          'structuredContent': toolResult,
        },
      };
    }

    // Non-MCP fallback for direct method-style invocation.
    if (method == 'list_schemas' ||
        method == 'describe_schema' ||
        method == 'validate_input') {
      final params = _asMap(request['params']);
      final toolResult = handlers.callTool(method, params);
      return <String, Object?>{
        'jsonrpc': '2.0',
        'id': id,
        'result': toolResult,
      };
    }

    return _jsonRpcError(
      id: id,
      code: -32601,
      message: 'Method not found: $method',
    );
  }

  Map<String, Object?> _jsonRpcError({
    required Object? id,
    required int code,
    required String message,
  }) {
    return <String, Object?>{
      'jsonrpc': '2.0',
      'id': id,
      'error': <String, Object?>{
        'code': code,
        'message': message,
      },
    };
  }

  Map<String, Object?> _asMap(Object? value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }

    return <String, Object?>{};
  }
}

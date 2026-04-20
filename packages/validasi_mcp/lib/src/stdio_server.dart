import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

import 'mcp_tool_handlers.dart';

final class ValidasiMcpServer extends MCPServer with ToolsSupport {
  ValidasiMcpServer.fromStreamChannel(
    super.channel, {
    required this.handlers,
    super.protocolLogSink,
  }) : super.fromStreamChannel(
          implementation: Implementation(
            name: 'validasi_mcp',
            version: '0.1.0-beta.1',
          ),
          instructions: 'Beta server. Supports Validasi v1.0.0-dev.x only.',
        ) {
    _registerNonMcpFallbackHandlers();
  }

  final ValidasiMcpToolHandlers handlers;
  bool _toolsRegistered = false;

  @override
  Future<InitializeResult> initialize(InitializeRequest request) async {
    final result = await super.initialize(request);

    if (!_toolsRegistered) {
      _toolsRegistered = true;

      for (final tool in handlers.tools()) {
        registerTool(
          tool,
          (request) => _callTool(request.name, request.arguments ?? const {}),
          validateArguments: false,
        );
      }
    }

    return result;
  }

  CallToolResult _callTool(String name, Map<String, Object?> arguments) {
    final toolResult = handlers.callTool(name, arguments);

    return CallToolResult(
      content: [TextContent(text: jsonEncode(toolResult))],
      structuredContent: toolResult,
      isError: toolResult['ok'] == false,
    );
  }

  void _registerNonMcpFallbackHandlers() {
    registerRequestHandler<Request?, _JsonMapResult>('list_schemas', (request) {
      final params = _requestToArguments(request);
      return _JsonMapResult(handlers.callTool('list_schemas', params));
    });

    registerRequestHandler<Request?, _JsonMapResult>(
      'describe_schema',
      (request) {
        final params = _requestToArguments(request);
        return _JsonMapResult(handlers.callTool('describe_schema', params));
      },
    );

    registerRequestHandler<Request?, _JsonMapResult>('validate_input',
        (request) {
      final params = _requestToArguments(request);
      return _JsonMapResult(handlers.callTool('validate_input', params));
    });
  }

  Map<String, Object?> _requestToArguments(Request? request) {
    if (request == null) {
      return const <String, Object?>{};
    }

    final map = request as Map;
    return map.cast<String, Object?>();
  }
}

extension type _JsonMapResult._(Map<String, Object?> _value) implements Result {
  factory _JsonMapResult(Map<String, Object?> value) => _JsonMapResult._(value);
}

class ValidasiMcpStdioServer {
  const ValidasiMcpStdioServer({required this.handlers});

  final ValidasiMcpToolHandlers handlers;

  Future<void> serve() async {
    final server = ValidasiMcpServer.fromStreamChannel(
      stdioChannel(input: stdin, output: stdout),
      handlers: handlers,
    );

    await server.done;
  }
}

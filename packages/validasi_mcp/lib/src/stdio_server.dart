import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

import 'package:validasi_mcp/src/docs_tools.dart';
import 'package:validasi_mcp/src/docs_types.dart';

final class ValidasiMcpServer extends MCPServer
    with ToolsSupport, ResourcesSupport {
  ValidasiMcpServer.fromStreamChannel(
    super.channel, {
    required this.tools,
    required this.config,
    required this.docsPages,
  }) : super.fromStreamChannel(
          implementation: Implementation(
            name: 'validasi_mcp',
            version: '0.1.0-beta.3',
          ),
          instructions:
              'Validasi documentation assistant. Use search_docs, get_page, '
              'list_pages, and get_code_examples to browse the docs. '
              'Docs are cached locally and refreshed automatically.',
        );

  final DocsTools tools;
  final DocsConfig config;
  final List<DocPage> docsPages;

  @override
  Future<InitializeResult> initialize(InitializeRequest request) async {
    final result = await super.initialize(request);

    for (final tool in tools.tools()) {
      registerTool(
        tool,
        (request) => _callTool(request.name, request.arguments ?? const {}),
        validateArguments: false,
      );
    }

    for (final page in docsPages) {
      final uri = 'validasi-docs://${page.path}';
      addResource(
        Resource(
          uri: uri,
          name: page.title,
          description: 'Validasi documentation: ${page.path}',
          mimeType: 'text/markdown',
        ),
        (request) => ReadResourceResult(
          contents: [
            TextResourceContents(
              uri: request.uri,
              text: page.rawMarkdown,
            ),
          ],
        ),
      );
    }

    return result;
  }

  CallToolResult _callTool(String name, Map<String, Object?> arguments) {
    final result = tools.callTool(name, arguments);

    return CallToolResult(
      content: [TextContent(text: jsonEncode(result))],
      structuredContent: result,
      isError: result['ok'] == false,
    );
  }
}

class ValidasiMcpStdioServer {
  ValidasiMcpStdioServer({
    required this.tools,
    required this.config,
    required this.docsPages,
  });

  final DocsTools tools;
  final DocsConfig config;
  final List<DocPage> docsPages;

  Future<void> serve() async {
    final server = ValidasiMcpServer.fromStreamChannel(
      stdioChannel(input: stdin, output: stdout),
      tools: tools,
      config: config,
      docsPages: docsPages,
    );

    await server.done;
  }
}

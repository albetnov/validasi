import 'package:validasi_mcp/validasi_mcp.dart';

Future<void> main() async {
  final registry = SchemaRegistry();
  final handlers = ValidasiMcpToolHandlers(registry: registry);
  final server = ValidasiMcpStdioServer(handlers: handlers);

  await server.serve();
}

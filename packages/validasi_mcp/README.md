# validasi_mcp

MCP server providing Validasi documentation and API reference for AI assistants.

Fetches the Validasi VitePress docs from the hosted site, caches them locally,
and exposes them via MCP tools and resources for AI coding assistants.

## Usage

```bash
# Start the MCP stdio server
dart run bin/validasi_mcp.dart

# Clear the local cache
dart run bin/validasi_mcp.dart --clean-cache

# Force refresh all docs
dart run bin/validasi_mcp.dart --refresh

# Custom cache directory
dart run bin/validasi_mcp.dart --cache-dir /path/to/cache
```

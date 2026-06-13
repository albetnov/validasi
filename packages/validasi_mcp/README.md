# validasi_mcp

MCP server providing Validasi documentation and API reference for AI assistants.

Fetches the Validasi VitePress docs from the hosted site, caches them locally,
and exposes them via MCP tools and resources for AI coding assistants.

## Tools

| Tool | Description |
|------|-------------|
| `search_docs` | Full-text search across all documentation pages |
| `get_page` | Retrieve a full documentation page by path (e.g. `guide/getting-started`) |
| `list_pages` | List all available pages, optionally filtered by section |
| `get_code_examples` | Retrieve code examples, optionally filtered by rule or page |
| `refresh_docs` | Re-fetch all docs from the remote source and rebuild the search index |
| `clean_cache` | Delete the local documentation cache |

## Resources

Every documentation page is exposed as a `validasi-docs://{path}` resource
with `text/markdown` MIME type.

## Usage

```bash
# Start the MCP stdio server
dart run bin/validasi_mcp.dart

# Clear the local cache
dart run bin/validasi_mcp.dart --clean-cache

# Force refresh all docs
dart run bin/validasi_mcp.dart --refresh

# Custom cache directory (defaults to ./.validasi_mcp_cache/)
dart run bin/validasi_mcp.dart --cache-dir /path/to/cache

# Point to a local VitePress preview server for development
dart run bin/validasi_mcp.dart --base-url http://localhost:4173/validasi
```

## Configuration

The docs URL defaults to `https://albetnov.github.io/validasi` and can be
overridden via the `--base-url` CLI flag or `DocsConfig.baseUrl` in code.

The cache directory defaults to `.validasi_mcp_cache/` in the current working
directory (project-local). Cache entries are considered fresh for 24 hours.

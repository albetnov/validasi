## 0.1.0-beta.3

**Rewrite**: Moved from a validation-engine adapter to a documentation assistant for AI.

### Added
- `DocsFetcher` — fetches Validasi documentation pages from the hosted VitePress site via HTTP.
- `DocsIndex` — full-text search across cached documentation pages.
- `DocPageParser` — extracts titles, headings, and code blocks from Markdown.
- 6 MCP tools: `search_docs`, `get_page`, `list_pages`, `get_code_examples`, `refresh_docs`, `clean_cache`.
- `validasi-docs://` MCP resources for every documentation page.
- Disk caching with 24h TTL, `--refresh` and `--clean-cache` CLI flags.
- End-to-end integration test with snapshot comparison.

### Breaking Changes
- Removed `validasi` dependency; package no longer imports the validation engine.
- Tools `list_schemas`, `describe_schema`, `validate_input` removed.
- New tools driven by documentation content instead of runtime registry.

## 0.1.0-beta.2

First working release of the Validasi MCP adapter.

### Added
- MCP stdio server with `initialize`, `tools/list`, and `tools/call`.
- Schema registry and tool handlers for agent-native support.
- Tools for `list_schemas`, `describe_schema`, and `validate_input`.
- Non-MCP fallback RPC handlers for direct schema introspection.
- Deterministic structured validation payloads from Validasi.
- Tests for the registry, tool handlers, and stdio server.

### Changed
- ValidasiEngine updated to support dual input/output type parameterization.
- Updated package configuration and workflows for workspace integration.

### Notes
- This adapter targets Validasi `v1.0.0-dev.x`.

## 0.1.0-beta.1

Initial beta preview of the Validasi MCP adapter.

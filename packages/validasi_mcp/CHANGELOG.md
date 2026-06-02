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

### Changed
- Removed `validasi` dependency; package no longer imports the validation engine.
- Tools `list_schemas`, `describe_schema`, `validate_input` removed.
- New tools driven by documentation content instead of runtime registry.

## 0.1.0-beta.1

Initial beta release of the Validasi MCP adapter.

### Added
- MCP stdio server with `initialize`, `tools/list`, and `tools/call`.
- Schema registry and tool handlers for agent-native support.
- Tools for `list_schemas`, `describe_schema`, and `validate_input`.
- Deterministic structured validation payloads from Validasi.
- Tests for the registry, tool handlers, and stdio server.

### Changed
- Refined the `ValidasiMcpServer` implementation and tool handling.
- Updated package configuration for workspace integration and publishability.
- Added README guidance for the beta adapter workflow.

### Notes
- This adapter currently targets Validasi `v1.0.0-dev.x`.

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

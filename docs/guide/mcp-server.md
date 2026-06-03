# MCP Server

Validasi ships with an [MCP](https://modelcontextprotocol.io) (Model Context Protocol)
server that provides documentation and API reference directly to AI coding assistants.

Instead of manually copying docs into your prompt, the AI can browse the full Validasi
documentation, search for rules, find code examples — all through standard MCP tools.

## How It Works

`validasi_mcp` runs as a stdio-based MCP server. On startup it fetches the hosted
Validasi docs from `albetnov.github.io/validasi`, caches them locally, and exposes
them through MCP tools and resources.

## Setup

Install the server globally via pub.dev:

```bash
dart pub global activate validasi_mcp
```

This makes the `validasi_mcp` command available on your PATH. All integration
configs below use it directly.

## Tools

| Tool | Description |
|------|-------------|
| `search_docs` | Full-text search across all documentation pages |
| `get_page` | Retrieve a full documentation page by path |
| `list_pages` | List all available pages, optionally filtered by section |
| `get_code_examples` | Retrieve code examples, optionally filtered by rule or page |
| `refresh_docs` | Re-fetch all docs from the remote source and rebuild the search index |
| `clean_cache` | Delete the local documentation cache |

## Resources

Every documentation page is also available as a `validasi-docs://{path}` resource
with `text/markdown` MIME type, so the AI can browse them like a file system.

## Usage

```bash
# Start the server (stdio mode)
dart run bin/validasi_mcp.dart

# Force re-fetch all docs
dart run bin/validasi_mcp.dart --refresh

# Clear the local cache
dart run bin/validasi_mcp.dart --clean-cache
```

## Configuration

The cache directory defaults to `.validasi_mcp_cache/` in the current directory
(project-local). Cache entries are considered fresh for 24 hours.

The docs URL defaults to `https://albetnov.github.io/validasi` and can be
overridden in code via `DocsConfig.baseUrl`.

## Integration

### OpenCode

Add to `~/.config/opencode/opencode.jsonc` (global) or `opencode.jsonc` (project):

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "validasi_docs": {
      "type": "local",
      "command": "validasi_mcp",
      "enabled": true,
      "environment": {}
    }
  }
}
```

> Check their [docs](https://opencode.ai/docs/mcp-servers/)

### Codex CLI

```
codex mcp add validasi_docs -- validasi_mcp --force-roots-fallback
```

> Checkout their [docs](https://developers.openai.com/codex/mcp)

### Cursor

Add to `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (project):

```json
{
  "mcpServers": {
    "validasi_docs": {
      "command": "validasi_mcp"
    }
  }
}
```

> Check their [docs](https://docs.cursor.com/context/model-context-protocol#installing-mcp-servers)

### VS Code Copilot

Add to `.vscode/mcp.json` in your workspace:

```json
{
  "servers": {
    "validasi_docs": {
      "command": "validasi_mcp"
    }
  }
}
```

> Check their [docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers#_enable-mcp-support-in-vs-code)

### Claude Code

```
claude mcp add --transport stdio validasi_docs -- validasi_mcp
```

> Checkout their [Installing MCP Servers](https://code.claude.com/docs/en/mcp#installing-mcp-servers).

The AI will automatically discover the available tools and can query the
documentation as needed.

# Companion Packages

The Validasi ecosystem includes four companion packages, each solving a specific problem, plus a
set of [Claude Code Skills](/companion/skills) for anyone using Claude Code on a `validasi`
project. Use them independently or together depending on your needs.

Package stability: <Badge type="warning" text="experimental" /> packages are still evolving — API changes are expected.
<Badge type="info" text="beta" /> packages are near-stable.

## Package Map

| Package | Purpose | Status | Runtime dep? |
|---------|---------|:---:|:---:|
| [validasi](https://pub.dev/packages/validasi) | Core validation engine | — | Required |
| [validasi_annotation](https://pub.dev/packages/validasi_annotation) | Annotations for code generation (`@Validate`, `@RefineFn`, rules) | <Badge type="warning" text="experimental" /> | Codegen only |
| [validasi_gen](https://pub.dev/packages/validasi_gen) | `build_runner` generator — emit typed validators at compile time | <Badge type="warning" text="experimental" /> | Dev only |
| [validasi_ui](https://pub.dev/packages/validasi_ui) | Headless form management for Flutter (controllers, signals, widgets) | <Badge type="warning" text="experimental" /> | Flutter |
| [validasi_mcp](https://pub.dev/packages/validasi_mcp) | MCP server — AI assistant docs & API reference | <Badge type="info" text="beta" /> | Standalone |
| [Claude Code Skills](/companion/skills) | `SKILL.md` guidance for `validasi`/`validasi_gen`/`validasi_ui`, not a pub.dev package | — | Optional, `.claude/skills/` |

## Which packages do I need?

| Scenario | Packages |
|----------|----------|
| **Dart CLI / backend** with compile-time validation | `validasi` + `validasi_annotation` + `validasi_gen` |
| **Flutter app** with generated schemas (recommended) | `validasi` + `validasi_annotation` + `validasi_gen` + `validasi_ui` |
| **Flutter app** with manual field descriptors | `validasi` + `validasi_ui` |
| **Plain validation library** (no codegen, no UI) | `validasi` only |
| **AI assistant integration** | `validasi_mcp` (runtime docs lookup) and/or the [Claude Code Skills](/companion/skills) (authored guidance) |

## Relationships

```
validasi (core engine)
  ↑
  ├── validasi_annotation (markers + contracts)
  │     ↑
  │     └── validasi_gen (build_runner generator)
  │           │
  │           └── validasi_ui (form widgets, reads generated XFields)
  │
  └── validasi_mcp (standalone docs server)
```

- `validasi_annotation` provides `@ValidateClass`, `@Validate<T>`, rule annotations — consumed by `validasi_gen`.
- `validasi_gen` reads annotations at build time and emits typed field classes (`XFields<V>`) and validation extensions.
- `validasi_ui` binds those generated field classes to Flutter widgets. It also works without codegen using manual `FieldDescriptor` and `ValidasiField`.
- `validasi_mcp` is fully standalone — it fetches hosted docs and serves them as MCP tools/resources.

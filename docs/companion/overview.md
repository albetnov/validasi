# Companion Packages

The Validasi ecosystem includes three companion packages, each solving a specific problem, plus a
set of [Agent Skills](/companion/skills) — shipped inside each package and installable with
`dart run skills@ get` — for anyone using an AI coding agent on a `validasi` project. Use them
independently or together depending on your needs.

## Package Map

| Package | Purpose | Status | Runtime dep? |
|---------|---------|:---:|:---:|
| [validasi](https://pub.dev/packages/validasi) | Core validation engine | <Badge type="tip" text="stable" /> | Required |
| [validasi_annotation](https://pub.dev/packages/validasi_annotation) | Annotations for code generation (`@Validate`, `@RefineFn`, rules) | <Badge type="tip" text="stable" /> | Codegen only |
| [validasi_gen](https://pub.dev/packages/validasi_gen) | `build_runner` generator — emit typed validators at compile time | <Badge type="tip" text="stable" /> | Dev only |
| [validasi_ui](https://pub.dev/packages/validasi_ui) | Headless form management for Flutter (controllers, signals, widgets) | <Badge type="tip" text="stable" /> | Flutter |
| [Agent Skills](/companion/skills) | `SKILL.md` guidance shipped inside each package and installed with `dart run skills@ get` | — | Optional, any agent supporting `SKILL.md` |

## Which packages do I need?

| Scenario | Packages |
|----------|----------|
| **Dart CLI / backend** with compile-time validation | `validasi` + `validasi_annotation` + `validasi_gen` |
| **Flutter app** with generated schemas (recommended) | `validasi` + `validasi_annotation` + `validasi_gen` + `validasi_ui` |
| **Flutter app** with manual field descriptors | `validasi` + `validasi_ui` |
| **Plain validation library** (no codegen, no UI) | `validasi` only |
| **AI assistant integration** | [Agent Skills](/companion/skills) (authored guidance) |

## Relationships

```
validasi (core engine)
  ↑
  ├── validasi_annotation (markers + contracts)
  │     ↑
  │     └── validasi_gen (build_runner generator)
  │           │
  │           └── validasi_ui (form widgets, reads generated XFields)
```

- `validasi_annotation` provides `@ValidateClass`, `@Validate<T>`, rule annotations — consumed by `validasi_gen`.
- `validasi_gen` reads annotations at build time and emits typed field classes (`XFields<V>`) and validation extensions.
- `validasi_ui` binds those generated field classes to Flutter widgets. It also works without codegen using manual `FieldDescriptor` and `ValidasiField`.

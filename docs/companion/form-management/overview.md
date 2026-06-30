# Form Management (`validasi_ui`) <Badge type="warning" text="experimental" />

`validasi_ui` provides headless form management for Flutter, built on top of Validasi.
It brings a React Hook Form–style controller + builder pattern, using [signals](https://pub.dev/packages/signals)
for fine-grained reactivity.

`validasi` is re-exported from this package, so you do **not** need to add it as a
separate dependency.

## Setup

```bash
flutter pub add validasi_ui
```

With code generation:

```bash
flutter pub add validasi_ui validasi_annotation
flutter pub add dev:build_runner dev:validasi_gen
```

## Architecture

```
┌─────────────────────────────────────┐
│ ValidasiForm<T>                     │  InheritedWidget scope
│   ├── schema: ValidasiSchema<T>     │  ← allocates model from controller
│   ├── mode: onSubmit / onBlur / onChange
│   └── controller: ValidasiFormController<T>   (auto-created)
│         │
│         ├── signals (dirty, touched, errors)
│         ├── values (per-field, typed)
│         └── validation (sync + async)
│
└── children ──────────────────────────┘
      │
      ├── ValidasiTextField<T, String>    (text input convenience)
      │     └── builder: (ctx, state, TextEditingController) => Widget
      │
      ├── ValidasiFormField<T, int>       (generic field binding)
      │     └── builder: (ctx, state) => Widget
      │
      └── ValidasiWatch.field<T, V>       (reactive value display)
            └── builder: (ctx, value) => Widget
```

## Key types

| Type | Role |
|------|------|
| `ValidasiForm<T>` | Root widget — creates + scopes a `ValidasiFormController<T>` |
| `ValidasiFormController<T>` | State manager — values, errors, dirty/touched, validate, submit |
| `ValidasiFormField<T, V>` | Binds a `ValidasiField<T, V>` to a builder; reactive |
| `ValidasiTextField<T, V>` | `ValidasiFormField` + auto `TextEditingController` lifecycle |
| `ValidasiFieldState<V>` | Typed value + errors passed to `builder` |
| `ValidasiTextController` | `TextEditingController` subclass for text field sync |

## Two usage patterns

1. **[With Codegen](/companion/form-management/with-codegen)** (recommended) — annotate your model with `@ValidateClass`, run `build_runner`, use generated `XFields` and `schema`.

2. **[Without Codegen](/companion/form-management/without-codegen)** — define `FieldDescriptor` and `ValidasiField` manually. No annotations, no build_runner.

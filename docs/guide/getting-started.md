# Getting Started

::: warning 📢 v1.0.0-dev Documentation
You are viewing the documentation for **Validasi v1.0.0-dev** (development version). Looking for the stable version? [View v0 Documentation →](/v0/)
:::

Welcome to Validasi! This guide will help you get started with the most flexible and type-safe validation library for Dart and Flutter.

## What is Validasi?

<GradientText>Validasi</GradientText> is a powerful validation library that brings type safety, composability, and elegance to data validation in Dart and Flutter applications. Whether you're validating user input, API responses, or configuration files, Validasi makes it simple and maintainable.

## Key Features

::: tip Type Safety First
Validasi is built with Dart's type system in mind, providing full type safety throughout your validation logic. No more runtime surprises!
:::

::: info Composable & Reusable
Create complex validation schemas from simple, reusable rules. Mix and match rules to build exactly what you need.
:::

::: warning Performance Optimized
Through a series of optimizations, your validations run fast, even when validating thousands of objects.
:::

## Why Choose Validasi?

### 🎯 Intuitive API

```dart
final schema = Validasi.string([
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
]);

final result = schema.validate('Hello');
```

Simple, readable, and self-documenting code.

### 🔧 Comprehensive Rules

Built-in rules for every common validation scenario:

- String validation (length, patterns, formats)
- Number validation (ranges, comparisons)
- Collection validation (lists, maps)
- Custom validation (inline rules, transformations)

### 🌲 Nested Validation

Validate complex, nested data structures with ease:

```dart
final userSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'profile': FieldRules<Map<String, dynamic>>([
      Rules.map.hasFields({
        'name': FieldRules<String>([Rules.string.minLength(2)]),
        'age': FieldRules<int>([Rules.number.moreThan(0)]),
      }),
    ]),
  }),
]);
```

### 🎨 Flexible Transformations

Transform data during validation:

```dart
final schema = Validasi.string([
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.minLength(3),
]);
```

### ✅ Type-Safe Input Handling

Validasi uses dual generics to enforce input type safety at compile time. When you need to accept different input types (e.g., strings from APIs), use `withPreprocess`:

```dart
// Accept String input, validate as int
final ageSchema = Validasi.number<int>([
  Rules.number.moreThan(0),
  Rules.number.lessThan(150),
]).withPreprocess((String value) => int.parse(value));

// validate() now only accepts String at compile time
final result = ageSchema.validate('25'); // ✓ Correct type
// ageSchema.validate(25);               // ✗ Compile error
```

**When to use `withPreprocess`:**

- Accepting data from JSON, APIs, or form inputs (usually strings)
- Converting between types in a type-safe way
- Building flexible schemas that accept specific input types

Read more in the [Transformations Guide](/guide/transformations.md) and [Engine Architecture](/advanced/engine.md).

## Companion Packages

Validasi also ships with two companion packages:

- **`validasi_annotation` + `validasi_gen`** *(experimental)* — annotation-based code generation. Decorate your model with `@ValidateClass()` and `@Validate()`, and the generator produces a typed `XFields<V>` hierarchy plus `validate()` / `validateAsync()` extension. No Runtime codegen — the generator runs at build time via `build_runner`.
- **`validasi_ui`** *(experimental)* — headless form management for Flutter. A `ValidasiFormController<T>` bridges generated schemas to the widget tree with hooks-style ergonomics: `watch`, `watchField`, `setError`, `formErrors`. Pair it with `validasi_gen` using `generateFields: true`, `generateAssemble: true`, and `generateValidateForm: true` for a fully type-safe form experience.

::: warning Experimental
Both `validasi_gen` and `validasi_ui` are in active development. APIs may change without a major version bump. Feedback and contributions are welcome!
:::

See the dedicated guides for detailed usage:

- [Code Generation](/guide/code-generation) — using `validasi_annotation` + `validasi_gen`
- [Form Management](/guide/form-management) — using `validasi_ui` for Flutter forms

## Community & Support

- **GitHub**: [albetnov/validasi](https://github.com/albetnov/validasi)
- **Issues**: [Report bugs or request features](https://github.com/albetnov/validasi/issues)
- **Pub.dev**: [Package documentation](https://pub.dev/packages/validasi)

## LLM Support

This documentation has support for LLMS, you can click the button at the bottom right corner to copy or download the current page as markdown file for your LLM processing. Or you can visit [`llms-full.txt`](/llms-full.txt) or [`llms.txt`](/llms.txt) files.

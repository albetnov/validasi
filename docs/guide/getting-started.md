# Getting Started

::: warning 📢 v1.0.0-dev Documentation
You are viewing the documentation for **Validasi v1.0.0-dev** (development version). This version includes significant API changes and new features. Looking for the stable version? [View v0 Documentation →](/v0/)
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
Built-in caching system ensures your validations run fast, even when validating thousands of objects.
:::

## Why Choose Validasi?

### 🎯 Intuitive API

```dart
final schema = Validasi.string([
  StringRules.minLength(3),
  StringRules.maxLength(20),
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
  MapRules.hasFields({
    'profile': Validasi.map<dynamic>([
      MapRules.hasFields({
        'name': Validasi.string([StringRules.minLength(2)]),
        'age': Validasi.number<int>([NumberRules.moreThan(0)]),
      }),
    ]),
  }),
]);
```

### 🎨 Flexible Transformations

Transform data during validation:

```dart
final schema = Validasi.string([
  Transform((value) => value?.trim().toLowerCase()),
  StringRules.minLength(3),
]);
```

## Next Steps

Ready to dive in? Check out:

- [Installation Guide](/guide/installation) - Add Validasi to your project
- [Quick Start](/guide/quick-start) - Build your first validation schema
- [String Examples](/examples/string-validation) - See practical examples

## Community & Support

- **GitHub**: [albetnov/validasi](https://github.com/albetnov/validasi)
- **Issues**: [Report bugs or request features](https://github.com/albetnov/validasi/issues)
- **Pub.dev**: [Package documentation](https://pub.dev/packages/validasi)

---

<div style="text-align: center; margin-top: 3rem;">
  <a href="/guide/installation" class="vp-button vp-button-brand">Get Started →</a>
</div>

---
layout: home

hero:
  name: "Validasi"
  text: "Type-Safe Validation for Dart & Flutter"
  tagline: A flexible, composable, and type-safe validation library that makes data validation elegant and effortless
  image:
    src: /logo.png
    alt: Validasi Logo
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/albetnov/validasi
    - theme: alt
      text: API Reference
      link: https://pub.dev/documentation/validasi/latest

features:
  - icon: 🎯
    title: Type-Safe & Composable
    details: Built with type safety in mind. Compose validation rules with ease and get full IntelliSense support throughout your codebase.
  
  - icon: ⚡
    title: High Performance
    details: Optimized with built-in caching system for maximum performance. Validate thousands of objects without breaking a sweat.
  
  - icon: 🎨
    title: Flexible Transformations
    details: Transform and preprocess data during validation. Clean, trim, normalize - all in one seamless flow.
  
  - icon: 🔌
    title: Extensible
    details: Create custom rules with InlineRule or Having. Extend the library to fit your specific needs perfectly.

  - icon: 🤖
    title: Agent-Native Ready
    details: Export introspectable schema metadata and deterministic validation payloads for AI tools and automation.
---

<VersionBanner
  type="warning"
  icon="📢"
  title="v1.0.0-dev Documentation"
  message="You are viewing the documentation for Validasi v1.0.0-dev (development version). This version includes significant API changes and new features."
  link="/v0/"
  linkText="View v0 Documentation"
/>

## Quick Example

Get started with Validasi in seconds:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

// Define your validation schema
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(50),
    ]),
    'email': Validasi.string([
      StringRules.email(),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(18),
      NumberRules.lessThan(100),
    ]),
  }),
]);

// Validate your data
final result = userSchema.validate({
  'name': 'John Doe',
  'email': 'john@example.com',
  'age': 25,
});

if (result.isValid) {
  print('Validation passed! Data: ${result.data}');
} else {
  print('Errors: ${result.errors.map((e) => e.message)}');
}
```

## Why Validasi?

::: tip Elegant API Design
Validasi provides an intuitive, fluent API that makes validation code readable and maintainable. No more messy validation logic scattered throughout your codebase.
:::

::: info Production Ready
Battle-tested in production applications. Validasi handles edge cases gracefully and provides clear error messages for better debugging.
:::

::: warning Performance Matters
With built-in caching and optimization, Validasi is designed for high-performance scenarios where validation speed is critical.
:::

## Installation

Add Validasi to your `pubspec.yaml`:

```yaml
dependencies:
  validasi: ^1.0.0-dev.0
```

Then run:

```bash
dart pub get
# or for Flutter
flutter pub get
```

## Ready to dive deeper?

<div class="vp-doc" style="margin-top: 2rem;">
  <a href="/guide/getting-started" class="vp-button vp-button-brand" style="margin-right: 1rem;">Read the Guide</a>
  <a href="/guide/agent-native-support" class="vp-button vp-button-alt">Agent-Native Guide</a>
</div>


# Any Schema

Use `Validasi.any<T>()` when you want full flexibility over the value type and validation strategy.

Under the hood, all schema builders use the same engine (`ValidasiEngine<T, TInput>`). By default, `TInput` equals `T`, but you can use `withPreprocess()` to accept a different input type. `Validasi.any<T>()` is the most direct and generic form of that engine.

That means if your generic type `T` matches a rule type, it works out of the box.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final boolSchema = Validasi.any<bool>([
	Required(),
]);

print(boolSchema.validate(true).isValid); // true
print(boolSchema.validate(null).isValid); // false
```

## When to Use Any

Use `Validasi.any<T>()` when:

- your type is not covered by specialized schema builders
- you need validation for custom domain models
- you need flexible map/object validation outside `Map<String, T>`

Example for non-String key maps:

```dart
final intKeyMapSchema = Validasi.any<Map<int, String>>([
	InlineRule<Map<int, String>>(
		(value) => value != null && value.containsKey(1),
		message: 'Map must contain key 1',
		name: 'contains_key_1',
	),
]);

print(intKeyMapSchema.validate({1: 'ok'}).isValid); // true
print(intKeyMapSchema.validate({2: 'no'}).isValid); // false
```

## InlineRule with Any

`InlineRule` is the most common way to add straightforward custom validation.

```dart
final scoreSchema = Validasi.any<int>([
	InlineRule<int>(
		(value) => value != null && value >= 0 && value <= 100,
		message: 'Score must be between 0 and 100',
		name: 'score_range',
	),
]);

print(scoreSchema.validate(88).isValid); // true
print(scoreSchema.validate(120).isValid); // false
```

## Dedicated Custom Rules with Any

For reusable or more complex logic, create a custom rule class (documented separately) and use it with `Validasi.any<T>()`.

```dart
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class AdultAgeRule extends Rule<int> {
	const AdultAgeRule({super.message});

	@override
	void apply(ValidationContext<int> context) {
		if (context.requireValue < 18) {
			context.addError(
				ValidationError(
					rule: 'adult_age',
					message: message ?? 'Age must be 18 or older',
				),
			);
		}
	}
}

final ageSchema = Validasi.any<int>([
	const AdultAgeRule(),
]);

print(ageSchema.validate(21).isValid); // true
print(ageSchema.validate(16).isValid); // false
```

## Combining Modifier Rules

`Any` also works with modifier rules like `Nullable`, `Required`, and `Transform`.

```dart
final normalizedCodeSchema = Validasi.any<String>([
	Nullable(),
	Transform((value) => value?.trim().toUpperCase()),
	InlineRule<String>(
		(value) => value == null || value.startsWith('SKU-'),
		message: 'Code must start with SKU-',
		name: 'sku_prefix',
	),
]);

print(normalizedCodeSchema.validate('  sku-001  ').data); // SKU-001
```

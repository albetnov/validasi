# Any Schema

Use `Validasi.any<T>()` when you want full flexibility over the value type and validation strategy.

Under the hood, all schema builders use the same engine (`ValidasiEngine<T, TInput>`). By default, `TInput` equals `T`, but you can use `withPreprocess()` to accept a different input type. `Validasi.any<T>()` is the most direct and generic form of that engine.

That means if your generic type `T` matches a rule type, it works out of the box.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final boolSchema = Validasi.any<bool>([
	Rules.required(),
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
	Rules.inline<Map<int, String>>(
		(value) => value != null && value.containsKey(1),
		message: 'Map must contain key 1',
	),
]);

print(intKeyMapSchema.validate({1: 'ok'}).isValid); // true
print(intKeyMapSchema.validate({2: 'no'}).isValid); // false
```

## Available Rules

### Rules.equals

Ensures the value equals a specific value.

```dart
final statusSchema = Validasi.any<String>([
	Rules.equals('active'),
]);

print(statusSchema.validate('active').isValid); // true
print(statusSchema.validate('inactive').isValid); // false
```

For custom equality:

```dart
final userSchema = Validasi.any<Map<String, dynamic>>([
	Rules.equals(
		{'id': 1},
		equals: (a, b) => a['id'] == b['id'],
	),
]);
```

### Rules.notEquals

Ensures the value does not equal a specific value.

```dart
final nonZeroSchema = Validasi.any<int>([
	Rules.notEquals(0),
]);

print(nonZeroSchema.validate(42).isValid); // true
print(nonZeroSchema.validate(0).isValid); // false
```

### Rules.anyOf

Ensures the value satisfies at least one of the given rule sets (OR logic).

```dart
final flexibleSchema = Validasi.any<String>([
	Rules.anyOf([
		[Rules.string.minLength(10)],
		[Rules.string.startsWith('special-')],
	]),
]);

print(flexibleSchema.validate('a long enough string').isValid); // true
print(flexibleSchema.validate('special-ok').isValid); // true
print(flexibleSchema.validate('short').isValid); // false
```

This is useful for "either/or" validation scenarios without dropping to `InlineRule`.

## InlineRule with Any

`InlineRule` is the most common way to add straightforward custom validation.

```dart
final scoreSchema = Validasi.any<int>([
	Rules.inline<int>(
		(value) => value != null && value >= 0 && value <= 100,
		message: 'Score must be between 0 and 100',
	),
]);

print(scoreSchema.validate(88).isValid); // true
print(scoreSchema.validate(120).isValid); // false
```

## Dedicated Custom Rules with Any

For reusable or more complex logic, create a custom rule class (documented separately) and use it with `Validasi.any<T>()`.

```dart
import 'package:validasi/validasi.dart';

class AdultAgeRule extends Rule<int> {
	const AdultAgeRule({super.message});

	@override
	int? apply(int? value, ValidationState state) {
		if (value == null) return null;
		if (value < 18) {
			state.addError(
				ValidationError(
					rule: 'adult_age',
					message: message ?? 'Age must be 18 or older',
				),
			);
		}
		return value;
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
	Rules.nullable(),
	Rules.transform((value) => value?.trim().toUpperCase()),
	Rules.inline<String>(
		(value) => value == null || value.startsWith('SKU-'),
		message: 'Code must start with SKU-',
	),
]);

print(normalizedCodeSchema.validate('  sku-001  ').data); // SKU-001
```

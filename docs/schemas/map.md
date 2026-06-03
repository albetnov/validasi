# Map Schema

Use `Validasi.map<T>()` to validate map/object values.

`Validasi.map<T>()` is limited to `Map<String, T>`.

- Keys must be `String`.
- Values are typed as `T`.

If your map uses non-String keys (for example `Map<int, String>`), do not use `Validasi.map`. Use `Validasi.any` instead for more flexible custom validation.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final userSchema = Validasi.map<dynamic>([
	Rules.map.hasFieldKeys({'name', 'email'}),
]);
```

## Available Rules

### Rules.map.hasFieldKeys

Ensures required keys exist in the map.

```dart
final configSchema = Validasi.map<dynamic>([
	Rules.map.hasFieldKeys({'host', 'port'}),
]);

print(configSchema.validate({'host': 'localhost', 'port': 8080}).isValid); // true
print(configSchema.validate({'host': 'localhost'}).isValid); // false
```

### Rules.map.hasFields

Validates specific fields using `FieldRules` per field.

```dart
final profileSchema = Validasi.map<dynamic>([
	Rules.map.hasFields({
		'name': FieldRules<String>([
			Rules.string.minLength(2),
		]),
		'age': FieldRules<int>([
			Rules.number.moreThanEqual(18),
		]),
	}),
]);

print(profileSchema.validate({'name': 'Alice', 'age': 25}).isValid); // true
print(profileSchema.validate({'name': 'A', 'age': 16}).isValid); // false
```

### Rules.map.conditionalField

Adds conditional validation based on the map context.

```dart
final shippingSchema = Validasi.map<dynamic>([
	Rules.map.hasFieldKeys({'isDelivery'}),
	Rules.map.conditionalField('address', (context, value) {
		final isDelivery = context.get<bool>('isDelivery') ?? false;
		if (isDelivery && (value == null || value.toString().isEmpty)) {
			return 'address is required when isDelivery is true';
		}
		return null;
	}),
]);

print(shippingSchema.validate({
	'isDelivery': true,
	'address': 'Main Street',
}).isValid); // true

print(shippingSchema.validate({
	'isDelivery': true,
}).isValid); // false
```

## Nested Map Validation

You can compose nested map schemas by putting `HasFields` inside `FieldRules<Map<String, dynamic>>(...)`.

```dart
final userSchema = Validasi.map<dynamic>([
	Rules.map.hasFields({
		'profile': FieldRules<Map<String, dynamic>>([
			Rules.map.hasFields({
				'name': FieldRules<String>([
					Rules.string.minLength(2),
				]),
				'age': FieldRules<int>([
					Rules.number.moreThanEqual(0),
				]),
			}),
		]),
	}),
]);

print(userSchema.validate({
	'profile': {'name': 'John', 'age': 30},
}).isValid); // true

print(userSchema.validate({
	'profile': {'name': '', 'age': -1},
}).isValid); // false
```

## Combining Map Rules

Use map rules together to validate shape, fields, and conditional requirements.

```dart
final orderSchema = Validasi.map<dynamic>([
	Rules.map.hasFieldKeys({'id', 'isDelivery'}),
	Rules.map.hasFields({
		'id': FieldRules<String>([
			Rules.string.minLength(1),
		]),
	}),
	Rules.map.conditionalField('address', (context, value) {
		if ((context.get<bool>('isDelivery') ?? false) && value == null) {
			return 'address is required for delivery orders';
		}
		return null;
	}),
]);

final result = orderSchema.validate({
	'id': 'ORD-001',
	'isDelivery': false,
});

print(result.isValid); // true
```

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
	MapRules.hasFieldKeys({'name', 'email'}),
]);
```

## Available Rules

### MapRules.hasFieldKeys

Ensures required keys exist in the map.

```dart
final configSchema = Validasi.map<dynamic>([
	MapRules.hasFieldKeys({'host', 'port'}),
]);

print(configSchema.validate({'host': 'localhost', 'port': 8080}).isValid); // true
print(configSchema.validate({'host': 'localhost'}).isValid); // false
```

### MapRules.hasFields

Validates specific fields using `FieldRules` per field.

```dart
final profileSchema = Validasi.map<dynamic>([
	MapRules.hasFields({
		'name': FieldRules<String>([
			StringRules.minLength(2),
		]),
		'age': FieldRules<int>([
			NumberRules.moreThanEqual(18),
		]),
	}),
]);

print(profileSchema.validate({'name': 'Alice', 'age': 25}).isValid); // true
print(profileSchema.validate({'name': 'A', 'age': 16}).isValid); // false
```

### MapRules.conditionalField

Adds conditional validation based on the map context.

```dart
final shippingSchema = Validasi.map<dynamic>([
	MapRules.hasFieldKeys({'isDelivery'}),
	MapRules.conditionalField('address', (context, value) {
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
	MapRules.hasFields({
		'profile': FieldRules<Map<String, dynamic>>([
			MapRules.hasFields({
				'name': FieldRules<String>([
					StringRules.minLength(2),
				]),
				'age': FieldRules<int>([
					NumberRules.moreThanEqual(0),
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
	MapRules.hasFieldKeys({'id', 'isDelivery'}),
	MapRules.hasFields({
		'id': FieldRules<String>([
			StringRules.minLength(1),
		]),
	}),
	MapRules.conditionalField('address', (context, value) {
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

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

### Rules.map.allowedKeys

Ensures the map only contains allowed keys (whitelist).

```dart
final strictSchema = Validasi.map<dynamic>([
	Rules.map.allowedKeys({'name', 'email'}),
]);

print(strictSchema.validate({'name': 'Alice'}).isValid); // true
print(strictSchema.validate({'name': 'Alice', 'unknown': 'field'}).isValid); // false
```

### Rules.map.forbiddenKeys

Ensures the map does not contain forbidden keys (blacklist).

```dart
final secureSchema = Validasi.map<dynamic>([
	Rules.map.forbiddenKeys({'password', 'secret'}),
]);

print(secureSchema.validate({'name': 'Alice'}).isValid); // true
print(secureSchema.validate({'name': 'Alice', 'password': '123'}).isValid); // false
```

### Rules.map.minKeys

Ensures the map has at least the given number of keys.

```dart
final minKeysSchema = Validasi.map<dynamic>([
	Rules.map.minKeys(2),
]);

print(minKeysSchema.validate({'a': 1, 'b': 2}).isValid); // true
print(minKeysSchema.validate({'a': 1}).isValid); // false
```

### Rules.map.maxKeys

Ensures the map has at most the given number of keys.

```dart
final maxKeysSchema = Validasi.map<dynamic>([
	Rules.map.maxKeys(2),
]);

print(maxKeysSchema.validate({'a': 1, 'b': 2}).isValid); // true
print(maxKeysSchema.validate({'a': 1, 'b': 2, 'c': 3}).isValid); // false
```

### Rules.map.allValues

Validates all values in the map using the same rules. Similar to `forEach` for lists.

```dart
final allPositiveSchema = Validasi.map<int>([
	Rules.map.allValues<int>([
		Rules.number.moreThanEqual(0),
	]),
]);

print(allPositiveSchema.validate({'a': 1, 'b': 2}).isValid); // true
print(allPositiveSchema.validate({'a': 1, 'b': -1}).isValid); // false
```

### Rules.map.requiredAny

Ensures at least one of the specified fields is present.

```dart
final contactSchema = Validasi.map<dynamic>([
	Rules.map.requiredAny(['email', 'phone']),
]);

print(contactSchema.validate({'email': 'test@example.com'}).isValid); // true
print(contactSchema.validate({'name': 'Alice'}).isValid); // false
```

### Rules.map.requiredOneOf

Ensures exactly one of the specified fields is present (XOR).

```dart
final identitySchema = Validasi.map<dynamic>([
	Rules.map.requiredOneOf(['name', 'username']),
]);

print(identitySchema.validate({'name': 'Alice'}).isValid); // true
print(identitySchema.validate({'name': 'Alice', 'username': 'alice123'}).isValid); // false
print(identitySchema.validate({}).isValid); // false
```

### Rules.map.requiredAll

Ensures all specified fields are present if any of them is present.

```dart
final passwordSchema = Validasi.map<dynamic>([
	Rules.map.requiredAll(['password', 'passwordConfirm']),
]);

print(passwordSchema.validate({'password': '123', 'passwordConfirm': '123'}).isValid); // true
print(passwordSchema.validate({'password': '123'}).isValid); // false
print(passwordSchema.validate({}).isValid); // true (none present)
```

### Rules.map.dependsOn

Ensures that if field A is present, field B must also be present.

```dart
final addressSchema = Validasi.map<dynamic>([
	Rules.map.dependsOn('city', 'country'),
]);

print(addressSchema.validate({'city': 'NYC', 'country': 'USA'}).isValid); // true
print(addressSchema.validate({'city': 'NYC'}).isValid); // false
print(addressSchema.validate({'country': 'USA'}).isValid); // true
```

### Rules.map.mutuallyExclusive

Ensures two fields cannot both be present.

```dart
final pricingSchema = Validasi.map<dynamic>([
	Rules.map.mutuallyExclusive('discount', 'memberPrice'),
]);

print(pricingSchema.validate({'discount': '10%'}).isValid); // true
print(pricingSchema.validate({'discount': '10%', 'memberPrice': '9.99'}).isValid); // false
```

### Rules.map.matchesField

Ensures two fields have equal values.

```dart
final confirmPasswordSchema = Validasi.map<dynamic>([
	Rules.map.matchesField('password', 'passwordConfirm'),
]);

print(confirmPasswordSchema.validate({
	'password': 'secret',
	'passwordConfirm': 'secret',
}).isValid); // true

print(confirmPasswordSchema.validate({
	'password': 'secret',
	'passwordConfirm': 'different',
}).isValid); // false
```

For custom equality:

```dart
final matchByIdSchema = Validasi.map<dynamic>([
	Rules.map.matchesField(
		'userA',
		'userB',
		equals: (a, b) => a['id'] == b['id'],
	),
]);
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

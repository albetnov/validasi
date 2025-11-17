# Map Rules

Map and object validation rules for structured data.

## MapRules.hasFields()

Validates that a map contains specific fields with their own validation schemas.

### Syntax

```dart
MapRules.hasFields<T>(Map<String, ValidasiEngine<T>> validator)
```

### Parameters

- **`T`** - The type of values in the map
- **`validator`** (`Map<String, ValidasiEngine<T>>`, required) - A map of field names to their validation schemas

### Example

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([StringRules.minLength(1)]),
    'email': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
    ]),
    'age': Validasi.number<int>([
      Nullable(),
      NumberRules.moreThanEqual(0),
    ]),
  }),
]);

final result = userSchema.validate({
  'name': 'John',
  'email': '  USER@EXAMPLE.COM  ',
  'age': null,
});

print(result.isValid); // true
print(result.data['email']); // 'user@example.com'
```

## MapRules.hasFieldKeys()

Validates that a map contains all required keys (without validating their values).

### Syntax

```dart
MapRules.hasFieldKeys<T>(Set<String> keys)
```

### Parameters

- **`T`** - The type of values in the map
- **`keys`** (`Set<String>`, required) - Set of required field names

### Example

```dart
final configSchema = Validasi.map<dynamic>([
  MapRules.hasFieldKeys({'api_key', 'endpoint', 'timeout'}),
]);

// Valid - has all required keys
print(configSchema.validate({
  'api_key': 'abc123',
  'endpoint': 'https://api.example.com',
  'timeout': 30,
  'extra': 'allowed', // Extra fields are OK
}).isValid); // true

// Invalid - missing keys
print(configSchema.validate({
  'api_key': 'abc123',
}).isValid); // false
```

## MapRules.conditionalField()

Validates a field based on the values of other fields in the map (conditional validation).

### Syntax

```dart
MapRules.conditionalField<T>(
  String field,
  ConditionalFieldCallback<T> callback
)
```

**Callback Signature:**
```dart
typedef ConditionalFieldCallback<T> = String? Function(
  ValidationContext context,
  T? value,
);
```

### Parameters

- **`T`** - The type of the field value
- **`field`** (String, required) - The name of the field to conditionally validate
- **`callback`** (`ConditionalFieldCallback<T>`, required) - Function that returns error message or null

### Example

```dart
final orderSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'is_delivery': Validasi.any<bool>(),
    'address': Validasi.string([
      Nullable(),
      StringRules.minLength(10),
    ]),
  }),
  MapRules.conditionalField('address', (context, value) {
    if (context.get('is_delivery') == true && value == null) {
      return 'Address is required for delivery orders';
    }
    return null;
  }),
]);

// Valid - delivery with address
print(orderSchema.validate({
  'is_delivery': true,
  'address': '123 Main Street, City',
}).isValid); // true

// Invalid - delivery without address
print(orderSchema.validate({
  'is_delivery': true,
  'address': null,
}).isValid); // false
```

## See Also

- [Map Validation Examples](/examples/map-validation)
- [Complex Structures Examples](/examples/complex-structures)

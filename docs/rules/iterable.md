# Iterable Rules

List and iterable validation rules for collections.

## IterableRules.minLength()

Validates that an iterable (list, set, etc.) has a minimum number of elements.

### Syntax

```dart
IterableRules.minLength<T>(int length, {String? message})
```

### Parameters

- **`T`** - The type of elements in the iterable
- **`length`** (int, required) - The minimum number of elements required
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Minimum length is {length} items"
```

### Example

```dart
final tagsSchema = Validasi.list<String>([
  IterableRules.minLength(1, message: 'At least one tag is required'),
]);

print(tagsSchema.validate([]).isValid); // false
print(tagsSchema.validate(['dart']).isValid); // true
```

## IterableRules.forEach()

Validates each element in an iterable using a specified schema.

### Syntax

```dart
IterableRules.forEach<T>(ValidasiEngine<T> validator)
```

### Parameters

- **`T`** - The type of elements in the iterable
- **`validator`** (`ValidasiEngine<T>`, required) - The validation schema to apply to each element

### Example

```dart
final emailsSchema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      InlineRule<String>((value) {
        return value.contains('@') ? null : 'Invalid email';
      }),
    ])
  ),
]);

final result = emailsSchema.validate(['JOHN@EXAMPLE.COM', 'JANE@EXAMPLE.COM']);
print(result.isValid); // true
print(result.data); // ['john@example.com', 'jane@example.com']
```

## See Also

- [List Validation Examples](/examples/list-validation)

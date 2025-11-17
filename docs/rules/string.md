# String Rules

String validation rules for text input validation.

## StringRules.minLength()

Validates that a string has a minimum length.

### Syntax

```dart
StringRules.minLength(int length, {String? message})
```

### Parameters

- **length** (int, required) - The minimum number of characters required
- **message** (String?, optional) - Custom error message

### Default Error Message

```
"Minimum length is {length} characters"
```

### Example

```dart
final usernameSchema = Validasi.string([
  StringRules.minLength(3, message: 'Username must be at least 3 characters'),
]);

print(usernameSchema.validate('ab').isValid); // false
print(usernameSchema.validate('abc').isValid); // true
```

## StringRules.maxLength()

Validates that a string does not exceed a maximum length.

### Syntax

```dart
StringRules.maxLength(int length, {String? message})
```

### Parameters

- **length** (int, required) - The maximum number of characters allowed
- **message** (String?, optional) - Custom error message

### Default Error Message

```
"Maximum length is {length} characters"
```

### Example

```dart
final bioSchema = Validasi.string([
  StringRules.maxLength(500, message: 'Bio cannot exceed 500 characters'),
]);

print(bioSchema.validate('Hello').isValid); // true
print(bioSchema.validate('a' * 501).isValid); // false
```

## StringRules.oneOf()

Validates that a string matches one of the allowed values (whitelist validation).

### Syntax

```dart
StringRules.oneOf(List<String> validValues, {String? message})
```

### Parameters

- **`validValues`** (`List<String>`, required) - List of allowed string values
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be one of: {validValues}"
```

### Example

```dart
final statusSchema = Validasi.string([
  StringRules.oneOf(
    ['active', 'inactive', 'pending'],
    message: 'Invalid status',
  ),
]);

print(statusSchema.validate('active').isValid); // true
print(statusSchema.validate('deleted').isValid); // false
```

## See Also

- [String Validation Examples](/examples/string-validation)

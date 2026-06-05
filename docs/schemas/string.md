# String Schema

Use `Validasi.string()` to validate string values.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.string([
	Rules.string.minLength(3),
]);
```

## Available Rules

### Rules.string.minLength

Ensures the string has at least the given number of characters.

```dart
final usernameSchema = Validasi.string([
	Rules.string.minLength(3),
]);

print(usernameSchema.validate('al').isValid); // false
print(usernameSchema.validate('alex').isValid); // true
```

### Rules.string.maxLength

Ensures the string does not exceed the given number of characters.

```dart
final titleSchema = Validasi.string([
	Rules.string.maxLength(10),
]);

print(titleSchema.validate('short').isValid); // true
print(titleSchema.validate('this title is too long').isValid); // false
```

### Rules.string.oneOf

Ensures the string matches one of the allowed values.

```dart
final statusSchema = Validasi.string([
	Rules.string.oneOf(['draft', 'published', 'archived']),
]);

print(statusSchema.validate('published').isValid); // true
print(statusSchema.validate('deleted').isValid); // false
```

### Rules.string.startsWith

Ensures the string starts with the given prefix.

```dart
final schema = Validasi.string([
	Rules.string.startsWith('hello'),
]);

print(schema.validate('hello world').isValid); // true
print(schema.validate('world hello').isValid); // false
```

### Rules.string.endsWith

Ensures the string ends with the given suffix.

```dart
final schema = Validasi.string([
	Rules.string.endsWith('.com'),
]);

print(schema.validate('example.com').isValid); // true
print(schema.validate('example.org').isValid); // false
```

### Rules.string.contains

Ensures the string contains the given substring.

```dart
final schema = Validasi.string([
	Rules.string.contains('@'),
]);

print(schema.validate('user@example.com').isValid); // true
print(schema.validate('userexample.com').isValid); // false
```

### Rules.string.regex

Ensures the string matches the given regular expression pattern.

```dart
final schema = Validasi.string([
	Rules.string.regex(r'^[A-Z]{3}-\d{4}$'),
]);

print(schema.validate('ABC-1234').isValid); // true
print(schema.validate('abc-1234').isValid); // false
```

### Rules.string.lowercase

Ensures the string contains only lowercase characters.

```dart
final schema = Validasi.string([
	Rules.string.lowercase(),
]);

print(schema.validate('hello').isValid); // true
print(schema.validate('Hello').isValid); // false
```

### Rules.string.uppercase

Ensures the string contains only uppercase characters.

```dart
final schema = Validasi.string([
	Rules.string.uppercase(),
]);

print(schema.validate('HELLO').isValid); // true
print(schema.validate('Hello').isValid); // false
```

### Rules.string.alpha

Ensures the string contains only alphabetic characters (a-z, A-Z).

```dart
final schema = Validasi.string([
	Rules.string.alpha(),
]);

print(schema.validate('Hello').isValid); // true
print(schema.validate('Hello123').isValid); // false
```

### Rules.string.alphanumeric

Ensures the string contains only alphanumeric characters (a-z, A-Z, 0-9).

```dart
final schema = Validasi.string([
	Rules.string.alphanumeric(),
]);

print(schema.validate('Hello123').isValid); // true
print(schema.validate('Hello-123').isValid); // false
```

### Rules.string.numeric

Ensures the string contains only numeric digits (0-9).

```dart
final schema = Validasi.string([
	Rules.string.numeric(),
]);

print(schema.validate('12345').isValid); // true
print(schema.validate('123.45').isValid); // false
```

### Rules.string.uuid

Ensures the string is a valid UUID. By default, accepts UUID v4 and v7.

```dart
final schema = Validasi.string([
	Rules.string.uuid(),
]);

print(schema.validate('550e8400-e29b-41d4-a716-446655440000').isValid); // true
print(schema.validate('not-a-uuid').isValid); // false

// Restrict to specific versions
final v4Only = Validasi.string([
	Rules.string.uuid(versions: [4]),
]);
```

### Rules.string.ulid

Ensures the string is a valid ULID (Universally Unique Lexicographically Sortable Identifier).

```dart
final schema = Validasi.string([
	Rules.string.ulid(),
]);

print(schema.validate('01ARZ3NDEKTSV4RRFFQ69G5FAV').isValid); // true
print(schema.validate('invalid-ulid').isValid); // false
```

### Rules.string.ip

Ensures the string is a valid IP address (IPv4 or IPv6).

```dart
final schema = Validasi.string([
	Rules.string.ip(),
]);

print(schema.validate('192.168.1.1').isValid); // true
print(schema.validate('::1').isValid); // true
print(schema.validate('invalid').isValid); // false
```

### Rules.string.ipv4

Ensures the string is a valid IPv4 address.

```dart
final schema = Validasi.string([
	Rules.string.ipv4(),
]);

print(schema.validate('192.168.1.1').isValid); // true
print(schema.validate('::1').isValid); // false
```

### Rules.string.ipv6

Ensures the string is a valid IPv6 address.

```dart
final schema = Validasi.string([
	Rules.string.ipv6(),
]);

print(schema.validate('::1').isValid); // true
print(schema.validate('192.168.1.1').isValid); // false
```

### Rules.string.url

Ensures the string is a valid URL.

```dart
final schema = Validasi.string([
	Rules.string.url(),
]);

print(schema.validate('https://example.com').isValid); // true
print(schema.validate('not a url').isValid); // false

// Require HTTPS only
final httpsOnly = Validasi.string([
	Rules.string.url(httpsOnly: true),
]);

print(httpsOnly.validate('https://example.com').isValid); // true
print(httpsOnly.validate('http://example.com').isValid); // false
```

### Rules.string.email

Ensures the string is a valid email address.

```dart
final schema = Validasi.string([
	Rules.string.email(),
]);

print(schema.validate('user@example.com').isValid); // true
print(schema.validate('invalid-email').isValid); // false

// Allow top-level domains (e.g., user@localhost)
final allowTld = Validasi.string([
	Rules.string.email(allowTopLevelDomain: true),
]);

// Restrict to specific domains
final workEmail = Validasi.string([
	Rules.string.email(domains: ['company.com', 'company.org']),
]);

print(workEmail.validate('user@company.com').isValid); // true
print(workEmail.validate('user@gmail.com').isValid); // false
```

## Combining String Rules

You can combine multiple rules in one schema.

```dart
final displayNameSchema = Validasi.string([
	Rules.string.minLength(2),
	Rules.string.maxLength(30),
	Rules.string.oneOf(['alice', 'bob', 'charlie']),
]);

final result = displayNameSchema.validate('bob');
print(result.isValid); // true
```

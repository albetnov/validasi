# Validation Cache

Validasi includes a built-in caching mechanism to optimize validation performance when the same values are validated repeatedly. This guide explains how the cache works and how to control it.

## Overview

The Validasi engine automatically caches validation results for each unique input value. When you validate the same value multiple times with the same schema, the engine returns the cached result instead of re-running all validation rules, significantly improving performance in scenarios with repeated validations.

## How the Cache Works

### Cache Lookup Process

When you call `validate()`, the engine follows this process:

1. **Compute Cache Key**: Generates a structural key from the input value
2. **Check Cache**: Looks up if this exact input was validated before
3. **Return or Compute**:
   - If cached result exists → return immediately
   - If no cache → run validation and store result

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    Required(),
    MinLength(5),
    MaxLength(20),
  ],
);

// First validation: runs all rules and caches result
final result1 = schema.validate('hello');

// Second validation: returns cached result instantly
final result2 = schema.validate('hello');

// Different value: runs validation and caches new result
final result3 = schema.validate('world');
```

### Cache Scope

The cache is **per-engine-instance**. Each `ValidasiEngine` maintains its own separate cache:

```dart
final schema1 = ValidasiEngine<String, String>(rules: [MinLength(5)]);
final schema2 = ValidasiEngine<String, String>(rules: [MinLength(10)]);

schema1.validate('hello'); // Cached in schema1
schema2.validate('hello'); // Separate cache in schema2
```

## Cache Key Generation

Validasi uses a **structural caching strategy** that generates stable keys based on the content of the value, not its identity:

### Supported Types

| Type | Cache Key Strategy | Example |
|------|-------------------|---------|
| `null` | Constant string | `'null'` |
| `bool` | Boolean value | `'b:1'` or `'b:0'` |
| `num` | Number with prefix | `'n:42'`, `'n:3.14'` |
| `String` | Length + content | `'s:5:hello'` |
| `List` | Length + recursive items | `'l[3]:n:1\|n:2\|n:3'` |
| `Map` | Sorted entries | `'m{k1=v1\|k2=v2}'` |
| `Object` | Identity + type | `'o:CustomType#12345'` |

### Examples

```dart
// Strings: same content = same key
schema.validate('hello'); // Key: 's:5:hello'
schema.validate('hello'); // Same key → cache hit!

// Numbers: same value = same key
schema.validate(42);    // Key: 'n:42'
schema.validate(42.0);  // Key: 'n:42.0' (different!)

// Lists: structural equality
schema.validate([1, 2, 3]); // Key: 'l[3]:n:1|n:2|n:3'
schema.validate([1, 2, 3]); // Same key → cache hit!

// Maps: keys are sorted for consistency
schema.validate({'b': 2, 'a': 1}); // Key: 'm{a=n:1|b=n:2}'
schema.validate({'a': 1, 'b': 2}); // Same key → cache hit!

// Objects: identity-based (no structural caching)
final obj1 = MyClass();
schema.validate(obj1); // Key: 'o:MyClass#67890'
schema.validate(obj1); // Same instance → cache hit!

final obj2 = MyClass();
schema.validate(obj2); // Different key → cache miss!
```

## Cache Policy: LRU (Least Recently Used)

The cache uses an **LRU eviction policy** with a fixed maximum size of **512 entries** per engine instance.

### How LRU Works

1. When a cached result is accessed, it becomes the "most recently used"
2. When the cache exceeds 512 entries, the **least recently used** entry is evicted
3. This ensures frequently validated values stay cached while old entries are removed

```dart
final schema = ValidasiEngine<String, String>(rules: [MinLength(1)]);

// Add 512 entries
for (var i = 0; i < 512; i++) {
  schema.validate('value$i');
}

// Cache is full (512 entries)

// Access an old entry → moves to front
schema.validate('value0');

// Add new entry → evicts least recently used
schema.validate('new_value'); // 'value1' is evicted
```

### Why 512 Entries?

The 512-entry limit balances memory usage and cache effectiveness:
- **Small enough**: Prevents unbounded memory growth
- **Large enough**: Handles most application validation patterns
- **LRU policy**: Keeps frequently used validations cached

## Enabling and Disabling Cache

Control caching when creating a schema:

```dart
// Cache enabled (default)
final engine = ValidasiEngine<String, String>(
  rules: [MinLength(5)],
  cacheEnabled: true,
);

// Cache disabled
final engine = ValidasiEngine<String, String>(
  rules: [MinLength(5)],
  cacheEnabled: false,
);

// or from Validasi
Validasi.withoutCache(() {
  return Validasi.string([StringRules.minLength(5)]).validate('test');
})
```

### Clearing the Cache

Clear cached results for a specific schema:

```dart
final schema = ValidasiEngine<String, String>(rules: [MinLength(5)]);

schema.validate('hello'); // Cached
schema.validate('hello'); // Cache hit

// Clear all cached results for this schema
schema.clearCache();

schema.validate('hello'); // Cache miss → re-validates
```

## When to Disable Cache

While caching improves performance in most scenarios, consider disabling it when:

### 1. Validating Unique Values

If every validation uses a different value, caching provides no benefit:

```dart
// Bad use case for cache: every value is unique
final schema = ValidasiEngine<String, String>(
  rules: [MinLength(5)],
  cacheEnabled: false, // Disable to save memory
);

for (var i = 0; i < 10000; i++) {
  schema.validate('unique_value_$i'); // Never repeats
}
```

### 2. Memory-Constrained Environments

In embedded systems or memory-sensitive applications:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [MinLength(5)],
  cacheEnabled: false, // Save memory
);
```

### 3. Non-Deterministic Validation

If validation depends on external state (time, random values, etc.), disable caching:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    InlineRule((value) {
      // Validation depends on current time
      return DateTime.now().hour >= 9 && DateTime.now().hour <= 17;
    }, message: 'Only available during business hours'),
  ],
  cacheEnabled: false, // Results change over time
);
```

### 4. Rules with Side Effects

If rules modify external state or have side effects:

```dart
var validationCount = 0;

final schema = ValidasiEngine<String, String>(
  rules: [
    InlineRule((value) {
      validationCount++; // Side effect
      return value != null;
    }),
  ],
  cacheEnabled: false, // Ensure rule runs every time
);
```

## When to Use Cache (Default)

Keep caching enabled (default) in these common scenarios:

### 1. Form Validation

User input often repeats during typing:

```dart
final emailSchema = ValidasiEngine<String, String>(
  rules: [Required(), Email()],
  // cacheEnabled: true (default)
);

// User types: "j" → "jo" → "joh" → "john" → "john@" → "john@ex" ...
// Many intermediate states will be validated multiple times
```

### 2. Repeated Validation

When validating the same data multiple times:

```dart
final schema = ValidasiEngine<Map<String, dynamic>, Map<String, dynamic>>(
  rules: [HasFields(['name', 'email'])],
);

final userData = {'name': 'John', 'email': 'john@example.com'};

// Validate on form load
schema.validate(userData);

// Validate before submission
schema.validate(userData); // Cache hit!

// Validate after confirmation
schema.validate(userData); // Cache hit!
```

### 3. Batch Processing with Duplicates

Processing lists where values may repeat:

```dart
final schema = ValidasiEngine<String, String>(rules: [Email()]);

final emails = [
  'john@example.com',
  'jane@example.com',
  'john@example.com', // Duplicate
  'bob@example.com',
  'john@example.com', // Duplicate
];

for (final email in emails) {
  schema.validate(email); // Duplicates use cache
}
```

### 4. API Request Validation

Validating similar API payloads:

```dart
final requestSchema = ValidasiEngine<Map<String, dynamic>, Map<String, dynamic>>(
  rules: [
    HasFields(['action', 'timestamp']),
    ConditionalField('action', (value) => value == 'update', 'data'),
  ],
);

// Similar requests benefit from caching
requestSchema.validate({'action': 'read', 'timestamp': '...'});
requestSchema.validate({'action': 'read', 'timestamp': '...'}); // Cache hit!
```

## Performance Considerations

### Cache Hit Performance

Cache hits are **extremely fast** - just a hash map lookup:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [MinLength(5), MaxLength(100), Email()],
);

// First validation: ~100 microseconds (depends on rules)
final result1 = schema.validate('test@example.com');

// Cache hit: ~1 microsecond (just lookup)
final result2 = schema.validate('test@example.com');
```

### Memory Usage

Each cached entry stores:
- Cache key (string)
- `ValidasiResult<T>` object

Typical memory per entry: **100-500 bytes** depending on error count and details.

Maximum memory per schema: **512 entries × ~300 bytes = ~150 KB**

### Cache Efficiency

Monitor cache effectiveness in performance-critical applications:

```dart
var cacheHits = 0;
var cacheMisses = 0;

final schema = ValidasiEngine<String, String>(rules: [MinLength(5)]);

for (final value in values) {
  final startTime = DateTime.now();
  schema.validate(value);
  final duration = DateTime.now().difference(startTime);
  
  if (duration.inMicroseconds < 10) {
    cacheHits++;
  } else {
    cacheMisses++;
  }
}

print('Cache hit rate: ${(cacheHits / (cacheHits + cacheMisses) * 100).toStringAsFixed(1)}%');
```

## Best Practices

### ✅ Do

- **Keep cache enabled by default** for most use cases
- **Clear cache** when validation rules change dynamically
- **Use cache** for form validation and repeated checks
- **Monitor memory** in long-running applications with many schemas

### ❌ Don't

- **Don't disable cache** unless you have a specific reason
- **Don't clear cache** unnecessarily (defeats the purpose)
- **Don't rely on cache** for rules with side effects
- **Don't cache** when validating unique values
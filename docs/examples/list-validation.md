# List Validation Examples

Learn how to validate lists and iterables with Validasi's list validation rules.

## Basic List Validation

### Simple List

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final tagsSchema = Validasi.list<String>([
  IterableRules.minLength(1, message: 'At least one tag required'),
]);

// Valid
print(tagsSchema.validate(['dart', 'flutter']).isValid); // true

// Invalid
print(tagsSchema.validate([]).isValid); // false
```

### List with Element Validation

```dart
final namesSchema = Validasi.list<String>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(2),
    ])
  ),
]);

// Valid
print(namesSchema.validate(['John', 'Jane', 'Bob']).isValid); // true

// Invalid - empty string
print(namesSchema.validate(['John', '', 'Bob']).isValid); // false
```

## Length Validation

### Minimum Length

```dart
final minSchema = Validasi.list<int>([
  IterableRules.minLength(3, message: 'List must have at least 3 items'),
]);

print(minSchema.validate([1, 2, 3]).isValid); // true
print(minSchema.validate([1, 2]).isValid); // false
```

### Combined Length Rules

```dart
final rangeSchema = Validasi.list<String>([
  IterableRules.minLength(2),
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(1),
    ])
  ),
  InlineRule<List<String>>((list) {
    if (list.length > 10) {
      return 'Too many items (max 10)';
    }
    return null;
  }),
]);

// Valid
print(rangeSchema.validate(['a', 'b', 'c']).isValid); // true

// Invalid - too few
print(rangeSchema.validate(['a']).isValid); // false

// Invalid - too many
print(rangeSchema.validate(List.generate(11, (i) => 'item$i')).isValid); // false
```

## ForEach Validation

### String List

```dart
final emailsSchema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(5),
      InlineRule<String>((value) {
        return value.contains('@') ? null : 'Invalid email';
      }),
    ])
  ),
]);

final result = emailsSchema.validate([
  'JOHN@EXAMPLE.COM',
  'JANE@EXAMPLE.COM',
]);

print(result.isValid); // true
print(result.data); // ['john@example.com', 'jane@example.com']
```

### Number List

```dart
final scoresSchema = Validasi.list<int>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.number<int>([
      NumberRules.moreThanEqual(0),
      NumberRules.lessThanEqual(100),
    ])
  ),
]);

// Valid
print(scoresSchema.validate([85, 92, 78]).isValid); // true

// Invalid - out of range
print(scoresSchema.validate([85, 105, 78]).isValid); // false
```

## Nested Lists

### List of Lists

```dart
final matrixSchema = Validasi.list<List<int>>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.list<int>([
      IterableRules.minLength(1),
      IterableRules.forEach(
        Validasi.number<int>([
          NumberRules.moreThanEqual(0),
        ])
      ),
    ])
  ),
]);

// Valid - 2D matrix
final matrix = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
];

print(matrixSchema.validate(matrix).isValid); // true
```

### List of Maps

```dart
final usersSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([
          NumberRules.moreThan(0),
        ]),
        'name': Validasi.string([
          StringRules.minLength(1),
        ]),
        'email': Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
        ]),
      }),
    ])
  ),
]);

final users = [
  {'id': 1, 'name': 'John', 'email': 'JOHN@EXAMPLE.COM'},
  {'id': 2, 'name': 'Jane', 'email': 'JANE@EXAMPLE.COM'},
];

final result = usersSchema.validate(users);
print('Valid: ${result.isValid}');
print('First email: ${result.data[0]['email']}'); // john@example.com
```

## Nullable Lists

### Optional List

```dart
final optionalTagsSchema = Validasi.list<String>([
  Nullable(),
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.string([StringRules.minLength(2)])
  ),
]);

// Valid
print(optionalTagsSchema.validate(null).isValid); // true
print(optionalTagsSchema.validate(['dart', 'flutter']).isValid); // true

// Invalid - empty list
print(optionalTagsSchema.validate([]).isValid); // false
```

### List with Nullable Elements

```dart
final mixedSchema = Validasi.list<String?>([
  IterableRules.forEach(
    Validasi.string([
      Nullable(),
      StringRules.minLength(2),
    ])
  ),
]);

// Valid - contains nulls
print(mixedSchema.validate(['hello', null, 'world']).isValid); // true
```

## List Transformations

### Filter Empty Strings

```dart
final cleanListSchema = Validasi.list<String>([
  Transform((list) {
    return list?.where((item) => item.isNotEmpty).toList();
  }),
  IterableRules.minLength(1),
]);

final result = cleanListSchema.validate(['a', '', 'b', '', 'c']);
print(result.data); // ['a', 'b', 'c']
```

### Trim All Strings

```dart
final trimmedSchema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([
      Transform((value) => value?.trim()),
      StringRules.minLength(1),
    ])
  ),
]);

final result = trimmedSchema.validate(['  hello  ', '  world  ']);
print(result.data); // ['hello', 'world']
```

### Sort List

```dart
final sortedSchema = Validasi.list<int>([
  Transform((list) {
    if (list == null) return null;
    final sorted = List<int>.from(list);
    sorted.sort();
    return sorted;
  }),
]);

final result = sortedSchema.validate([3, 1, 4, 1, 5, 9]);
print(result.data); // [1, 1, 3, 4, 5, 9]
```

### Remove Duplicates

```dart
final uniqueSchema = Validasi.list<String>([
  Transform((list) {
    return list?.toSet().toList();
  }),
  IterableRules.minLength(1),
]);

final result = uniqueSchema.validate(['a', 'b', 'a', 'c', 'b']);
print(result.data); // ['a', 'b', 'c']
```

## Real-World Examples

### Todo List

```dart
final todoListSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.minLength(1, message: 'Add at least one task'),
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([
          NumberRules.moreThan(0),
        ]),
        'title': Validasi.string([
          Transform((value) => value?.trim()),
          StringRules.minLength(1, message: 'Task title required'),
          StringRules.maxLength(200),
        ]),
        'completed': Validasi.any<bool>(),
        'priority': Validasi.string([
          Nullable(),
          StringRules.oneOf(['low', 'medium', 'high']),
        ]),
      }),
    ])
  ),
]);

final todos = [
  {
    'id': 1,
    'title': '  Complete documentation  ',
    'completed': false,
    'priority': 'high',
  },
  {
    'id': 2,
    'title': 'Review pull requests',
    'completed': true,
    'priority': 'medium',
  },
];

final result = todoListSchema.validate(todos);
print('Valid: ${result.isValid}');
print('First task: ${result.data[0]['title']}'); // 'Complete documentation'
```

### File Upload List

```dart
final filesSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.minLength(1, message: 'Select at least one file'),
  InlineRule<List<Map<String, dynamic>>>((list) {
    if (list.length > 5) {
      return 'Maximum 5 files allowed';
    }
    return null;
  }),
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'name': Validasi.string([
          StringRules.minLength(1),
        ]),
        'size': Validasi.number<int>([
          NumberRules.moreThan(0),
          NumberRules.lessThanEqual(10 * 1024 * 1024), // 10MB
        ]),
        'type': Validasi.string([
          StringRules.oneOf([
            'image/jpeg',
            'image/png',
            'image/gif',
            'application/pdf',
          ]),
        ]),
      }),
    ])
  ),
]);

final files = [
  {
    'name': 'photo.jpg',
    'size': 2048576, // 2MB
    'type': 'image/jpeg',
  },
  {
    'name': 'document.pdf',
    'size': 1024000, // 1MB
    'type': 'application/pdf',
  },
];

print(filesSchema.validate(files).isValid); // true
```

### Shopping Cart

```dart
final cartSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.minLength(1, message: 'Cart is empty'),
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'product_id': Validasi.number<int>([
          NumberRules.moreThan(0),
        ]),
        'name': Validasi.string([
          StringRules.minLength(1),
        ]),
        'quantity': Validasi.number<int>([
          NumberRules.moreThan(0),
          NumberRules.lessThanEqual(99),
        ]),
        'price': Validasi.number<double>([
          NumberRules.moreThan(0.0),
        ]),
      }),
    ])
  ),
  InlineRule<List<Map<String, dynamic>>>((items) {
    // Calculate total
    final total = items.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    
    if (total > 10000.0) {
      return 'Order total exceeds maximum allowed';
    }
    return null;
  }),
]);

final cart = [
  {
    'product_id': 1,
    'name': 'Laptop',
    'quantity': 1,
    'price': 999.99,
  },
  {
    'product_id': 2,
    'name': 'Mouse',
    'quantity': 2,
    'price': 29.99,
  },
];

print(cartSchema.validate(cart).isValid); // true
```

### Coordinate List

```dart
final coordinatesSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.minLength(2, message: 'At least 2 points required'),
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'lat': Validasi.number<double>([
          NumberRules.moreThanEqual(-90.0),
          NumberRules.lessThanEqual(90.0),
        ]),
        'lng': Validasi.number<double>([
          NumberRules.moreThanEqual(-180.0),
          NumberRules.lessThanEqual(180.0),
        ]),
      }),
    ])
  ),
]);

final route = [
  {'lat': 37.7749, 'lng': -122.4194}, // San Francisco
  {'lat': 34.0522, 'lng': -118.2437}, // Los Angeles
  {'lat': 40.7128, 'lng': -74.0060},  // New York
];

print(coordinatesSchema.validate(route).isValid); // true
```

### Tag Cloud

```dart
final tagCloudSchema = Validasi.list<String>([
  Transform((list) {
    // Remove duplicates and trim
    return list?.map((tag) => tag.trim().toLowerCase())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();
  }),
  IterableRules.minLength(1, message: 'At least one tag required'),
  InlineRule<List<String>>((list) {
    if (list.length > 20) {
      return 'Maximum 20 tags allowed';
    }
    return null;
  }),
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(50),
    ])
  ),
]);

final tags = [
  '  Flutter  ',
  'DART',
  'flutter', // duplicate
  'Mobile',
  'dart', // duplicate
  '',
  'UI',
];

final result = tagCloudSchema.validate(tags);
print('Valid: ${result.isValid}');
print('Tags: ${result.data}'); // ['flutter', 'dart', 'mobile', 'ui']
```

## Custom List Validations

### Unique Elements

```dart
final uniqueListSchema = Validasi.list<String>([
  IterableRules.minLength(1),
  InlineRule<List<String>>((list) {
    final unique = list.toSet();
    if (unique.length != list.length) {
      return 'List must contain unique elements';
    }
    return null;
  }),
]);

// Valid
print(uniqueListSchema.validate(['a', 'b', 'c']).isValid); // true

// Invalid - duplicates
print(uniqueListSchema.validate(['a', 'b', 'a']).isValid); // false
```

### Sorted List

```dart
final sortedListSchema = Validasi.list<int>([
  IterableRules.minLength(2),
  InlineRule<List<int>>((list) {
    for (int i = 1; i < list.length; i++) {
      if (list[i] < list[i - 1]) {
        return 'List must be sorted in ascending order';
      }
    }
    return null;
  }),
]);

// Valid
print(sortedListSchema.validate([1, 2, 3, 4]).isValid); // true

// Invalid
print(sortedListSchema.validate([1, 3, 2, 4]).isValid); // false
```

### Max Total Size

```dart
final sizedListSchema = Validasi.list<String>([
  InlineRule<List<String>>((list) {
    final totalLength = list.fold<int>(0, (sum, str) => sum + str.length);
    if (totalLength > 1000) {
      return 'Total text length exceeds 1000 characters';
    }
    return null;
  }),
]);
```

### No Consecutive Duplicates

```dart
final noConsecutiveSchema = Validasi.list<int>([
  InlineRule<List<int>>((list) {
    for (int i = 1; i < list.length; i++) {
      if (list[i] == list[i - 1]) {
        return 'No consecutive duplicate values allowed';
      }
    }
    return null;
  }),
]);

// Valid
print(noConsecutiveSchema.validate([1, 2, 1, 3]).isValid); // true

// Invalid
print(noConsecutiveSchema.validate([1, 2, 2, 3]).isValid); // false
```

## Error Tracking in Lists

### Individual Element Errors

```dart
final emailListSchema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([
      InlineRule<String>((value) {
        return value.contains('@') ? null : 'Invalid email format';
      }),
    ])
  ),
]);

final result = emailListSchema.validate([
  'valid@example.com',
  'invalid-email',
  'another@example.com',
  'also-invalid',
]);

print('Valid: ${result.isValid}'); // false

// Print errors with indices
for (var error in result.errors) {
  print('[${error.path?.join('.')}] ${error.message}');
}
// Output:
// [1] Invalid email format
// [3] Invalid email format
```

### Nested List Errors

```dart
final nestedSchema = Validasi.list<List<int>>([
  IterableRules.forEach(
    Validasi.list<int>([
      IterableRules.forEach(
        Validasi.number<int>([
          NumberRules.moreThanEqual(0, message: 'Must be non-negative'),
        ])
      ),
    ])
  ),
]);

final result = nestedSchema.validate([
  [1, 2, 3],
  [4, -5, 6],
  [7, 8, -9],
]);

for (var error in result.errors) {
  print('[${error.path?.join('.')}] ${error.message}');
}
// Output:
// [1.1] Must be non-negative
// [2.2] Must be non-negative
```

## List with Complex Validation

### Conditional Element Validation

```dart
final conditionalListSchema = Validasi.list<Map<String, dynamic>>([
  IterableRules.forEach(
    Validasi.map<dynamic>([
      MapRules.hasFields({
        'type': Validasi.string([
          StringRules.oneOf(['text', 'number', 'date']),
        ]),
        'value': Validasi.any<dynamic>([Required()]),
      }),
      Having((context, value) {
        if (value is Map) {
          final type = value['type'];
          final val = value['value'];
          
          if (type == 'number' && val is! num) {
            return 'Value must be a number when type is "number"';
          }
          if (type == 'date' && val is! String) {
            return 'Value must be a string when type is "date"';
          }
        }
        return null;
      }),
    ])
  ),
]);

final items = [
  {'type': 'text', 'value': 'Hello'},
  {'type': 'number', 'value': 42},
  {'type': 'date', 'value': '2024-01-15'},
];

print(conditionalListSchema.validate(items).isValid); // true
```

## Next Steps

- [String Validation](/examples/string-validation)
- [Number Validation](/examples/number-validation)
- [Map Validation](/examples/map-validation)
- [Complex Structures](/examples/complex-structures)
- [Iterable Rules Reference](/guide/iterable-rules)

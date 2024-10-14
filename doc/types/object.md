# Object

The `Object` schema is used to validate the input value as an object or `Map`. This schema contains some useful built-in validators to validate the input value.

The following code shows how to create an `Object` schema:

```dart [Using Validasi]
Validasi.object({
  'name': Validasi.string(),
  'age': Validasi.number(),
});
```

```dart [Using Direct Class]
ObjectValidator({
  'name': StringValidator(),
  'age': NumberValidator(),
});
```

The `Object` schema requires a schema parameter a map of string-validator pairs to validate the keys and values in the object.

You can also have nesting schemas in the `Object` schema. The following code shows how to create a nested `Object` schema:

```dart
Validasi.object({
  'name': Validasi.string(),
  'address': Validasi.object({
    'street': Validasi.string(),
    'city': Validasi.string(),
  }),
});
```

Or combine them with other schema:

```dart
Validasi.object({
  'name': Validasi.string(),
  'addresses': Validasi.array(
    Validasi.object({
      'street': Validasi.string(),
      'city': Validasi.string(),
    }),
  ),
});
```

::: info
The Array schema will reconstruct your input value accoring to the schema you provided. This allow you to take advantage of transformer in the schema
to convert the array value into the desired format.

```dart
Validasi.object({
    'name': Validasi.string(),
    'numbers': Validasi.array(Validasi.number(transformer: NumberTransformer())),
});
```

Above code can takes `name: string, numbers: List<String>` and returning `name: string, numbers: List<num>`. The `numbers` key will be converted
according to the transformer you provided.
:::

## The `null` Behaviour

Since Object Validator will reconstruct your input value, it will replace the value with `null` if the value fail to validate. This is to ensure the object length is still the same as the input value. However, for some this behaviour might confuse you. Therefore, this guide will attempt to explain when you will
receive `null` and kinds.

### When Receive `null`

If the input value is null and not an object, the reconstructed object will return null as well.

```dart
var schema = Validasi.object({
  'name': Validasi.string(),
  'age': Validasi.number(),
});

print(schema.tryParse(null).value); // null
```

### When receive `object` but empty

If the input value is an object but empty, the reconstructed object will differs compared to receiving `null`. It will return an object with all keys and values set to `null`.

```dart
var schema = Validasi.object({
  'name': Validasi.string(),
  'age': Validasi.number(),
});

print(schema.tryParse({}).value); // {name: null, age: null}
```
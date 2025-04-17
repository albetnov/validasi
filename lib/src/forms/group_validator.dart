import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/validator.dart';

class GroupValidatorUsing {
  final Validator validator;
  final String path;

  const GroupValidatorUsing(this.validator, this.path);

  /// Validates a single [value] against the validator associated with the
  /// specified [field].
  ///
  /// Returns `null` if validation succeeds, or an error message string if it fails.
  /// The optional [path] specifies the name used in the error message,
  /// defaulting to the [field] name.
  String? validate(dynamic value) {
    return FieldValidator(validator, path: path).validate(value);
  }

  /// Asynchronously validates a single [value] against the validator
  /// associated with the specified [field].
  ///
  /// Returns `null` if validation succeeds, or an error message string if it fails.
  /// The optional [path] specifies the name used in the error message,
  /// defaulting to the [field] name.
  Future<String?> validateAsync(dynamic value) {
    return FieldValidator(validator, path: path).validateAsync(value);
  }
}

/// [GroupValidator] allows you to combine couple of validators with
/// Map syntax and grouped them together. Do note, that [GroupValidator] is
/// not for validating [Map], you should use [ObjectValidator] instead.
///
/// The [GroupValidator] allow you to use [validate] to quickly return
/// first error message or null if success. Suitable to be passed on Flutter's
/// `FormField`.
///
/// The [GroupValidator] takes [schema] as parameter. The [schema] is a Map
/// with [String] as key and [Validator] as value.
class GroupValidator {
  /// The [schema] contains all [Validator] instances to be used.
  final Map<String, Validator> schema;

  /// Creates a [GroupValidator] with the given validation [schema].
  ///
  /// The [schema] maps field names (keys) to their corresponding [Validator]
  /// instances (values).
  const GroupValidator(this.schema);

  /// Checks if the [field] is present in the [schema].
  void _hasField(String field) {
    if (!schema.containsKey(field)) {
      throw ValidasiException("Field '$field' is not found in the schema");
    }
  }

  /// Extends the [Validator] for the given [field] using the [extend] function.
  ///
  /// Throws a [ValidasiException] if the [field] is not found in the schema.
  /// Allows modifying or wrapping an existing validator in the schema.
  ///
  /// Example:
  /// ```dart
  /// validator.extend<StringValidator>('email', (v) => v.email());
  /// ```
  GroupValidator extend<T extends Validator>(
    String field,
    Validator Function(T validator) extend,
  ) {
    _hasField(field);
    final validator = schema[field];

    // Ensure the validator is of the expected type before extending.
    if (validator is! T) {
      throw ValidasiException(
          "Validator for field '$field' is of type ${validator.runtimeType}, expected $T.");
    }

    schema[field] = extend(validator);
    return this;
  }

  /// Sets the [field] to be validated.
  ///
  /// The [field] should be a key in the [schema] map.
  /// The [path] is used for error messages and defaults to the [field] name.
  GroupValidatorUsing using(String field, {String? path}) {
    _hasField(field);

    return GroupValidatorUsing(schema[field]!, path ?? field);
  }

  /// Sets the [field] to be validated.
  ///
  /// This method is deprecated and will be removed in future versions.
  /// Currently this method is an alias for [using] method. Update your code accordingly.
  @Deprecated('Use using() instead')
  GroupValidatorUsing on(String field, {String? path}) =>
      using(field, path: path);

  /// Validates multiple values contained in a [map].
  ///
  /// The keys in the [map] should correspond to the field names in the [schema].
  /// Returns a map where keys are field names with validation errors and values
  /// are the corresponding error messages. An empty map indicates success.
  ///
  /// Throws a [ValidasiException] if any key from the [schema] is missing
  /// in the input [map].
  Map<String, String> validateMap(Map<String, dynamic> map) {
    final errors = <String, String>{};

    for (final entry in schema.entries) {
      final field = entry.key;
      final validator = entry.value;

      if (!map.containsKey(field)) {
        throw ValidasiException(
            "Missing key '$field' in the input map. Ensure the map contains all keys defined in the schema.");
      }

      final value = map[field];
      final error = FieldValidator(validator, path: field).validate(value);

      if (error != null) {
        errors[field] = error;
      }
    }

    return errors;
  }

  /// Asynchronously validates multiple values contained in a [map].
  ///
  /// The keys in the [map] should correspond to the field names in the [schema].
  /// Returns a map where keys are field names with validation errors and values
  /// are the corresponding error messages. An empty map indicates success.
  ///
  /// Throws a [ValidasiException] if any key from the [schema] is missing
  /// in the input [map].
  Future<Map<String, String>> validateMapAsync(Map<String, dynamic> map) async {
    final errors = <String, String>{};

    // Use Future.wait for potential parallel validation if validators support it.
    final validationFutures = <Future<void>>[];

    for (final entry in schema.entries) {
      final field = entry.key;
      final validator = entry.value;

      if (!map.containsKey(field)) {
        throw ValidasiException(
            "Missing key '$field' in the input map. Ensure the map contains all keys defined in the schema.");
      }

      final value = map[field];
      final future =
          FieldValidator(validator, path: field).validateAsync(value).then(
        (error) {
          if (error != null) {
            // Synchronize access to the errors map
            errors[field] = error;
          }
        },
      );
      validationFutures.add(future);
    }

    await Future.wait(validationFutures);
    return errors;
  }
}

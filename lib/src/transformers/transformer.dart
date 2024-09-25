import 'package:meta/meta.dart';
import 'package:validasi/src/exceptions/field_error.dart';

/// The [FailCallback] will throw [FieldError] exception based on the message.
typedef FailCallback = void Function(String message);

/// The [Transformer] class is the base class for all transformers.
/// This class responsible to transform the value to the desired type.
abstract class Transformer<T> {
  const Transformer();

  /// The [transform] method should be implemented by the inheritors.
  /// This method should return the transformed value or throw [FieldError]
  /// if the transformation failed.
  @mustBeOverridden
  T? transform(dynamic value, FailCallback fail);
}

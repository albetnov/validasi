import 'package:validasi/src/engine/error.dart';

/// Groups a list of [ValidationError]s by their first path segment.
///
/// Errors with a non-empty [ValidationError.path] are keyed by `path[0]`.
/// Errors with no path or an empty path are grouped under the empty string key
/// (representing form-level errors).
Map<String, List<ValidationError>> groupErrorsByPath(
  List<ValidationError> errors,
) {
  final result = <String, List<ValidationError>>{};
  for (final error in errors) {
    final path = error.path;
    final key = (path != null && path.isNotEmpty) ? path[0] : '';
    result.putIfAbsent(key, () => []).add(error);
  }
  return result;
}

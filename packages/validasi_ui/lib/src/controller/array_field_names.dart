/// Pure utility for parsing bracket-indexed field names like `emails[0]`
/// or `people[2].name`.
///
/// All methods are static and stateless. No dependencies on controller
/// internals.
class ArrayFieldName {
  ArrayFieldName._();

  /// Extracts the integer slot index from a bracket field name.
  ///
  /// Examples:
  /// ```dart
  /// ArrayFieldName.slotIndex('emails[2]');       // → 2
  /// ArrayFieldName.slotIndex('people[0].name');  // → 0
  /// ArrayFieldName.slotIndex('name');            // → null
  /// ```
  static int? slotIndex(String name) {
    final start = name.lastIndexOf('[');
    final end = name.lastIndexOf(']');
    if (start == -1 || end == -1) return null;
    return int.tryParse(name.substring(start + 1, end));
  }

  /// Whether [name] represents a sub-field of an object array item
  /// (i.e. has a dot after the closing bracket).
  ///
  /// Examples:
  /// ```dart
  /// ArrayFieldName.isObjectSubField('people[0].name'); // → true
  /// ArrayFieldName.isObjectSubField('emails[0]');      // → false
  /// ```
  static bool isObjectSubField(String name) {
    final end = name.lastIndexOf(']');
    if (end == -1) return false;
    return name.indexOf('.', end) != -1;
  }

  /// Returns a new field name with the slot index replaced by [newIndex].
  ///
  /// Examples:
  /// ```dart
  /// ArrayFieldName.withIndex('people[2].name', 5); // → 'people[5].name'
  /// ArrayFieldName.withIndex('emails[0]', 7);      // → 'emails[7]'
  /// ```
  static String withIndex(String name, int newIndex) {
    final start = name.lastIndexOf('[');
    final end = name.lastIndexOf(']');
    if (start == -1 || end == -1) return name;
    final prefix = name.substring(0, start + 1);
    final suffix = name.substring(end);
    return '$prefix$newIndex$suffix';
  }
}

import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/array_field_names.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/controller/indexed_field.dart';

/// Internal field type for scalar array items (e.g. `emails[0]`).
class _ArrayItemField<T, V> extends ValidasiField<T, V> {
  final String _name;
  const _ArrayItemField(this._name);

  @override
  String get name => _name;

  @override
  V? extract(T owner) => null;

  @override
  ValidasiResult<V> validate(V? value) => ValidasiResult.success(value as V);

  @override
  bool operator ==(Object other) =>
      other is _ArrayItemField<T, V> && _name == other._name;

  @override
  int get hashCode => _name.hashCode;
}

/// Internal structure describing how to index and reconstruct object-array items.
class _ObjectArrayStructure<T> {
  final List<ValidasiField<T, dynamic>> Function(int index) indexedFields;
  final dynamic Function(ValidasiFormController<T>, int) reconstructItem;
  final List<dynamic> Function(ValidasiFormController<T>) reconstructAll;

  _ObjectArrayStructure({
    required this.indexedFields,
    required this.reconstructItem,
    required this.reconstructAll,
  });
}

/// Coordinates all array-item lifecycle, tracking, and slot-migration logic
/// for a [ValidasiFormController].
///
/// Owns the four array-tracking maps. The controller holds one instance and
/// proxies public array operations here. Never accesses controller internals
/// directly — only through the [ValidasiControllerContext] contract.
class ValidasiArrayRegistry<T> {
  final ValidasiControllerContext<T> _ctx;
  final ValidasiFormController<T> _controller;

  ValidasiArrayRegistry(this._ctx, this._controller);

  // ---------------------------------------------------------------------------
  // Array tracking state
  // ---------------------------------------------------------------------------

  final _arrayItemFields = <ValidasiField<T, dynamic>>{};
  final _arrayItemParents =
      <ValidasiField<T, dynamic>, ValidasiField<T, dynamic>>{};
  final _objectArrayStructures =
      <ValidasiField<T, dynamic>, _ObjectArrayStructure<T>>{};
  final _arraySubFields =
      <ValidasiField<T, dynamic>, List<ValidasiField<T, dynamic>>>{};

  // ---------------------------------------------------------------------------
  // Queries used by the controller
  // ---------------------------------------------------------------------------

  /// Whether [field] is a tracked array-item sub-field.
  bool isArrayItemField(ValidasiField<T, dynamic> field) =>
      _arrayItemFields.contains(field);

  /// Whether [field] has an associated object-array structure.
  bool hasArrayStructure(ValidasiField<T, dynamic> field) =>
      _objectArrayStructures.containsKey(field);

  /// The parent field if [field] is an array item, otherwise `null`.
  ValidasiField<T, dynamic>? getArrayItemParent(
    ValidasiField<T, dynamic> field,
  ) =>
      _arrayItemParents[field];

  /// If [field] has an object-array structure, reconstruct all items using its
  /// registered callbacks. Otherwise returns `null`.
  List<dynamic>? reconstructAll(ValidasiField<T, dynamic> field) {
    final structure = _objectArrayStructures[field];
    return structure?.reconstructAll(_controller);
  }

  // ---------------------------------------------------------------------------
  // Notification from controller when a field is unregistered
  // ---------------------------------------------------------------------------

  /// Called by the controller's [ValidasiFormController.unregisterField] after
  /// it has cleaned up subscriptions, field controllers, etc.
  void onFieldUnregistered(ValidasiField<T, dynamic> field) {
    _objectArrayStructures.remove(field);
    _arrayItemFields.remove(field);
    final parent = _arrayItemParents.remove(field);
    if (parent != null) {
      _arraySubFields[parent]?.remove(field);
    }
  }

  // ---------------------------------------------------------------------------
  // Unregister sub-fields (called by controller's unregister)
  // ---------------------------------------------------------------------------

  /// Unregister all sub-fields of [parentField] recursively.
  void unregisterSubFields(ValidasiField<T, dynamic> parentField) {
    final subs = _arraySubFields.remove(parentField);
    if (subs != null) {
      for (final sub in subs) {
        _ctx.unregisterField(sub);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Rebuild helpers used by setInitialValues / reset
  // ---------------------------------------------------------------------------

  /// Rebuild all registered object-array sub-fields from the current value.
  void rebuildAllArrayItems() {
    for (final parentField in _objectArrayStructures.keys.toList()) {
      _rebuildArrayItems(parentField as ValidasiField<T, List<dynamic>>);
    }
  }

  /// Rebuild sub-fields for every list-valued field that is not itself an array
  /// item (used during [ValidasiFormController.reset]).
  void rebuildListFields(Iterable<ValidasiField<T, dynamic>> allFields) {
    for (final field in allFields) {
      if (field is _ArrayItemField) continue;
      if (_ctx.fieldSignal(field)?.value is List) {
        _rebuildArrayItems(field as ValidasiField<T, List<dynamic>>);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Public array API (proxied by controller)
  // ---------------------------------------------------------------------------

  ValidasiField<T, V>? getArrayItemField<V>(
    ValidasiField<T, List<V>> field,
    int index,
  ) {
    final name = '${field.name}[$index]';
    return _ctx.fieldByName(name) as ValidasiField<T, V>?;
  }

  int getArrayItemCount(ValidasiField<T, dynamic> field) {
    final fc = _ctx.fieldSignal(field);
    if (fc == null) return 0;
    final list = fc.value;
    if (list is List) return list.length;
    return 0;
  }

  ValidasiField<T, SubV>? getArraySubField<SubV>(
    ValidasiField<T, dynamic> field,
    int index,
    String fieldName,
  ) {
    final name = '${field.name}[$index].$fieldName';
    return _ctx.fieldByName(name) as ValidasiField<T, SubV>?;
  }

  void appendArrayItem<V>(
    ValidasiField<T, List<V>> field,
    V value, {
    List<ValidasiField<T, dynamic>> Function(int index)? indexedFields,
    dynamic Function(ValidasiFormController<T>, int)? reconstructItem,
    List<dynamic> Function(ValidasiFormController<T>)? reconstructAll,
  }) {
    final key = field as ValidasiField<T, dynamic>;
    if (indexedFields != null &&
        reconstructItem != null &&
        reconstructAll != null) {
      _objectArrayStructures[key] = _ObjectArrayStructure<T>(
        indexedFields: indexedFields,
        reconstructItem: reconstructItem,
        reconstructAll: reconstructAll,
      );
    }
    final parentFc = _ctx.getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[], value];
    parentFc.value = list;
    _registerNewSlot(field, list.length - 1, _objectArrayStructures[key], list);
    _ctx.notifyListeners();
  }

  void insertArrayItem<V>(
    ValidasiField<T, List<V>> field,
    int index,
    V value, {
    List<ValidasiField<T, dynamic>> Function(int index)? indexedFields,
    dynamic Function(ValidasiFormController<T>, int)? reconstructItem,
    List<dynamic> Function(ValidasiFormController<T>)? reconstructAll,
  }) {
    final key = field as ValidasiField<T, dynamic>;
    if (indexedFields != null &&
        reconstructItem != null &&
        reconstructAll != null) {
      _objectArrayStructures[key] = _ObjectArrayStructure<T>(
        indexedFields: indexedFields,
        reconstructItem: reconstructItem,
        reconstructAll: reconstructAll,
      );
    }
    final parentFc = _ctx.getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (index < 0 || index > list.length) return;
    list.insert(index, value);
    parentFc.value = list;
    final structure = _objectArrayStructures[key];
    final n = list.length;
    _registerNewSlot(field, n - 1, structure, list);
    _ctx.beginBatch();
    try {
      for (var i = n - 2; i >= index; i--) {
        _migrateSlotSignals(field, i, i + 1);
      }
      if (structure != null) {
        final subFields = structure.indexedFields(index);
        for (final subField in subFields) {
          final existingField = _ctx.fieldByName(subField.name);
          if (existingField == null) continue;
          final indexedField = existingField as IndexedField<T, dynamic>;
          final subValue = indexedField.extractFromItem(list[index]);
          final fc = _ctx.fieldSignal(existingField);
          if (fc != null) {
            fc.setInitialValue(subValue);
            fc.reset();
          }
        }
      } else {
        final itemField = _ArrayItemField<T, V>('${field.name}[$index]');
        final fc = _ctx.fieldSignal(itemField);
        if (fc != null) {
          fc.setInitialValue(list[index]);
          fc.reset();
        }
      }
    } finally {
      _ctx.endBatch();
    }
    _ctx.notifyListeners();
  }

  void removeArrayItem<V>(ValidasiField<T, List<V>> field, int index) {
    final parentFc = _ctx.getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    parentFc.value = list;
    final n = list.length;
    _ctx.beginBatch();
    try {
      for (var i = index; i < n; i++) {
        _migrateSlotSignals(field, i + 1, i);
      }
    } finally {
      _ctx.endBatch();
    }
    _unregisterLastSlot(field, n);
    _ctx.notifyListeners();
  }

  void swapArrayItems<V>(ValidasiField<T, List<V>> field, int i, int j) {
    final parentFc = _ctx.getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (i < 0 || i >= list.length || j < 0 || j >= list.length) return;
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
    parentFc.value = list;
    _ctx.beginBatch();
    try {
      _swapSlotSignals(field, i, j);
    } finally {
      _ctx.endBatch();
    }
    _ctx.notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _rebuildArrayItems<V>(ValidasiField<T, List<V>> field) {
    final previous = _arraySubFields.remove(field) ?? const [];
    for (final sub in previous) {
      _unregisterArrayItem(sub);
    }

    final parentFc = _ctx.getFieldController<List<V>>(field);
    final list = parentFc.value ?? <V>[];
    final structure = _objectArrayStructures[field];
    final newSubs = <ValidasiField<T, dynamic>>[];

    for (var i = 0; i < list.length; i++) {
      if (structure != null) {
        final subFields = structure.indexedFields(i);
        for (final subField in subFields) {
          _ctx.register(subField);
          final item = list[i];
          final indexedField = subField as IndexedField<T, dynamic>;
          final subValue = indexedField.extractFromItem(item);
          final fc = _ctx.fieldSignal(subField)!;
          fc.setInitialValue(subValue);
          _arrayItemFields.add(subField);
          _arrayItemParents[subField] = field as ValidasiField<T, dynamic>;
          newSubs.add(subField);
        }
      } else {
        final itemField = _ArrayItemField<T, V>('${field.name}[$i]');
        _ctx.register(itemField, initialValue: list[i]);
        _arrayItemFields.add(itemField);
        _arrayItemParents[itemField] = field as ValidasiField<T, dynamic>;
        newSubs.add(itemField);
      }
    }
    _arraySubFields[field] = newSubs;
  }

  void _registerNewSlot<V>(
    ValidasiField<T, List<V>> parentField,
    int newIndex,
    _ObjectArrayStructure<T>? structure,
    List<V> list,
  ) {
    final newSubs = <ValidasiField<T, dynamic>>[];
    if (structure != null) {
      final subFields = structure.indexedFields(newIndex);
      for (final subField in subFields) {
        _ctx.register(subField);
        final indexedField = subField as IndexedField<T, dynamic>;
        final subValue = indexedField.extractFromItem(list[newIndex]);
        final fc = _ctx.fieldSignal(subField)!;
        fc.setInitialValue(subValue);
        _arrayItemFields.add(subField);
        _arrayItemParents[subField] = parentField as ValidasiField<T, dynamic>;
        newSubs.add(subField);
      }
    } else {
      final itemField = _ArrayItemField<T, V>('${parentField.name}[$newIndex]');
      _ctx.register(itemField, initialValue: list[newIndex]);
      _arrayItemFields.add(itemField);
      _arrayItemParents[itemField] = parentField as ValidasiField<T, dynamic>;
      newSubs.add(itemField);
    }
    final existing = _arraySubFields[parentField];
    if (existing != null) {
      existing.addAll(newSubs);
    } else {
      _arraySubFields[parentField] = newSubs;
    }
  }

  void _unregisterLastSlot<V>(
    ValidasiField<T, List<V>> parentField,
    int lastIndex,
  ) {
    final subs = _arraySubFields[parentField]?.toList() ?? const [];
    for (final subField in subs) {
      final slotIndex = ArrayFieldName.slotIndex(subField.name);
      if (slotIndex == lastIndex) {
        _unregisterArrayItem(subField);
      }
    }
  }

  void _unregisterArrayItem(ValidasiField<T, dynamic> field) {
    _ctx.unregisterField(field);
  }

  void _swapSlotSignals<V>(
    ValidasiField<T, List<V>> parentField,
    int i,
    int j,
  ) {
    if (i == j) return;
    final subs = _arraySubFields[parentField] ?? const [];

    for (final subField in subs) {
      final slotIndex = ArrayFieldName.slotIndex(subField.name);
      if (slotIndex == null) continue;
      if (slotIndex != i && slotIndex != j) continue;
      if (slotIndex != i) continue;

      final otherName = ArrayFieldName.withIndex(subField.name, j);
      final otherSubField = _ctx.fieldByName(otherName);
      if (otherSubField == null) continue;

      final fcI = _ctx.fieldSignal(subField)!;
      final fcJ = _ctx.fieldSignal(otherSubField)!;
      fcI.swapSignalsWith(fcJ);
    }

    for (final subField in subs) {
      final slotIndex = ArrayFieldName.slotIndex(subField.name);
      if (slotIndex == null) continue;
      if (slotIndex != i && slotIndex != j) continue;
      _ctx.cancelAsyncField(subField);
      final fc = _ctx.fieldSignal(subField);
      if (fc != null && fc.isValidating) {
        fc.isValidating = false;
      }
    }
  }

  void _migrateSlotSignals<V>(
    ValidasiField<T, List<V>> parentField,
    int fromIndex,
    int toIndex,
  ) {
    final subs = _arraySubFields[parentField] ?? const [];
    for (final subField in subs) {
      final slotIndex = ArrayFieldName.slotIndex(subField.name);
      if (slotIndex == null || slotIndex != fromIndex) continue;

      final destName = ArrayFieldName.withIndex(subField.name, toIndex);
      final destSubField = _ctx.fieldByName(destName);
      if (destSubField == null) continue;

      final srcFc = _ctx.fieldSignal(subField)!;
      final destFc = _ctx.fieldSignal(destSubField)!;
      destFc.migrateFrom(srcFc);
      _ctx.migrateAsyncValidator(
        subField,
        destSubField,
        srcFc,
        destFc,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Clear all array-tracking state (used during [ValidasiFormController.dispose]).
  void clear() {
    _objectArrayStructures.clear();
    _arraySubFields.clear();
  }
}

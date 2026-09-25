// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_form.dart';

sealed class IndexedFormItemFields<V> extends ValidasiKey<IndexedFormItem>
    implements ValidasiField<IndexedFormItem, V> {
  const IndexedFormItemFields._();

  static const ValidasiSchema<IndexedFormItem> schema =
      _IndexedFormItemSchema();

  static const IndexedFormItemFields<String> title =
      IndexedFormItemTitleField();

  static const IndexedFormItemFields<int> quantity =
      IndexedFormItemQuantityField();

  static List<IndexedFieldDescriptor<FormType>> indexedFields<FormType>(
    String parentPath,
    int index,
  ) {
    return <IndexedFieldDescriptor<FormType>>[
      IndexedField<FormType, String>(
        fieldName: 'title',
        parentPath: parentPath,
        index: index,
        validate: (v) => IndexedFormItemTitleField().validate(v),
        validateAsync: (v) => IndexedFormItemTitleField().validateAsync(v),
        extractFromItem: (item) => (item as IndexedFormItem).title,
      ),
      IndexedField<FormType, int>(
        fieldName: 'quantity',
        parentPath: parentPath,
        index: index,
        validate: (v) => IndexedFormItemQuantityField().validate(v),
        validateAsync: (v) => IndexedFormItemQuantityField().validateAsync(v),
        extractFromItem: (item) => (item as IndexedFormItem).quantity,
      ),
    ];
  }

  static IndexedFormItem reconstructItem<FormType>(
    ValidasiFormController<FormType> ctrl,
    ValidasiField<FormType, List<IndexedFormItem>> field,
    int index,
  ) {
    return IndexedFormItem(
      title: ctrl.getValue(
        ctrl.getArraySubField<String>(field, index, 'title')!,
      ) as String,
      quantity: ctrl.getValue(
        ctrl.getArraySubField<int>(field, index, 'quantity')!,
      ) as int,
    );
  }

  static List<IndexedFormItem> reconstructAll<FormType>(
    ValidasiFormController<FormType> ctrl,
    ValidasiField<FormType, List<IndexedFormItem>> field,
  ) {
    final count = ctrl.getArrayItemCount(field);
    return List.generate(count, (i) => reconstructItem(ctrl, field, i));
  }
}

class IndexedFormItemTitleField extends IndexedFormItemFields<String> {
  const IndexedFormItemTitleField() : super._();

  @override
  String get name => 'title';

  @override
  String extract(IndexedFormItem owner) => owner.title;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value!.length < 1) {
      $errors.add(_Errors.minLength([name], 1));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class IndexedFormItemQuantityField extends IndexedFormItemFields<int> {
  const IndexedFormItemQuantityField() : super._();

  @override
  String get name => 'quantity';

  @override
  int extract(IndexedFormItem owner) => owner.quantity;

  @override
  ValidasiResult<int> validate(int? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && ![1, 2, 3].contains(value)) {
      $errors.add(_Errors.oneOf([name], [1, 2, 3]));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<int>> validateAsync(int? value) async {
    return validate(value);
  }
}

class _IndexedFormItemSchema extends ValidasiSchema<IndexedFormItem> {
  const _IndexedFormItemSchema();

  @override
  IndexedFormItem allocate(ValidasiFieldReader<IndexedFormItem> reader) {
    return IndexedFormItem(
      title: reader.getValue(IndexedFormItemFields.title) as String,
      quantity: reader.getValue(IndexedFormItemFields.quantity) as int,
    );
  }
}

extension $IndexedFormItemValidasi on IndexedFormItem {
  ValidasiResult<IndexedFormItem> validate() {
    final $errors = <ValidationError>[];
    // Field: title
    if (title.length < 1) {
      $errors.add(_Errors.minLength(['title'], 1));
    }
    // Field: quantity
    if (![1, 2, 3].contains(quantity)) {
      $errors.add(_Errors.oneOf(['quantity'], [1, 2, 3]));
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<IndexedFormItem>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: title
    if (title.length < 1) {
      $errors.add(_Errors.minLength(['title'], 1));
    }
    // Field: quantity
    if (![1, 2, 3].contains(quantity)) {
      $errors.add(_Errors.oneOf(['quantity'], [1, 2, 3]));
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  ValidasiResult<V> validateField<V>(IndexedFormItemFields<V> field) {
    return field.validate(field.extract(this));
  }

  Future<ValidasiResult<V>> validateFieldAsync<V>(
    IndexedFormItemFields<V> field,
  ) async {
    return field.validateAsync(field.extract(this));
  }
}

sealed class IndexedArrayFormFields<V> extends ValidasiKey<IndexedArrayForm>
    implements ValidasiField<IndexedArrayForm, V> {
  const IndexedArrayFormFields._();

  static const ValidasiSchema<IndexedArrayForm> schema =
      _IndexedArrayFormSchema();

  static const IndexedArrayFormFields<String> title =
      IndexedArrayFormTitleField();

  static const IndexedArrayFormFields<List<IndexedFormItem>> items =
      IndexedArrayFormItemsField();
}

class IndexedArrayFormTitleField extends IndexedArrayFormFields<String> {
  const IndexedArrayFormTitleField() : super._();

  @override
  String get name => 'title';

  @override
  String extract(IndexedArrayForm owner) => owner.title;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value!.length < 1) {
      $errors.add(_Errors.minLength([name], 1));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class IndexedArrayFormItemsField
    extends IndexedArrayFormFields<List<IndexedFormItem>> {
  const IndexedArrayFormItemsField() : super._();

  @override
  String get name => 'items';

  @override
  List<IndexedFormItem> extract(IndexedArrayForm owner) => owner.items;

  @override
  ValidasiResult<List<IndexedFormItem>> validate(List<IndexedFormItem>? value) {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
    }
    final $errors = <ValidationError>[];
    for (var $itemsIndex = 0; $itemsIndex < value.length; $itemsIndex++) {
      final $itemsItem = value[$itemsIndex];
      final $itemsResult = $itemsItem.validate();
      if (!$itemsResult.isValid) {
        $errors.addAll(
          $itemsResult.errors.map((e) => e..prefix("$name[${$itemsIndex}]")),
        );
      }
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<List<IndexedFormItem>>> validateAsync(
    List<IndexedFormItem>? value,
  ) async {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
    }
    final $errors = <ValidationError>[];
    for (var $itemsIndex = 0; $itemsIndex < value.length; $itemsIndex++) {
      final $itemsItem = value[$itemsIndex];
      final $itemsResult = await $itemsItem.validateAsync();
      if (!$itemsResult.isValid) {
        $errors.addAll(
          $itemsResult.errors.map((e) => e..prefix("$name[${$itemsIndex}]")),
        );
      }
    }
    return _Result.from($errors, value);
  }
}

class _IndexedArrayFormSchema extends ValidasiSchema<IndexedArrayForm> {
  const _IndexedArrayFormSchema();

  @override
  IndexedArrayForm allocate(ValidasiFieldReader<IndexedArrayForm> reader) {
    return IndexedArrayForm(
      title: reader.getValue(IndexedArrayFormFields.title) as String,
      items: reader.getValue(IndexedArrayFormFields.items)
              as List<IndexedFormItem>? ??
          const <IndexedFormItem>[],
    );
  }
}

extension $IndexedArrayFormValidasi on IndexedArrayForm {
  ValidasiResult<IndexedArrayForm> validate() {
    final $errors = <ValidationError>[];
    // Field: title
    if (title.length < 1) {
      $errors.add(_Errors.minLength(['title'], 1));
    }
    // Field: items (nested IndexedFormItem)
    for (var $itemsIndex = 0; $itemsIndex < items.length; $itemsIndex++) {
      final $itemsItem = items[$itemsIndex];
      final $itemsItemResult = $itemsItem.validate();
      if (!$itemsItemResult.isValid) {
        $errors.addAll(
          $itemsItemResult.errors.map(
            (e) => e..prefix('items[${$itemsIndex}]'),
          ),
        );
      }
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<IndexedArrayForm>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: title
    if (title.length < 1) {
      $errors.add(_Errors.minLength(['title'], 1));
    }
    // Field: items (nested IndexedFormItem)
    for (var $itemsIndex = 0; $itemsIndex < items.length; $itemsIndex++) {
      final $itemsItem = items[$itemsIndex];
      final $itemsItemResult = await $itemsItem.validateAsync();
      if (!$itemsItemResult.isValid) {
        $errors.addAll(
          $itemsItemResult.errors.map(
            (e) => e..prefix('items[${$itemsIndex}]'),
          ),
        );
      }
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  ValidasiResult<V> validateField<V>(IndexedArrayFormFields<V> field) {
    return field.validate(field.extract(this));
  }

  Future<ValidasiResult<V>> validateFieldAsync<V>(
    IndexedArrayFormFields<V> field,
  ) async {
    return field.validateAsync(field.extract(this));
  }
}

abstract final class _Errors {
  static ValidationError required(List<String> path, {String? message}) =>
      ValidationError(
        rule: 'Required',
        message: message ?? 'Field is required',
        path: path,
      );

  static ValidationError minLength(
    List<String> path,
    int length, {
    String? message,
  }) =>
      ValidationError(
        rule: 'MinLength',
        message: message ?? 'Minimum length is $length characters',
        details: {'length': '$length'},
        path: path,
      );

  static ValidationError oneOf(
    List<String> path,
    List<Object?> options, {
    String? message,
  }) =>
      ValidationError(
        rule: 'OneOf',
        message: message ?? 'Value must be one of: ${options.join(", ")}',
        details: {'options': '${options.join(",")}'},
        path: path,
      );
}

abstract final class _Result {
  static ValidasiResult<T> from<T>(List<ValidationError> errors, T? value) =>
      errors.isEmpty
          ? ValidasiResult(errors: const [], isValid: true, data: value)
          : ValidasiResult(errors: errors, isValid: false);

  static ValidasiResult<T> invalidSingle<T>(ValidationError error) =>
      ValidasiResult(errors: [error], isValid: false);
}

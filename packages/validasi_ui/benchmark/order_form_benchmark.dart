// ignore_for_file: unused_import, depend_on_referenced_packages, avoid_print, unused_element_parameter, unnecessary_cast
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'package:test/test.dart';

class _LineItem {
  final String productName;
  final int quantity;
  final String note;
  const _LineItem({
    required this.productName,
    required this.quantity,
    this.note = '',
  });
}

class _OrderForm {
  final List<_LineItem> items;
  final String orderNote;
  final String referralCode;

  const _OrderForm({
    this.items = const [],
    this.orderNote = '',
    this.referralCode = '',
  });
}

const _productNames = [
  'Widget A',
  'Widget B',
  'Gadget X',
  'Gadget Y',
  'Premium Z',
  'Basic Tool',
  'Pro Kit',
  'Starter Pack',
  'Deluxe Set',
  'Mini',
];

class _ItemsField extends ValidasiField<_OrderForm, List<_LineItem>> {
  const _ItemsField();
  @override
  String get name => 'items';
  @override
  List<_LineItem>? extract(_OrderForm owner) => owner.items;
  @override
  ValidasiResult<List<_LineItem>> validate(List<_LineItem>? v) =>
      ValidasiResult.success(v);
}

class _OrderNoteField extends ValidasiField<_OrderForm, String> {
  const _OrderNoteField();
  @override
  String get name => 'orderNote';
  @override
  String? extract(_OrderForm owner) => owner.orderNote;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

class _ReferralField extends ValidasiField<_OrderForm, String> {
  const _ReferralField();
  @override
  String get name => 'referralCode';
  @override
  String? extract(_OrderForm owner) => owner.referralCode;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

const _itemsField = _ItemsField();
const _orderNoteField = _OrderNoteField();
const _referralField = _ReferralField();

ValidasiFormController<_OrderForm> _createController({int itemCount = 50}) {
  final ctrl = ValidasiFormController<_OrderForm>(
    assembler: (_) => const _OrderForm(),
  );

  for (var i = 0; i < itemCount; i++) {
    final product = _productNames[i % _productNames.length];
    ctrl.appendArrayItem(
      _itemsField,
      _LineItem(productName: product, quantity: 1),
      indexedFields: (idx) => [
        IndexedField<_OrderForm, String>(
          fieldName: 'productName',
          parentPath: 'items',
          index: idx,
          validate: (v) => v != null && v.length >= 2
              ? ValidasiResult.success(v)
              : ValidasiResult.error(
                  ValidationError(rule: 'MinLength', message: 'Too short'),
                ),
          validateAsync: (v) async => v != null && v.length >= 2
              ? ValidasiResult.success(v)
              : ValidasiResult.error(
                  ValidationError(rule: 'MinLength', message: 'Too short'),
                ),
          extractFromItem: (item) => (item as _LineItem).productName,
        ),
        IndexedField<_OrderForm, int>(
          fieldName: 'quantity',
          parentPath: 'items',
          index: idx,
          validate: (v) => v != null && v >= 1
              ? ValidasiResult.success(v)
              : ValidasiResult.error(
                  ValidationError(rule: 'Min', message: 'Min 1'),
                ),
          validateAsync: (v) async => v != null && v >= 1
              ? ValidasiResult.success(v)
              : ValidasiResult.error(
                  ValidationError(rule: 'Min', message: 'Min 1'),
                ),
          extractFromItem: (item) => (item as _LineItem).quantity,
        ),
        IndexedField<_OrderForm, String>(
          fieldName: 'note',
          parentPath: 'items',
          index: idx,
          validate: (v) => ValidasiResult.success(v),
          validateAsync: (v) async => ValidasiResult.success(v),
          extractFromItem: (item) => (item as _LineItem).note,
        ),
      ],
      reconstructItem: (ctrl, idx) => _LineItem(
        productName: ctrl.getValue(
          ctrl.getArraySubField(_itemsField, idx, 'productName')!,
        ),
        quantity: ctrl.getValue(
          ctrl.getArraySubField(_itemsField, idx, 'quantity')!,
        ),
        note: ctrl.getValue(
          ctrl.getArraySubField(_itemsField, idx, 'note')!,
        ),
      ),
      reconstructAll: (ctrl) {
        final count = ctrl.getArrayItemCount(_itemsField);
        final result = <_LineItem>[];
        for (var i = 0; i < count; i++) {
          result.add(_LineItem(
            productName: ctrl.getValue(
              ctrl.getArraySubField(_itemsField, i, 'productName')!,
            ),
            quantity: ctrl.getValue(
              ctrl.getArraySubField(_itemsField, i, 'quantity')!,
            ),
            note: ctrl.getValue(
              ctrl.getArraySubField(_itemsField, i, 'note')!,
            ),
          ));
        }
        return result;
      },
    );
  }
  return ctrl;
}

double _mean(List<int> samples) =>
    samples.reduce((a, b) => a + b) / samples.length;

void main() {
  const iterations = 5;

  test('1. Build 50 items', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      _createController(itemCount: 50);
      times.add(sw.elapsedMicroseconds);
    }
    print('Build (50 items): ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('2. Reconstruct parent list', () {
    final ctrl = _createController(itemCount: 50);
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      ctrl.getValue(_itemsField);
      times.add(sw.elapsedMicroseconds);
    }
    print('Reconstruct (50 items): ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('3. Validate all fields', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final ctrl = _createController(itemCount: 50);
      final sw = Stopwatch()..start();
      ctrl.validate();
      times.add(sw.elapsedMicroseconds);
    }
    print('Validate (50 items × 3 fields): ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('4. Append 10 items', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final ctrl = _createController(itemCount: 0);
      final sw = Stopwatch()..start();
      for (var j = 0; j < 10; j++) {
        ctrl.appendArrayItem(
          _itemsField,
          const _LineItem(productName: 'Widget', quantity: 1),
          indexedFields: (idx) => [
            IndexedField<_OrderForm, String>(
              fieldName: 'productName',
              parentPath: 'items',
              index: idx,
              validate: (v) => ValidasiResult.success(v),
              validateAsync: (v) async => ValidasiResult.success(v),
              extractFromItem: (item) => (item as _LineItem).productName,
            ),
          ],
          reconstructItem: (c, i) =>
              const _LineItem(productName: '', quantity: 0),
          reconstructAll: (c) => [],
        );
      }
      times.add(sw.elapsedMicroseconds);
    }
    print('Append 10 items: ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('5. Remove 5 items', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final ctrl = _createController(itemCount: 50);
      final sw = Stopwatch()..start();
      for (var j = 0; j < 5; j++) {
        ctrl.removeArrayItem(_itemsField, 0);
      }
      times.add(sw.elapsedMicroseconds);
    }
    print('Remove 5 items: ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('6. Swap 10 pairs', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final ctrl = _createController(itemCount: 50);
      final sw = Stopwatch()..start();
      for (var j = 0; j < 10; j++) {
        ctrl.swapArrayItems(_itemsField, j, 49 - j);
      }
      times.add(sw.elapsedMicroseconds);
    }
    print('Swap 10 pairs: ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('7. Full validation with extras', () {
    final times = <int>[];
    for (var i = 0; i < iterations; i++) {
      final ctrl = _createController(itemCount: 50);
      ctrl.register(_orderNoteField);
      ctrl.register(_referralField);
      ctrl.setValue(_orderNoteField, 'Deliver after 5pm');
      ctrl.setValue(_referralField, 'DISCOUNT10');
      final sw = Stopwatch()..start();
      ctrl.validate();
      times.add(sw.elapsedMicroseconds);
    }
    print('Full validate (50 items + note + referral): ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });

  test('8. Async validation (100ms simulated server)', () async {
    final times = <int>[];
    for (var i = 0; i < 3; i++) {
      final ctrl = _createController(itemCount: 50);
      ctrl.setFieldValidator(
        _referralField,
        (code) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return (code != null && code.length >= 4) ? null : 'Invalid code';
        },
        debounce: const Duration(milliseconds: 5),
      );
      ctrl.setValue(_referralField, 'SAVE20');
      final sw = Stopwatch()..start();
      await ctrl.triggerAsyncValidation(_referralField);
      times.add(sw.elapsedMicroseconds);
    }
    print('Async validate (100ms server): ${times.join(', ')} µs');
    print('  Avg: ${_mean(times).toStringAsFixed(0)} µs');
  });
}

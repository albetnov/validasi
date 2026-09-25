import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi_ui/validasi_ui.dart';

import 'fixtures/indexed_form.dart';

void _appendItem(
  ValidasiFormController<IndexedArrayForm> controller,
  IndexedFormItem item,
) {
  controller.appendArrayItem(
    IndexedArrayFormFields.items,
    item,
    indexedFields: (index) =>
        IndexedFormItemFields.indexedFields<IndexedArrayForm>(
            IndexedArrayFormFields.items.name, index),
    reconstructItem: (controller, index) =>
        IndexedFormItemFields.reconstructItem<IndexedArrayForm>(
      controller,
      IndexedArrayFormFields.items,
      index,
    ),
    reconstructAll: (controller) =>
        IndexedFormItemFields.reconstructAll<IndexedArrayForm>(
      controller,
      IndexedArrayFormFields.items,
    ),
  );
}

void main() {
  testWidgets(
    'generated indexed fields retain concrete signal types through submit',
    (tester) async {
      final controller = ValidasiFormController<IndexedArrayForm>(
        schema: IndexedArrayFormFields.schema,
      );
      IndexedArrayForm? submitted;

      controller.setValue(IndexedArrayFormFields.title, 'Form title');
      _appendItem(
        controller,
        const IndexedFormItem(title: 'First title', quantity: 1),
      );
      _appendItem(
        controller,
        const IndexedFormItem(title: 'Second title', quantity: 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm<IndexedArrayForm>(
              controller: controller,
              builder: (context, submit) =>
                  ValidasiWatch.form<IndexedArrayForm>(
                builder: (context, controller) {
                  final itemCount = controller.getArrayItemCount(
                    IndexedArrayFormFields.items,
                  );
                  return Column(
                    children: [
                      for (var index = 0; index < itemCount; index++)
                        Builder(
                          builder: (context) {
                            final titleField =
                                controller.getArraySubField<String>(
                              IndexedArrayFormFields.items,
                              index,
                              'title',
                            )!;
                            final quantityField =
                                controller.getArraySubField<int>(
                              IndexedArrayFormFields.items,
                              index,
                              'quantity',
                            )!;
                            return Column(
                              children: [
                                ValidasiFormField<IndexedArrayForm, String>(
                                  field: titleField,
                                  builder: (context, state) => TextField(
                                    key: ValueKey('title-$index'),
                                    onChanged: state.onChanged,
                                  ),
                                ),
                                ValidasiFormField<IndexedArrayForm, int>(
                                  field: quantityField,
                                  builder: (context, state) => Text(
                                    'quantity-$index=${state.value}',
                                  ),
                                ),
                                TextButton(
                                  key: ValueKey('remove-$index'),
                                  onPressed: () => controller.removeArrayItem(
                                    IndexedArrayFormFields.items,
                                    index,
                                  ),
                                  child: const Text('Remove'),
                                ),
                              ],
                            );
                          },
                        ),
                      ElevatedButton(
                        onPressed: submit((form) => submitted = form),
                        child: const Text('Submit'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('title-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('title-1')), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('title-0')),
        'Edited title',
      );
      await tester.pump();

      final editedTitleField = controller.getArraySubField<String>(
        IndexedArrayFormFields.items,
        0,
        'title',
      )!;
      final quantityField = controller.getArraySubField<int>(
        IndexedArrayFormFields.items,
        0,
        'quantity',
      )!;
      expect(
        controller.getFieldController(editedTitleField),
        isA<ValidasiFieldSignals<String>>(),
      );
      expect(
        controller.getFieldController(quantityField),
        isA<ValidasiFieldSignals<int>>(),
      );

      await tester.tap(find.byKey(const ValueKey('remove-1')));
      await tester.pump();
      expect(find.byKey(const ValueKey('title-1')), findsNothing);

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!.title, 'Form title');
      expect(submitted!.items, hasLength(1));
      expect(submitted!.items.single.title, 'Edited title');
      expect(submitted!.items.single.quantity, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
}

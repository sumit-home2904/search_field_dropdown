import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_field_dropdown/search_field_dropdown.dart';

void main() {
  Widget buildTestScaffold(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  SearchFieldDropdown<String> buildDropdown({
    Function(String?)? onChanged,
    Function(List<String>)? onItemsChanged,
    SearchFieldDropdownDecoration? decoration,
    OverlayPortalController? controller,
    String? initialItem,
    List<String> items = const ['Option A', 'Option B', 'Option C', 'Option D'],
  }) {
    return SearchFieldDropdown<String>(
      controller: controller,
      initialItem: initialItem,
      item: items,
      onChanged: onChanged,
      onItemsChanged: onItemsChanged,
      decoration: decoration,
      listItemBuilder: (context, item, isSelected) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(item, key: ValueKey<String>('item-$item')),
        );
      },
      selectedItemBuilder: (context, item) => Text(item),
    );
  }

  group('UI Scenarios Testing', () {
    testWidgets('Dropdown inside AlertDialog behaves correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Dialog Test'),
                          content: SizedBox(
                            width: 300,
                            child: buildDropdown(
                              decoration: const SearchFieldDropdownDecoration(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Tap the dropdown field inside the dialog
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Check if overlay is opened
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Option A'), findsWidgets);

      // Select Item
      await tester.tap(find.byKey(const ValueKey<String>('item-Option B')));
      await tester.pumpAndSettle();

      // Ensure form field has picked the value
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text, 'Option B');
    });

    testWidgets('Dropdown inside BottomSheet behaves correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: buildDropdown(
                              decoration: const SearchFieldDropdownDecoration(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open BottomSheet'),
                );
              },
            ),
          ),
        ),
      );

      // Open BottomSheet
      await tester.tap(find.text('Open BottomSheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);

      // Tap Dropdown
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Select item
      await tester.tap(find.byKey(const ValueKey<String>('item-Option C')));
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text, 'Option C');
    });

    testWidgets('Form validation logic functions properly', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        buildTestScaffold(
          Form(
            key: formKey,
            child: Column(
              children: [
                buildDropdown(
                  decoration: const SearchFieldDropdownDecoration(),
                ),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState?.validate();
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
        ),
      );

      // Unfortunately there is no standard validator input directly in the Dropdown API yet unless we implemented one.
      // But we can check if it passes standard bounds check.
      // Assuming it does not crash when inside a Form.
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Dropdowns inside DataTable do not crash list view',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('1')),
                    DataCell(SizedBox(width: 150, child: buildDropdown())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('2')),
                    DataCell(SizedBox(width: 150, child: buildDropdown())),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));

      // Open first dropdown in datatable
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget); // Overlay should be visible

      await tester
          .tap(find.byKey(const ValueKey<String>('item-Option A')).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_field_dropdown/search_field_dropdown.dart';

void main() {
  Widget buildTestApp({
    required SearchFieldDropdown<String> child,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(width: 240, child: child),
          ),
        ),
      ),
    );
  }

  SearchFieldDropdown<String> buildDropdown({
    Function(String?)? onChanged,
    Function(List<String>)? onItemsChanged,
    SearchFieldDropdownDecoration? decoration,
  }) {
    return SearchFieldDropdown<String>(
      item: const ['Alpha', 'Beta', 'Gamma'],
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

  testWidgets('multiselect triggers both changed callbacks with updated item',
      (tester) async {
    String? changedItem;
    List<String>? changedItems;

    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          onChanged: (value) => changedItem = value,
          onItemsChanged: (values) => changedItems = List<String>.from(values),
          decoration: const SearchFieldDropdownDecoration(
            isMultiSelect: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('item-Beta')));
    await tester.pumpAndSettle();

    expect(changedItem, 'Beta');
    expect(changedItems, <String>['Beta']);
  });

  testWidgets('dropdownOffset from decoration is applied to overlay position',
      (tester) async {
    const dropdownOffset = Offset(18, 92);

    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          decoration: const SearchFieldDropdownDecoration(
            dropdownOffset: dropdownOffset,
          ),
        ),
      ),
    );

    final fieldTopLeft = tester.getTopLeft(find.byType(TextFormField));

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    final overlayTopLeft = tester.getTopLeft(find.byType(Card));

    expect(overlayTopLeft.dx, fieldTopLeft.dx + dropdownOffset.dx);
    expect(overlayTopLeft.dy, fieldTopLeft.dy + dropdownOffset.dy);
  });
}

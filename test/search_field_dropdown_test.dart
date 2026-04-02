import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_field_dropdown/search_field_dropdown.dart';

void main() {
  const parentScrollKey = ValueKey<String>('parent-scroll-view');

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
    OverlayPortalController? controller,
    FocusNode? focusNode,
    String? initialItem,
    List<String>? initialItems,
    List<String> items = const ['Alpha', 'Beta', 'Gamma'],
  }) {
    return SearchFieldDropdown<String>(
      controller: controller,
      focusNode: focusNode,
      initialItem: initialItem,
      initialItems: initialItems,
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

  Widget buildScrollableTestApp({
    SearchFieldDropdownDecoration? decoration,
    ScrollController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          key: parentScrollKey,
          controller: controller,
          children: [
            const SizedBox(height: 200),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: 240,
                child: buildDropdown(decoration: decoration),
              ),
            ),
            const SizedBox(height: 800),
          ],
        ),
      ),
    );
  }

  Widget buildResizableTestApp({
    required ValueNotifier<double> widthNotifier,
    OverlayPortalController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<double>(
              valueListenable: widthNotifier,
              builder: (context, width, child) {
                return SizedBox(
                  width: width,
                  child: buildDropdown(controller: controller),
                );
              },
            ),
          ),
        ),
      ),
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

  testWidgets('single select keeps chosen value without parent rebuild',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('item-Beta')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Beta');
  });

  testWidgets('focus loss keeps live multiselect text, not stale initial items',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          focusNode: focusNode,
          initialItems: const ['Alpha'],
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

    focusNode.unfocus();
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Alpha, Beta');
  });

  testWidgets('multiselect renders checkbox builder when enabled',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          decoration: SearchFieldDropdownDecoration(
            isMultiSelect: true,
            multiSelectCheckBuilder: (context, selected) {
              return Checkbox(
                value: selected,
                onChanged: null,
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsWidgets);
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

  testWidgets('overlayHeight from decoration caps overlay height',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          decoration: const SearchFieldDropdownDecoration(
            overlayHeight: 40,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(Card)).height, 40);
  });

  testWidgets('overlay keeps shrinking to content when item count is low',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: buildDropdown(
          items: const ['Only one'],
          decoration: const SearchFieldDropdownDecoration(
            overlayHeight: 200,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(Card)).height, lessThan(200));
  });

  testWidgets('controller changes do not keep stale overlay attachments',
      (tester) async {
    final controllerA = OverlayPortalController();
    final controllerB = OverlayPortalController();

    Widget buildControllerList(List<OverlayPortalController> controllers) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              for (final controller in controllers)
                SizedBox(
                  width: 240,
                  child: buildDropdown(controller: controller),
                ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildControllerList([controllerA]));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(buildControllerList([controllerB, controllerA]));
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlay width tracks field width while dropdown is open',
      (tester) async {
    final widthNotifier = ValueNotifier<double>(240);
    final controller = OverlayPortalController();

    await tester.pumpWidget(
      buildResizableTestApp(
        widthNotifier: widthNotifier,
        controller: controller,
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    final double initialWidth = tester.getSize(find.byType(Card)).width;
    expect(initialWidth, 240);

    widthNotifier.value = 320;
    await tester.pump();
    await tester.pumpAndSettle();

    final double resizedWidth = tester.getSize(find.byType(Card)).width;
    expect(resizedWidth, 320);
  });

  testWidgets('dropdown closes when parent scrollable starts scrolling',
      (tester) async {
    final controller = ScrollController();
    final decoration = SearchFieldDropdownDecoration(
      parentScrollController: controller,
    );

    await tester.pumpWidget(
      buildScrollableTestApp(
        controller: controller,
        decoration: decoration,
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);

    await tester.dragFrom(const Offset(200, 580), const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('dropdown can stay open during parent scroll when disabled',
      (tester) async {
    final controller = ScrollController();
    final decoration = SearchFieldDropdownDecoration(
      parentScrollController: controller,
      closeDropdownOnParentScroll: false,
    );

    await tester.pumpWidget(
      buildScrollableTestApp(
        controller: controller,
        decoration: decoration,
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);

    await tester.dragFrom(const Offset(200, 580), const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(find.byType(Card), findsOneWidget);
  });

  // ---------------------------------------------------------------
  // Regression: removing a list-row that contains a SearchFieldDropdown
  // used to crash with 'attached: is not true' because the overlay's
  // AnimatedBuilder still held a reference to the now-detached RenderBox.
  // ---------------------------------------------------------------
  testWidgets(
      'no crash when a row containing the dropdown is removed from the list',
      (tester) async {
    // Simulate a DataTable-like list where each row has its own dropdown.
    final rows = ValueNotifier<List<String>>(['Row A', 'Row B', 'Row C']);

    Widget buildRowList() {
      return MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<String>>(
            valueListenable: rows,
            builder: (context, currentRows, _) {
              return ListView(
                children: currentRows.map((rowLabel) {
                  return Padding(
                    key: ValueKey<String>(rowLabel),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: Text(rowLabel)),
                        SizedBox(
                          width: 200,
                          child: SearchFieldDropdown<String>(
                            item: const ['Option 1', 'Option 2'],
                            listItemBuilder: (ctx, item, sel) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(item,
                                  key:
                                      ValueKey<String>('$rowLabel-item-$item')),
                            ),
                            selectedItemBuilder: (ctx, item) => Text(item),
                          ),
                        ),
                        IconButton(
                          key: ValueKey<String>('delete-$rowLabel'),
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            rows.value = List<String>.from(rows.value)
                              ..remove(rowLabel);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildRowList());
    await tester.pumpAndSettle();

    // Verify 3 rows are rendered
    expect(find.text('Row A'), findsOneWidget);
    expect(find.text('Row B'), findsOneWidget);
    expect(find.text('Row C'), findsOneWidget);

    // Open dropdown in Row B
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));
    await tester.tap(textFields.at(1)); // Row B's text field
    await tester.pumpAndSettle();

    // Dropdown overlay should be visible
    expect(find.byType(Card), findsOneWidget);

    // Remove Row B while its dropdown is open — this is the crash scenario.
    // We mutate the list directly (simulating a parent setState / DataTable
    // row removal) rather than tapping the delete button which is behind
    // the overlay's dismiss barrier.
    rows.value = List<String>.from(rows.value)..remove('Row B');
    await tester.pumpAndSettle();

    // Should NOT crash; Row B should be gone
    expect(find.text('Row B'), findsNothing);
    expect(find.text('Row A'), findsOneWidget);
    expect(find.text('Row C'), findsOneWidget);

    // No exceptions should have been thrown
    expect(tester.takeException(), isNull);
  });

  testWidgets('no crash when multiple rows are removed rapidly from a list',
      (tester) async {
    final rows = ValueNotifier<List<String>>(['R1', 'R2', 'R3', 'R4', 'R5']);

    Widget buildRowList() {
      return MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<String>>(
            valueListenable: rows,
            builder: (context, currentRows, _) {
              return ListView(
                children: currentRows.map((rowLabel) {
                  return Padding(
                    key: ValueKey<String>(rowLabel),
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 200,
                      child: SearchFieldDropdown<String>(
                        item: const ['A', 'B'],
                        listItemBuilder: (ctx, item, sel) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(item),
                        ),
                        selectedItemBuilder: (ctx, item) => Text(item),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildRowList());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(5));

    // Open dropdown on 3rd item
    await tester.tap(find.byType(TextFormField).at(2));
    await tester.pumpAndSettle();

    // Rapidly remove rows while overlay may still be reacting
    rows.value = ['R1', 'R5']; // remove R2, R3, R4 at once
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing the ONLY row with a dropdown does not crash',
      (tester) async {
    final rows = ValueNotifier<List<String>>(['Solo']);

    Widget buildRowList() {
      return MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<String>>(
            valueListenable: rows,
            builder: (context, currentRows, _) {
              return Column(
                children: currentRows.map((rowLabel) {
                  return SizedBox(
                    key: ValueKey<String>(rowLabel),
                    width: 200,
                    child: SearchFieldDropdown<String>(
                      item: const ['X', 'Y'],
                      listItemBuilder: (ctx, item, sel) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item),
                      ),
                      selectedItemBuilder: (ctx, item) => Text(item),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildRowList());
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    // Remove the only row
    rows.value = [];
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

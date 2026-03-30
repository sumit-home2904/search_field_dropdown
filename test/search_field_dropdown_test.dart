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
    List<String> items = const ['Alpha', 'Beta', 'Gamma'],
  }) {
    return SearchFieldDropdown<String>(
      controller: controller,
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
}

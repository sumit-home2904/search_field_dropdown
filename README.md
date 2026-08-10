# search_field_dropdown 🛠️

[![Pub Version](https://img.shields.io/pub/v/search_field_dropdown?color=blue)](https://pub.dev/packages/search_field_dropdown)
[![Flutter Platform](https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

SearchFieldDropdown widget implementation in Flutter. This widget provides a customizable search field with a dropdown menu that can be populated either statically or dynamically through an API call. It includes various customization options and supports keyboard navigation.

---

## 📸 Demo

<img src="https://raw.githubusercontent.com/sumit-home2904/search_field_dropdown/master/search_field_dropdown.gif">

## ✨ Features

- **Named Factory Constructors**: Dedicated `SearchFieldDropdown.singleSelection` and `SearchFieldDropdown.multiSelection` constructors for clean, mode-focused parameter auto-complete without needing `isMultiSelect` boolean flags.
- **Automatic Focus Dismissal**: Auto-unfocuses text field and closes soft keyboard when an item is selected in single selection mode.
- **Soft Keyboard Awareness**: Dynamically predicts soft keyboard height so overlay menus near the bottom of the screen open above the text field immediately instead of getting covered when the keyboard slides up.
- **Automatic API Loader**: Automatically toggles `isApiLoading` state during `onTap` and `onSearch` execution and displays `loaderWidget` or progress indicator.
- **Static & Dynamic Data**: Display static items or fetch them dynamically via APIs.
- **Single & Multi-Select**: Support for Single-Select and Multi-Select dropdowns with native checkboxes & external display chip builders.
- **High Customizability**: Fully customizable dropdown appearance using `SearchFieldDropdownDecoration` and custom item builders.
- **Readonly & Searchable**: Support for readonly and searchable dropdowns, along with additional styling customization options.
- **Custom Add Button**: Seamless integration of an add-button for custom functionality.
- **Advanced Filtering**: Flexible search and filter options, supporting both local and API-based data.

---

## 🚀 Installation

1. Add the latest version of the package to your `pubspec.yaml` (and run `flutter pub get`):

```yaml
dependencies:
  search_field_dropdown: ^2.0.0
```

2. Import the package and use it in your Flutter App.

```dart
import 'package:search_field_dropdown/search_field_dropdown.dart';
```

---

## 📖 Example Usage

### 1. Basic SearchFieldDropdown (Single Selection)

A `GlobalKey<SearchFieldDropdownState>` is used to uniquely identify and manage the state of a SearchFieldDropdown widget, allowing you to interact with its internal state (e.g., selecting an item or retrieving the selected value) from outside the widget.

```dart
final GlobalKey<SearchFieldDropdownState<String>> dropdownKey = GlobalKey<SearchFieldDropdownState<String>>();
final itemList = ['Option 1', 'Option 2', 'Option 3'];

class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchFieldDropdown<String>.singleSelection(
        key: dropdownKey, // Attach the GlobalKey to the widget
        item: itemList,
        onChanged: (value) {
          print('Selected: $value');
        },
        listItemBuilder: (context, item, isActive) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(item),
          );
        },
        selectedItemBuilder: (context, item) => Text(item),
      )
    );
  }
}
```

### 2. SearchFieldDropdown with a Custom Add Button

The `addButton` property lets you define a custom widget to trigger additional actions, such as opening a dialog box, navigating to another screen, or performing user-defined functionality.

```dart
class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchFieldDropdown<String>.singleSelection(
            item : itemList,
            controller: itemController,
            addButton:  InkWell(
              onTap: () {
                // Add your custom event here
              },
              child: Container(
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                          "Add",
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white)
                      ),
                    ),
                    Icon(Icons.add, color: Colors.white)
                  ],
                ),
              ),
            ),
            decoration: SearchFieldDropdownDecoration(
              canShowButton: true,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              menuDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blueAccent)
              ),
              fieldDecoration: const InputDecoration(),
            ),
            onChanged: (String? value) {},
            listItemBuilder: (context, item, isSelected) {
              return Text(
                item,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 3. Custom Dropdown with Custom Type Model

Let's start with the type of object we are going to work with:

```dart
class ItemModel {
  final int id;
  final String name;

  ItemModel({required this.id, required this.name});

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json["id"],
    name: json["name"],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ItemModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
```

### 4. SearchFieldDropdown with Dynamic Search or API Integration

Advanced usage example for fetching dropdown items dynamically from an API with automatic loading indicators.

```dart
class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchFieldDropdown<String>.singleSelection(
            controller: itemController,
            initialItem: selectedItem,
            item: const [],
            onTap: () async {
              // Example API call, or return your API list.
              return itemList;
            },
            onSearch: (value) async {
              // Fetch API data and filter here
              return itemList.where((element) {
                return element.toLowerCase().contains(value.toLowerCase());
              }).toList();
            },
            loaderWidget: const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            decoration: SearchFieldDropdownDecoration(
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                fieldDecoration: const InputDecoration(hintText: "Search remote items..."),
            ),
            onChanged: (String? value) {},
            listItemBuilder: (context, item, isSelected) {
              return Text(
                item,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 5. Multi-Select SearchFieldDropdown

Advanced usage example featuring `SearchFieldDropdown.multiSelection`, custom selection parsing, and outer UI chips display integration.

```dart
SearchFieldDropdown<String>.multiSelection(
  initialItems: const [],
  item: const ['Apple', 'Banana', 'Orange', 'Mango'],
  controller: itemController,
  decoration: SearchFieldDropdownDecoration(
      showSelectedItemsInField: false,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      fieldDecoration: const InputDecoration(hintText: "Select multiple fruits"),
  ),
  onItemsChanged: (List<String> values) {
    print("Multi selections: $values");
  },
  listItemBuilder: (context, item, isSelected) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(item, style: const TextStyle(fontSize: 12)),
    );
  },
  selectedItemsBuilder: (context, items) { // Customise string output shown in the field
    return items.join(', ');
  },
  multiSelectDisplayBuilder: (context, selectedItems, onRemove) { // Chips built automatically underneath Dropdown
    if (selectedItems.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8.0,
      children: selectedItems.map((fruit) {
        return Chip(
          label: Text(fruit),
          onDeleted: () => onRemove(fruit),
        );
      }).toList(),
    );
  },
)
```

> **Note:** `listItemBuilder`'s third parameter (`isActive`) represents the currently active row, which is useful for keyboard navigation and hover styling. To customize the multi-select checked state, use `decoration.multiSelectCheckBuilder`.

---

## ⚙️ Properties

### SearchFieldDropdown Widget Props

| Property | Type | Description |
|---|---|---|
| `key` | `GlobalKey<SearchFieldDropdownState>()` | Use for maintaining state. |
| `item` | `List<T>` | List of dropdown items to display. |
| `initialItems` | `List<T>?` | Defines multiple initial entries for multi-select. |
| `initialItem` | `T?` | Initial value for the single-select dropdown. |
| `decoration` | `SearchFieldDropdownDecoration?` | Holds dropdown styling plus behavior flags (multi-select, readonly, etc). |
| `isApiLoading` | `bool` | Indicates if the API is loading. |
| `loaderWidget` | `Widget?` | Custom widget to show during API loading. |
| `focusNode` | `FocusNode?` | Manages focus for searchable dropdowns. |
| `addButton` | `Widget?` | Adds a custom button for additional functionality. |
| `onChanged` | `Function(T? value)` | Callback triggered when a single item is selected. |
| `onItemsChanged` | `Function(List<T> values)` | Callback triggered when multiple items are selected. |
| `onTap` | `Future<List<T>> Function()` | Loads items dynamically for the dropdown. |
| `autovalidateMode` | `AutovalidateMode?` | Enables validation listener when items change. |
| `controller` | `OverlayPortalController` | Controls dropdown visibility programmatically. |
| `listItemBuilder` | `ListItemBuilder<T>` | Custom builder for dropdown rows. |
| `selectedItemBuilder` | `SelectedItemBuilder<T>?` | Custom builder for the selected single item. |
| `selectedItemsBuilder` | `SelectedItemsBuilder<T>?` | Custom text formatting for multiple selected items. |
| `multiSelectDisplayBuilder` | `MultiSelectDisplayBuilder<T>?` | Custom UI generic display below the search field (e.g. chips). |
| `onSearch` | `Future<List<T>> Function(String)` | Callback for API-based search functionality. |
| `inputFormatters` | `List<TextInputFormatter>?` | Applies input formatting rules to the `TextFormField`. |
| `validator` | `String? Function(String?)` | Validates the dropdown value. |
| `enableInteractiveSelection` | `bool?` | Enables or disables text selection in `TextFormField`. |

### SearchFieldDropdownDecoration Props

| Property | Type | Description |
|---|---|---|
| `isMultiSelect` | `bool?` | Enables multi-select capabilities with internal checkbox support. |
| `showSelectedItemsInField` | `bool?` | Controls whether selected multi-select values are rendered back into the field text. |
| `multiSelectCheckBuilder` | `MultiSelectCheckBuilder?` | Custom trailing indicator for each multi-select row. |
| `multiSelectCheckedIcon` | `IconData?` | Icon used for selected items when no custom check builder is supplied. |
| `multiSelectUncheckedIcon` | `IconData?` | Icon used for unselected items when no custom check builder is supplied. |
| `multiSelectCheckedIconColor` | `Color?` | Color for the selected icon state. |
| `multiSelectUncheckedIconColor` | `Color?` | Color for the unselected icon state. |
| `canShowButton` | `bool?` | Toggles the visibility of the optional add button area inside the overlay. |
| `fieldReadOnly` | `bool?` | Makes the internal `TextFormField` readonly. |
| `readOnly` | `bool?` | Prevents the dropdown overlay from opening on tap. |
| `parentScrollController` | `ScrollController?` | Optional parent scroll controller used to auto-dismiss the dropdown on outer scroll reliably. |
| `closeDropdownOnParentScroll` | `bool?` | Auto closes the open dropdown when its parent `ScrollView` starts scrolling. |
| `dropdownOffset` | `Offset?` | Adjusts the overlay position relative to the text field. |
| `overlayHeight` | `double?` | Preferred maximum height of the dropdown overlay. |
| `errorMessage` | `Text?` | Custom error widget text when no items are found. |
| `textStyle` | `TextStyle?` | Styles the field text. |
| `textAlign` | `TextAlign?` | Aligns the text in the field. |
| `keyboardType` | `TextInputType?` | Sets the input type for the `TextFormField`. |
| `showCursor` | `bool?` | Toggles the cursor visibility. |
| `cursorColor` | `Color?` | Sets cursor color. |
| `cursorHeight` | `double?` | Sets cursor height. |
| `cursorWidth` | `double?` | Sets cursor width. |
| `cursorRadius` | `Radius?` | Sets cursor radius. |
| `cursorErrorColor` | `Color?` | Sets cursor error color. |
| `menuDecoration` | `BoxDecoration?` | Styles the dropdown container. |
| `fieldDecoration` | `InputDecoration?` | Styles the text field. |
| `listPadding` | `EdgeInsetsGeometry?` | Padding applied to the overlay list. |
| `elevation` | `double?` | Elevation of the dropdown card. |
| `focusedItemDecoration` | `BoxDecoration?` | Decoration applied to the active row. |
| `unfocusedItemDecoration` | `BoxDecoration?` | Decoration applied to non-active rows. |
| `itemPadding` | `EdgeInsetsGeometry?` | Shared padding applied around each row item. |

---

## 🤝 Contributors

A huge thanks to the following people who have contributed to this project:

- **Sumit Sharma** *(Creator & Maintainer)* - [@sumit-home2904](https://github.com/sumit-home2904)
- **Yagnesh-chauhan7** - [@Yagnesh-chauhan7](https://github.com/Yagnesh-chauhan7)

*(Feel free to open a pull request if you want to contribute!)*

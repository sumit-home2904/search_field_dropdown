# search_field_dropdown 🛠️

SearchFieldDropdown widget implementation in Flutter. This widget provides a customizable search 
field with a dropdown menu that can be populated either statically or dynamically through an 
API call. It includes various customization options and supports keyboard navigation.
---

## Features

- Display static items or fetch them dynamically via APIs.
- Support for Single-Select and Multi-Select dropdowns with native checkboxes & external display chip builders.
- Fully customizable dropdown appearance using `SearchFieldDropdownDecoration` and custom item builders.
- Support for readonly and searchable dropdowns, along with additional styling customization options.
- Seamless integration of an add-button for custom functionality.
- Flexible search and filter options, supporting both local and API-based data.

---

## Installation
1.Add the latest version of package to your pubspec.yaml (and run flutter pub get):

```yaml
dependencies:
  search_field_dropdown: latest_version
```

2.Import the package and use it in your Flutter App.
```dart
import 'package:search_field_dropdown/search_field_dropdown.dart';
```

## Example usage
### **1.Basic SearchFieldDropdown**

A GlobalKey`<FormFiledDropDownState>` is used to uniquely identify and manage the state of a FormFiledDropDown 
widget, allowing you to interact with its internal state (e.g., selecting an item or retrieving the selected value) 
from outside the widget.

**Purpose:**
    The GlobalKey`<FormFiledDropDownState>` allows you to access the state of the FormFiledDropDown widget,
    which is useful when you need to control the dropdown’s behavior programmatically. By associating a key 
    with the FormFiledDropDown, you can call methods on its state, trigger a rebuild, or update its selected 
    value from a parent widget or another part of your app.

```dart
final GlobalKey<SearchFieldDropdownState<String>> dropdownKey = GlobalKey<SearchFieldDropdownState<String>>();
```

```dart

class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchFieldDropdown<String>(
        key: dropdownKey, // Attach the GlobalKey to the widget
        items: ['Option 1', 'Option 2', 'Option 3'],
        onChanged: (value) {
          print('Selected: $value');
        },
      )
    );
  }
}
```


### **2.SearchFieldDropdown with a Custom Add Button**
The addButton property lets you define a custom widget to trigger additional actions, such as 
opening a dialog box, navigating to another screen, or performing user-defined functionality.

```dart
class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          SearchFieldDropdown<String>(
            item : itemList,
            controller: itemController,
            canShowButton: true,
            addButton:  InkWell(
              onTap: () {
                // add your event's
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration:BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                          "Add",
                          maxLines: 1,
                          textAlign:TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white)
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
            decoration: SearchFieldDropdownDecoration(
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

### **3 Custom dropdown with custom type model

Let's start with the type of object we are going to work with:

``` dart
 class ItemModel {
  final int id;
  final String name;


  ItemModel({required this.id, required this.name});


  factory ItemModel.fromJson(Map<String, dynamic> json) => CityModel(
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

### **4.SearchFieldDropdown with Dynamic Search or API Integration**

Advanced usage example for fetching dropdown items dynamically from an API.

```dart
class DropDownClass extends StatelessWidget {
  const DropDownClass({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          SearchFieldDropdown<String>(
            controller: itemController,
            initialItem: selectedItem,
            item : itemList,
            onTap: () async{
              // example API, or return your API list.
              return itemList;
            },
            decoration: SearchFieldDropdownDecoration(
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                fieldDecoration: const InputDecoration(),
            ),
            onChanged: (String? value) {},
            onSearch: (value) async {
              // We can call your API and search from it. Also, I can implement local search in your static list.
              return itemList.where((element) {
                return element.contains(value.toLowerCase());
              }).toList();
            },
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

### **5. Multi-Select SearchFieldDropdown**

Advanced usage example featuring multi-select configurations, custom selection parsing, and outer UI chips display integration.

```dart
SearchFieldDropdown<String>(
  isMultiSelect: true,
  initialItems: [],
  item: ['Apple', 'Banana', 'Orange', 'Mango'],
  controller: itemController,
  decoration: SearchFieldDropdownDecoration(
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
  showSelectedItemsInField: false, // Prevents text populating the main field if you prefer chips below it
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

## Properties

| Property | Type | Description |
|---|---|---|
| `key` | `GlobalKey<SearchFieldDropdownState>()` | Use for maintain state. |
| `item` | `List<T>?` | List of dropdown items to display. |
| `isMultiSelect` | `bool` | Enables multi-select capabilities with internal checkboxes. |
| `initialItems` | `List<T>?` | Defines multiple initial entries for multi-select. |
| `initialItem` | `T?` | Initial value for the single-select dropdown. |
| `decoration` | `SearchFieldDropdownDecoration?` | Container unifying custom cursor, menu layouts, backgrounds, padding, and text field styles. |
| `fieldReadOnly` | `bool` | Makes `TextFormField` readonly. |
| `readOnly` | `bool` | Makes dropdown readonly. |
| `isApiLoading` | `bool` | Indicates if the API is loading. |
| `dropdownOffset` | `bool` | Change drop-down opening offset |
| `showCursor` | `bool?` | Toggles the cursor visibility. |
| `loaderWidget` | `Widget?` | Custom widget to show during API loading. |
| `focusNode` | `FocusNode?` | Manages focus for searchable dropdowns. |
| `errorMessage` | `Text?` | Custom error message when no items are found. |
| `overlayHeight` | `double?` | Height of the dropdown overlay. |
| `addButton` | `Widget?` | Adds a custom button for additional functionality. |
| `onChanged` | `Function(T? value)` | Callback triggered when a single item is selected. |
| `onItemsChanged` | `Function(List<T> values)` | Callback triggered when multiple items are selected. |
| `onTap` | `Future<List<T>> Function()` | Loads items dynamically for the dropdown. |
| `autovalidateMode` | `AutovalidateMode?` | Enables validation listener when items change. |
| `controller` | `OverlayPortalController` | Controls dropdown visibility programmatically. |
| `listItemBuilder` | `ListItemBuilder<T>` | Custom builder for dropdown items. |
| `selectedItemBuilder` | `SelectedItemBuilder<T?>?` | Custom builder for the selected single item. |
| `selectedItemsBuilder` | `SelectedItemsBuilder<T>?` | Custom text formatting for multiple selected items. |
| `multiSelectDisplayBuilder` | `MultiSelectDisplayBuilder<T>?` | Custom UI generic display below the search field (e.g. chips). |
| `showSelectedItemsInField` | `bool` | Determines whether the main search text field renders strings derived from selected items. |
| `onSearch` | `Future<List<T>> Function(String)` | Callback for API-based search functionality. |
| `canShowButton` | `bool` | Toggles the visibility of the add button. |
| `textAlign` | `TextAlign` | Aligns the text in the search field. |
| `keyboardType` | `TextInputType?` | Sets the input type for the `TextFormField`. |
| `maxLine` | `int?` | Limits the maximum number of text lines. |
| `maxLength` | `int?` | Limits the maximum number of characters. |
| `inputFormatters` | `List<TextInputFormatter>?` | Applies input formatting rules to the `TextFormField`. |
| `validator` | `String? Function(String?)` | Validates the dropdown value. |
| `enableInteractiveSelection` | `bool?` | Enables or disables text selection in TextFormField |

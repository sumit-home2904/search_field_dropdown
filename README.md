# search_field_dropdown 🛠️

A highly customizable dropdown widget for Flutter with powerful features like search, API integration, 
custom UI support, and validation.

---

## Features

- Display static items or fetch them dynamically via APIs.
- Fully customizable dropdown appearance using BoxDecoration and custom item builders.
- Support for readonly and searchable dropdowns, along with additional customization options.
- Easy integration with TextFormField for validation and decoration.
- Advanced cursor styling for an enhanced user interface.
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

A GlobalKey<FormFiledDropDownState> is used to uniquely identify and manage the state of a FormFiledDropDown 
widget, allowing you to interact with its internal state (e.g., selecting an item or retrieving the selected value) 
from outside the widget.

**Purpose:**
    The GlobalKey<FormFiledDropDownState> allows you to access the state of the FormFiledDropDown widget,
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
            textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400
            ),
            menuDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Colors.blueAccent
                )
            ),
            filedDecoration: const InputDecoration(),
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
            textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400
            ),
            filedDecoration: InputDecoration(),
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

## Properties

| Property              | Type                         | Description                                           |
|-----------------------|------------------------------|-------------------------------------------------------|
| `key`                 | `GlobalKey<SearchFieldDropdownState>()`| Use for maintain state.                    |
| `item`                | `List<T>?`                  | List of dropdown items to display.                    |
| `filedReadOnly`       | `bool`                      | Makes `TextFormField` readonly.                       |
| `readOnly`            | `bool`                      | Makes dropdown readonly.                              |
| `initialItem`         | `T?`                        | Initial value for the dropdown.                       |
| `isApiLoading`        | `bool`                      | Indicates if the API is loading.                      |
| `dropdownOffset`      | `bool`                      | Change drop-down opening offset                       |
| `showCursor`          | `bool?`                     | Toggles the cursor visibility.                        |
| `cursorColor`         | `Color?`                    | Changes the cursor color.                             |
| `cursorHeight`        | `double?`                   | Sets the cursor height.                               |
| `cursorWidth`         | `double?`                   | Sets the cursor width.                                |
| `errorWidgetHeight`   | `double?`                   | Sets the error widget height.                         |
| `cursorRadius`        | `Radius?`                   | Sets the cursor border radius.                        |
| `cursorErrorColor`    | `Color?`                    | Sets the cursor error color.                          |
| `textStyle`           | `TextStyle`                 | Styles the search or selected text.                   |
| `loaderWidget`        | `Widget?`                   | Custom widget to show during API loading.             |
| `focusNode`           | `FocusNode?`                | Manages focus for searchable dropdowns.               |
| `errorMessage`        | `Text?`                     | Custom error message when no items are found.         |
| `overlayHeight`       | `double?`                   | Height of the dropdown overlay.                       |
| `addButton`           | `Widget?`                   | Adds a custom button for additional functionality.    |
| `onChanged`           | `Function(T? value)`        | Callback triggered when an item is selected.          |
| `menuDecoration`      | `BoxDecoration?`            | Custom decoration for the dropdown menu.              |
| `filedDecoration`     | `InputDecoration`           | Decoration for the `TextFormField`.                   |
| `onTap`               | `Future<List<T>> Function()`| Loads items dynamically for the dropdown.             |
| `autovalidateMode`    | `AutovalidateMode?`         | Enables validation listener when items change.        |
| `controller`          | `OverlayPortalController`   | Controls dropdown visibility programmatically.        |
| `listItemBuilder`     | `ListItemBuilder<T>`        | Custom builder for dropdown items.                    |
| `selectedItemBuilder` | `SelectedItemBuilder<T?>?`  | Custom builder for the selected item.                 |
| `onSearch`            | `Future<List<T>> Function(String)` | Callback for API-based search functionality.   |
| `listPadding`         | `EdgeInsets?`              | Sets padding for the list view.                       |
| `menuMargin`          | `EdgeInsets?`              | Sets margin for the dropdown item container.          |
| `canShowButton`       | `bool`                      | Toggles the visibility of the add button.             |
| `textAlign`           | `TextAlign`                 | Aligns the text in the search field.                  |
| `keyboardType`        | `TextInputType?`            | Sets the input type for the `TextFormField`.          |
| `maxLine`             | `int?`                      | Limits the maximum number of text lines.              |
| `maxLength`           | `int?`                      | Limits the maximum number of characters.              |
| `inputFormatters`     | `List<TextInputFormatter>?` | Applies input formatting rules to the `TextFormField`.|
| `validator`           | `String? Function(String?)` | Validates the dropdown value.                         |

import 'package:flutter/material.dart';

/// Callback typedef for building each row widget inside the overlay menu list.
///
/// Parameters:
/// - [context]: BuildContext from the row builder.
/// - [item]: The generic item of type [T] to render.
/// - [isSelected]: Boolean indicating whether the row is currently focused via keyboard or hovered by mouse.
typedef ListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
);

/// Callback typedef for converting a single selected item into a [Text] widget inside the search field.
typedef SelectedItemBuilder<T> = Text Function(
  BuildContext context,
  T item,
);

/// Callback typedef for formatting multiple selected items into a single display string for the search field.
typedef SelectedItemsBuilder<T> = String Function(
  BuildContext context,
  List<T> items,
);

/// Callback typedef for building a custom widget area below the search field displaying multi-select tags/chips.
///
/// Parameters:
/// - [context]: BuildContext for tag rendering.
/// - [items]: Currently selected items list.
/// - [onRemove]: Function callback to invoke when user removes a specific selected item tag.
typedef MultiSelectDisplayBuilder<T> = Widget Function(
  BuildContext context,
  List<T> items,
  Function(T) onRemove,
);

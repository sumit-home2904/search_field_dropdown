import 'package:flutter/material.dart';

/// Builds each row inside the overlay list.
///
/// The third argument represents the currently active row used for keyboard
/// navigation / hover styling. In multi-select mode, the actual checked state
/// is exposed through `multiSelectCheckBuilder`.
typedef ListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
);

typedef SelectedItemBuilder<T> = Text Function(BuildContext context, T item);

typedef SelectedItemsBuilder<T> = String Function(
  BuildContext context,
  List<T> items,
);

typedef MultiSelectDisplayBuilder<T> = Widget Function(
  BuildContext context,
  List<T> items,
  Function(T) onRemove,
);

/// Builds the trailing selection indicator for a multi-select row.
///
/// The builder receives only the current selected state. Selection changes are
/// still driven by the row tap handled inside `SearchFieldDropdown`, so this
/// builder is best used for presentation unless you wire custom tap behavior
/// around the whole row yourself.
typedef MultiSelectCheckBuilder = Widget Function(
  BuildContext context,
  bool selected,
);

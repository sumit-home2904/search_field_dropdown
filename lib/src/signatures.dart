import 'package:flutter/material.dart';

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

typedef MultiSelectCheckBuilder = Widget Function(
  BuildContext context,
  bool selected,
);

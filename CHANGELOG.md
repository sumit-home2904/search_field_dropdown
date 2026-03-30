# 1.2.3
- Fixed overlay width so an open dropdown now follows text field width changes during screen or layout resize.
- Fixed dropdown overlay dismissal on parent scroll to avoid detached floating menus in scrollable screens.
- Fixed `overlayHeight` calculation so user-provided height values are respected while still shrinking to fit when item data is short.

# 1.2.2
bug fixed

# 1.2.1
bug fixed

# 1.2.0
- Added comprehensive Multi-Select dropdown support (`isMultiSelect`).
- Introduced native inner checkbox rendering alongside `multiSelectCheckBuilder`.
- Supported custom external chip rendering via `multiSelectDisplayBuilder` and `selectedItemsBuilder`.
- Refactored loose decoration parameters (`textStyle`, `menuDecoration`, `fieldDecoration`, etc.) into a unified `SearchFieldDropdownDecoration` configuration model.
- Added `focusedItemDecoration`, `unfocusedItemDecoration`, and `itemPadding` for full-width row selections natively extending beneath checkboxes.

# 1.1.1
bug fixed

# 1.1.0
bug fixed

# 1.0.5
mobile version drop-down issue fixed and other bug fixed

# 1.0.4+1
empty list enter press issue fixed and onChange focus issue fixed

# 1.0.4
ui component added or shortcut issue fixed  

# 1.0.3
Shortcut added for item selection on Mac, Windows, and web; mouse hover feature implemented.

# 1.0.2
focusNode issue fixed

# 1.0.1
bug fixed

# 1.0.0
This drop-down allows users to search for any item from the API or local list data.

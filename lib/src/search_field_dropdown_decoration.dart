import 'package:flutter/material.dart';

/// Styling and visual decoration configuration for [SearchFieldDropdown].
///
/// Encapsulates styling for the text input field, dropdown menu container,
/// list item rows, elevation, cursor, and overlay layout behavior.
class SearchFieldDropdownDecoration {
  // ===========================================================================
  // TEXT FIELD STYLING PROPERTIES
  // ===========================================================================

  /// Custom text style for text typed inside the search field or displayed values.
  final TextStyle? textStyle;

  /// Custom decoration for the internal [TextFormField] (border, hintText, prefix/suffix icons).
  final InputDecoration? fieldDecoration;

  /// Text alignment inside the search field.
  final TextAlign? textAlign;

  /// Keyboard input type for the search input field.
  final TextInputType? keyboardType;

  /// Controls cursor visibility inside the search field.
  final bool? showCursor;

  /// Color of the blinking insertion cursor.
  final Color? cursorColor;

  /// Height of the insertion cursor.
  final double? cursorHeight;

  /// Width of the insertion cursor.
  final double? cursorWidth;

  /// Border radius of the insertion cursor corners.
  final Radius? cursorRadius;

  /// Color of the insertion cursor when the form field displays an error.
  final Color? cursorErrorColor;

  // ===========================================================================
  // OVERLAY MENU & CONTAINER STYLING PROPERTIES
  // ===========================================================================

  /// Custom container decoration for the open overlay menu card (background, border, shadow).
  final BoxDecoration? menuDecoration;

  /// Padding applied around the list view inside the overlay menu.
  final EdgeInsetsGeometry? listPadding;

  /// Card elevation / shadow depth for the dropdown overlay container.
  final double? elevation;

  /// Max height cap for the dropdown overlay menu.
  final double? overlayHeight;

  /// Positional offset (dx, dy) applied to the overlay menu relative to the target field.
  final Offset? dropdownOffset;

  // ===========================================================================
  // LIST ITEM ROW STYLING PROPERTIES
  // ===========================================================================

  /// Visual decoration applied to an item row when focused via keyboard arrow keys or hovered.
  final BoxDecoration? focusedItemDecoration;

  /// Visual decoration applied to an item row when unfocused.
  final BoxDecoration? unfocusedItemDecoration;

  /// Padding applied inside each individual item row container.
  final EdgeInsetsGeometry? itemPadding;

  // ===========================================================================
  // BEHAVIORAL & SCROLL CONTROL PROPERTIES
  // ===========================================================================

  /// Enables rendering of the optional [SearchFieldDropdown.addButton] above the list items.
  final bool? canShowButton;

  /// Controls whether selected multi-select items are rendered inside the search field as text.
  final bool? showSelectedItemsInField;

  /// Disables both text input and dropdown opening.
  final bool? readOnly;

  /// Disables text typing while still allowing the dropdown menu to open on tap.
  final bool? fieldReadOnly;

  /// Explicit parent scroll controller for deterministic scroll-aware auto-dismiss.
  final ScrollController? parentScrollController;

  /// Automatically closes the dropdown menu when surrounding parent scrollable starts scrolling.
  final bool? closeDropdownOnParentScroll;

  /// Custom empty/error message text widget displayed when item list is empty.
  final Text? errorMessage;

  /// Height of the empty error message container.
  final double? errorWidgetHeight;

  const SearchFieldDropdownDecoration({
    this.textStyle,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.cursorRadius,
    this.cursorErrorColor,
    this.menuDecoration,
    this.fieldDecoration,
    this.listPadding,
    this.elevation,
    this.focusedItemDecoration,
    this.unfocusedItemDecoration,
    this.itemPadding,
    this.canShowButton,
    this.dropdownOffset,
    this.overlayHeight,
    this.textAlign,
    this.keyboardType,
    this.showCursor,
    this.showSelectedItemsInField,
    this.readOnly,
    this.fieldReadOnly,
    this.parentScrollController,
    this.closeDropdownOnParentScroll,
    this.errorMessage,
    this.errorWidgetHeight,
  });

  /// Creates a copy of this decoration with the given fields replaced with new values.
  SearchFieldDropdownDecoration copyWith({
    TextStyle? textStyle,
    Color? cursorColor,
    double? cursorHeight,
    double? cursorWidth,
    Radius? cursorRadius,
    Color? cursorErrorColor,
    BoxDecoration? menuDecoration,
    InputDecoration? fieldDecoration,
    EdgeInsetsGeometry? listPadding,
    double? elevation,
    double? errorWidgetHeight,
    BoxDecoration? focusedItemDecoration,
    BoxDecoration? unfocusedItemDecoration,
    EdgeInsetsGeometry? itemPadding,
    bool? canShowButton,
    Offset? dropdownOffset,
    double? overlayHeight,
    TextAlign? textAlign,
    TextInputType? keyboardType,
    bool? showCursor,
    bool? showSelectedItemsInField,
    bool? readOnly,
    bool? fieldReadOnly,
    ScrollController? parentScrollController,
    bool? closeDropdownOnParentScroll,
    Text? errorMessage,
  }) {
    return SearchFieldDropdownDecoration(
      textStyle: textStyle ?? this.textStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      errorWidgetHeight: errorWidgetHeight ?? this.errorWidgetHeight,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      menuDecoration: menuDecoration ?? this.menuDecoration,
      fieldDecoration: fieldDecoration ?? this.fieldDecoration,
      listPadding: listPadding ?? this.listPadding,
      elevation: elevation ?? this.elevation,
      focusedItemDecoration:
          focusedItemDecoration ?? this.focusedItemDecoration,
      unfocusedItemDecoration:
          unfocusedItemDecoration ?? this.unfocusedItemDecoration,
      itemPadding: itemPadding ?? this.itemPadding,
      canShowButton: canShowButton ?? this.canShowButton,
      dropdownOffset: dropdownOffset ?? this.dropdownOffset,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      textAlign: textAlign ?? this.textAlign,
      keyboardType: keyboardType ?? this.keyboardType,
      showCursor: showCursor ?? this.showCursor,
      showSelectedItemsInField:
          showSelectedItemsInField ?? this.showSelectedItemsInField,
      readOnly: readOnly ?? this.readOnly,
      fieldReadOnly: fieldReadOnly ?? this.fieldReadOnly,
      parentScrollController:
          parentScrollController ?? this.parentScrollController,
      closeDropdownOnParentScroll:
          closeDropdownOnParentScroll ?? this.closeDropdownOnParentScroll,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

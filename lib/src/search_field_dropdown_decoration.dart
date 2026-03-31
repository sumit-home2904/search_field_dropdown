import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/signatures.dart';

class SearchFieldDropdownDecoration {
  /// Use this to style your search or selected text.
  final TextStyle? textStyle;

  /// Call when you need to change cursor color.
  final Color? cursorColor;

  /// Call when you need to change cursor Height.
  final double? cursorHeight;

  /// Call when you need to change cursor Width.
  final double? cursorWidth;

  /// Call when you need to change cursor Radius.
  final Radius? cursorRadius;

  /// Call when you need to change cursor Error Color.
  final Color? cursorErrorColor;

  /// Give your drop-down a custom decoration style.
  final BoxDecoration? menuDecoration;

  /// Creates a [TextFormField] with an [InputDecoration].
  final InputDecoration? fieldDecoration;

  /// Call for [listPadding] to provide padding for the list view.
  final EdgeInsetsGeometry? listPadding;

  final double? elevation;

  /// Optional custom trailing widget for each multi-select row.
  ///
  /// This is a visual builder only; the dropdown still toggles selection from
  /// the row tap so teams have a single selection path to debug.
  final MultiSelectCheckBuilder? multiSelectCheckBuilder;
  final IconData? multiSelectCheckedIcon;
  final IconData? multiSelectUncheckedIcon;
  final Color? multiSelectCheckedIconColor;
  final Color? multiSelectUncheckedIconColor;

  /// Supply a decoration (like a background color or border) when the item is focused/hovered.
  /// This expands across the entire row including native checkboxes.
  final BoxDecoration? focusedItemDecoration;

  /// Supply a decoration when the item is not focused.
  final BoxDecoration? unfocusedItemDecoration;

  /// Set the overall unified row padding encapsulating the list item and checkbox natively.
  final EdgeInsetsGeometry? itemPadding;

  /// Enables rendering of the optional [SearchFieldDropdown.addButton]
  /// section above the list inside the overlay.
  final bool? canShowButton;
  final Offset? dropdownOffset;

  /// Turns on multi-select mode for the entire dropdown flow.
  ///
  /// This flag affects selection bookkeeping in `SearchFieldDropdownState`
  /// and row rendering inside `OverlayBuilder`, so keep it in decoration as
  /// the single source of truth for multi-select visuals and behavior.
  final bool? isMultiSelect;
  final double? overlayHeight;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final bool? showCursor;
  final bool? showSelectedItemsInField;

  final bool? readOnly;
  final bool? fieldReadOnly;

  /// Supply the surrounding scroll controller when the dropdown is hosted
  /// inside a parent ListView/SingleChildScrollView and you want scroll-aware
  /// auto-dismiss behaviour to be deterministic.
  final ScrollController? parentScrollController;

  /// Closes the open dropdown when the surrounding parent scrollable starts
  /// scrolling, which avoids detached overlay menus in long forms/lists.
  final bool? closeDropdownOnParentScroll;
  final Text? errorMessage;

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
    this.multiSelectCheckBuilder,
    this.multiSelectCheckedIcon,
    this.multiSelectUncheckedIcon,
    this.multiSelectCheckedIconColor,
    this.multiSelectUncheckedIconColor,
    this.focusedItemDecoration,
    this.unfocusedItemDecoration,
    this.itemPadding,
    this.canShowButton,
    this.dropdownOffset,
    this.isMultiSelect,
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
  });

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
    MultiSelectCheckBuilder? multiSelectCheckBuilder,
    IconData? multiSelectCheckedIcon,
    IconData? multiSelectUncheckedIcon,
    Color? multiSelectCheckedIconColor,
    Color? multiSelectUncheckedIconColor,
    BoxDecoration? focusedItemDecoration,
    BoxDecoration? unfocusedItemDecoration,
    EdgeInsetsGeometry? itemPadding,
    bool? canShowButton,
    Offset? dropdownOffset,
    bool? isMultiSelect,
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
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      menuDecoration: menuDecoration ?? this.menuDecoration,
      fieldDecoration: fieldDecoration ?? this.fieldDecoration,
      listPadding: listPadding ?? this.listPadding,
      elevation: elevation ?? this.elevation,
      multiSelectCheckBuilder:
          multiSelectCheckBuilder ?? this.multiSelectCheckBuilder,
      multiSelectCheckedIcon:
          multiSelectCheckedIcon ?? this.multiSelectCheckedIcon,
      multiSelectUncheckedIcon:
          multiSelectUncheckedIcon ?? this.multiSelectUncheckedIcon,
      multiSelectCheckedIconColor:
          multiSelectCheckedIconColor ?? this.multiSelectCheckedIconColor,
      multiSelectUncheckedIconColor:
          multiSelectUncheckedIconColor ?? this.multiSelectUncheckedIconColor,
      focusedItemDecoration:
          focusedItemDecoration ?? this.focusedItemDecoration,
      unfocusedItemDecoration:
          unfocusedItemDecoration ?? this.unfocusedItemDecoration,
      itemPadding: itemPadding ?? this.itemPadding,
      canShowButton: canShowButton ?? this.canShowButton,
      dropdownOffset: dropdownOffset ?? this.dropdownOffset,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
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

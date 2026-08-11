library search_field_dropdown;

export 'src/signatures.dart';
export 'src/search_field_dropdown_decoration.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:search_field_dropdown/src/overlay_builder.dart';
import 'package:search_field_dropdown/src/search_field_dropdown_decoration.dart';
import 'package:search_field_dropdown/src/signatures.dart';

/// A highly customizable, performant search field dropdown for Flutter.
///
/// Supports single-selection ([SearchFieldDropdown.singleSelection]) and
/// multi-selection ([SearchFieldDropdown.multiSelection]) modes with
/// asynchronous search, keyboard navigation, overlay position calculation,
/// and granular rebuild optimizations.
class SearchFieldDropdown<T> extends StatefulWidget {
  // ===========================================================================
  // DATA & CALLBACK PROPERTIES
  // ===========================================================================

  /// List of generic items displayed inside the dropdown overlay menu.
  final List<T> item;

  /// Callback fired when an item is tapped or selected.
  ///
  /// In single-selection mode, receives the newly selected item (or `null`).
  /// In multi-selection mode, receives the specific item that was toggled.
  final Function(T? value)? onChanged;

  /// Callback fired when the selection set changes in multi-selection mode.
  ///
  /// Receives the full list of currently selected items [List<T>].
  final Function(List<T>)? onItemsChanged;

  /// Initial item selected in single-selection mode.
  final T? initialItem;

  /// Initial list of items selected in multi-selection mode.
  final List<T>? initialItems;

  /// Async callback executed when user types in the search field to filter items.
  ///
  /// Use this for backend/remote API search. When `null`, local filtering is used.
  final Future<List<T>> Function(String value)? onSearch;

  /// Async callback executed when the dropdown field is tapped.
  ///
  /// Use this to dynamically load items from a remote API before opening menu.
  final Future<List<T>> Function()? onTap;

  // ===========================================================================
  // CUSTOM BUILDER PROPERTIES
  // ===========================================================================

  /// Custom widget builder for rendering individual row items inside the overlay list.
  ///
  /// The third parameter `isSelected` indicates whether the row is currently
  /// focused/highlighted via keyboard arrow keys or mouse hover.
  final ListItemBuilder<T> listItemBuilder;

  /// Custom builder for converting a selected item to a display string inside the text field.
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// Custom builder for formatting multiple selected items into a text field string.
  final SelectedItemsBuilder<T>? selectedItemsBuilder;

  /// Custom widget builder for rendering selected item tags/chips below the search field.
  final MultiSelectDisplayBuilder<T>? multiSelectDisplayBuilder;

  /// Custom widget shown while async operations ([onTap] or [onSearch]) are loading.
  final Widget? loaderWidget;

  /// Custom widget rendered at the top of the overlay list (e.g., "Add New Item" button).
  final Widget? addButton;

  // ===========================================================================
  // CONFIGURATION & DECORATION PROPERTIES
  // ===========================================================================

  /// Visual styling configuration for the search field and dropdown overlay menu.
  final SearchFieldDropdownDecoration? decoration;

  /// External focus node for controlling keyboard focus on the text field.
  final FocusNode? focusNode;

  /// Controls whether text selection options (copy/paste toolbar) are enabled.
  final bool? enableInteractiveSelection;

  /// External controller for manually controlling overlay visibility state.
  final OverlayPortalController? controller;

  /// Indicates whether an external API call is currently loading data.
  final bool isApiLoading;

  /// Validation mode for form field validation.
  final AutovalidateMode? autovalidateMode;

  /// Input formatters applied to the search input text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Form field validation callback.
  final String? Function(String? value)? validator;

  // ===========================================================================
  // PRIVATE MODE FLAG & CONSTRUCTORS
  // ===========================================================================

  /// Internal boolean flag distinguishing single-selection (`false`) from multi-selection (`true`).
  final bool _isMultiSelect;

  /// Private constructor enforcing constructor-based mode selection.
  ///
  /// Developers must use either [SearchFieldDropdown.singleSelection] or
  /// [SearchFieldDropdown.multiSelection].
  const SearchFieldDropdown._({
    super.key,
    required this.item,
    required this.listItemBuilder,
    required bool isMultiSelect,
    this.onChanged,
    this.onItemsChanged,
    this.focusNode,
    this.enableInteractiveSelection,
    this.initialItem,
    this.initialItems,
    this.loaderWidget,
    this.addButton,
    this.decoration,
    this.isApiLoading = false,
    this.selectedItemsBuilder,
    this.multiSelectDisplayBuilder,
    this.onTap,
    this.autovalidateMode,
    this.controller,
    this.selectedItemBuilder,
    this.onSearch,
    this.inputFormatters,
    this.validator,
  }) : _isMultiSelect = isMultiSelect;

  /// Creates a single-selection search field dropdown.
  ///
  /// Exposes single-selection properties ([initialItem], [onChanged]) while
  /// omitting multi-select specific parameters for type safety and clarity.
  factory SearchFieldDropdown.singleSelection({
    Key? key,
    required List<T> item,
    required ListItemBuilder<T> listItemBuilder,
    ValueChanged<T?>? onChanged,
    FocusNode? focusNode,
    bool? enableInteractiveSelection,
    T? initialItem,
    Widget? loaderWidget,
    Widget? addButton,
    SearchFieldDropdownDecoration? decoration,
    bool isApiLoading = false,
    Future<List<T>> Function()? onTap,
    AutovalidateMode? autovalidateMode,
    OverlayPortalController? controller,
    SelectedItemBuilder<T>? selectedItemBuilder,
    Future<List<T>> Function(String value)? onSearch,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String? value)? validator,
  }) {
    return SearchFieldDropdown._(
      key: key,
      item: item,
      listItemBuilder: listItemBuilder,
      isMultiSelect: false,
      onChanged: onChanged,
      focusNode: focusNode,
      enableInteractiveSelection: enableInteractiveSelection,
      initialItem: initialItem,
      loaderWidget: loaderWidget,
      addButton: addButton,
      decoration: decoration,
      isApiLoading: isApiLoading,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      controller: controller,
      selectedItemBuilder: selectedItemBuilder,
      onSearch: onSearch,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  /// Creates a multi-selection search field dropdown.
  ///
  /// Exposes multi-selection properties ([initialItems], [onItemsChanged],
  /// [multiSelectDisplayBuilder]) while setting internal multi-select mode to `true`.
  factory SearchFieldDropdown.multiSelection({
    Key? key,
    required List<T> item,
    required ListItemBuilder<T> listItemBuilder,
    ValueChanged<T?>? onChanged,
    ValueChanged<List<T>>? onItemsChanged,
    FocusNode? focusNode,
    bool? enableInteractiveSelection,
    List<T>? initialItems,
    Widget? loaderWidget,
    Widget? addButton,
    SearchFieldDropdownDecoration? decoration,
    bool isApiLoading = false,
    SelectedItemsBuilder<T>? selectedItemsBuilder,
    MultiSelectDisplayBuilder<T>? multiSelectDisplayBuilder,
    Future<List<T>> Function()? onTap,
    AutovalidateMode? autovalidateMode,
    OverlayPortalController? controller,
    SelectedItemBuilder<T>? selectedItemBuilder,
    Future<List<T>> Function(String value)? onSearch,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String? value)? validator,
  }) {
    return SearchFieldDropdown._(
      key: key,
      item: item,
      listItemBuilder: listItemBuilder,
      isMultiSelect: true,
      onChanged: onChanged,
      onItemsChanged: onItemsChanged,
      focusNode: focusNode,
      enableInteractiveSelection: enableInteractiveSelection,
      initialItems: initialItems,
      loaderWidget: loaderWidget,
      addButton: addButton,
      decoration: decoration,
      isApiLoading: isApiLoading,
      selectedItemsBuilder: selectedItemsBuilder,
      multiSelectDisplayBuilder: multiSelectDisplayBuilder,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      controller: controller,
      selectedItemBuilder: selectedItemBuilder,
      onSearch: onSearch,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  @override
  State<SearchFieldDropdown<T>> createState() => SearchFieldDropdownState<T>();
}

class SearchFieldDropdownState<T> extends State<SearchFieldDropdown<T>> {
  // ===========================================================================
  // STATE READERS & GETTERS
  // ===========================================================================

  bool get _readOnly => widget.decoration?.readOnly ?? false;
  bool get _fieldReadOnly => widget.decoration?.fieldReadOnly ?? false;
  bool get _showSelectedItemsInField =>
      widget.decoration?.showSelectedItemsInField ?? true;
  bool get _isMultiSelect => widget._isMultiSelect;
  bool get _closeDropdownOnParentScroll =>
      widget.decoration?.closeDropdownOnParentScroll ?? true;

  // ===========================================================================
  // VALUE NOTIFIERS FOR REACTIVE STATE MANAGEMENT WITHOUT FULL REBUILDS
  // ===========================================================================

  /// Holds current single selection value.
  final ValueNotifier<T?> selectedItemNotifier = ValueNotifier<T?>(null);

  /// Holds current list of items available for display/filtering.
  final ValueNotifier<List<T>> itemsNotifier = ValueNotifier<List<T>>([]);

  /// Holds current list of selected items in multi-selection mode.
  final ValueNotifier<List<T>> selectedItemsNotifier =
      ValueNotifier<List<T>>([]);

  /// Holds index of currently focused item for keyboard UP/DOWN navigation.
  final ValueNotifier<int> focusedIndexNotifier = ValueNotifier<int>(-1);

  /// Holds flag disabling text input when user secondary-taps field.
  final ValueNotifier<bool> isTypingDisabledNotifier =
      ValueNotifier<bool>(false);

  /// Holds flag tracking whether keyboard navigation is actively being used.
  final ValueNotifier<bool> isKeyboardNavigationNotifier =
      ValueNotifier<bool>(false);

  /// Holds API loading state during async search or tap fetching.
  final ValueNotifier<bool> isApiLoadingNotifier = ValueNotifier<bool>(false);

  // ===========================================================================
  // CONTROLLERS & KEYS
  // ===========================================================================

  final OverlayPortalController _internalOverlayController =
      OverlayPortalController();

  OverlayPortalController get _overlayController =>
      widget.controller ?? _internalOverlayController;

  final layerLink = LayerLink();
  final GlobalKey textFieldKey = GlobalKey();
  final GlobalKey itemListKey = GlobalKey();
  final GlobalKey addButtonKey = GlobalKey();
  final GlobalKey contentKey = GlobalKey();

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  /// Ancestor scroll position listener for auto-dismissing menu on parent scroll.
  ScrollPosition? _ancestorScrollPosition;

  /// Debounce timer for API/local search to prevent excessive rapid queries.
  final SearchTimerMethod _searchDebounce =
      SearchTimerMethod(milliseconds: 350);

  // ===========================================================================
  // LIFECYCLE HOOKS
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    itemsNotifier.value = [];

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_focusNodeListener);
    }

    // Initialize selection state after initial post-frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachAncestorScrollListener();
      itemsNotifier.value = widget.item;
      if (_isMultiSelect) {
        selectedItemsNotifier.value = List.from(widget.initialItems ?? []);
      } else {
        selectedItemNotifier.value = widget.initialItem;
      }
      _syncFieldTextFromSelection();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachAncestorScrollListener();
  }

  @override
  void didUpdateWidget(covariant SearchFieldDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Deep list equality guard: prevent re-pushing items if list contents are identical
    if (!listEquals(widget.item, oldWidget.item)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        itemsNotifier.value = widget.item;
      });
    }

    if (widget.isApiLoading != oldWidget.isApiLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        isApiLoadingNotifier.value = widget.isApiLoading;
      });
    }

    if (_isMultiSelect) {
      if (!listEquals(widget.initialItems, oldWidget.initialItems)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItems == null || widget.initialItems!.isEmpty) {
            selectedItemsNotifier.value = [];
          } else {
            selectedItemsNotifier.value = List.from(widget.initialItems!);
          }
          _syncFieldTextFromSelection();
        });
      }
    } else {
      if (widget.initialItem != oldWidget.initialItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItem == null) {
            selectedItemNotifier.value = null;
          } else {
            selectedItemNotifier.value = widget.initialItem;
          }
          _syncFieldTextFromSelection();
        });
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_focusNodeListener);
    _ancestorScrollPosition?.removeListener(_handleAncestorScrollChange);
    _searchDebounce.cancel();
    textController.dispose();
    scrollController.dispose();
    selectedItemNotifier.dispose();
    itemsNotifier.dispose();
    selectedItemsNotifier.dispose();
    focusedIndexNotifier.dispose();
    isKeyboardNavigationNotifier.dispose();
    isApiLoadingNotifier.dispose();
    isTypingDisabledNotifier.dispose();
    super.dispose();
  }

  // ===========================================================================
  // PARENT SCROLL LISTENER MANAGEMENT
  // ===========================================================================

  /// Finds and resolves nearest ancestor scroll position (e.g. ListView, SingleChildScrollView).
  ScrollPosition? _resolveAncestorScrollPosition() {
    final explicitController = widget.decoration?.parentScrollController;
    if (explicitController != null && explicitController.hasClients) {
      return explicitController.position;
    }

    final primaryController = PrimaryScrollController.maybeOf(context);
    if (primaryController != null && primaryController.hasClients) {
      return primaryController.position;
    }

    return Scrollable.maybeOf(context)?.position;
  }

  /// Attaches scroll listener to parent scrollable to close open dropdown on scroll.
  void _attachAncestorScrollListener() {
    final ScrollPosition? newPosition = _resolveAncestorScrollPosition();
    if (identical(_ancestorScrollPosition, newPosition)) return;

    _ancestorScrollPosition?.removeListener(_handleAncestorScrollChange);
    _ancestorScrollPosition = newPosition;
    _ancestorScrollPosition?.addListener(_handleAncestorScrollChange);
  }

  /// Dismisses overlay when user scrolls a parent scrollable container.
  void _handleAncestorScrollChange() {
    final position = _ancestorScrollPosition;
    if (!_closeDropdownOnParentScroll ||
        position == null ||
        !_overlayController.isShowing) {
      return;
    }
    if (position.userScrollDirection != ScrollDirection.idle) {
      _dismissOverlay(resetText: true);
    }
  }

  // ===========================================================================
  // SELECTION & OVERLAY HELPER METHODS
  // ===========================================================================

  /// Removes an item from multi-select set when user taps delete chip/tag.
  void removeSelectedItem(T item) {
    if (selectedItemsNotifier.value.contains(item)) {
      final updatedList = List<T>.from(selectedItemsNotifier.value)
        ..remove(item);
      selectedItemsNotifier.value = updatedList;
      _syncFieldTextFromSelection();
      widget.onChanged?.call(item);
      widget.onItemsChanged?.call(updatedList);
    }
  }

  /// Syncs text field content to mirror current single/multi selection.
  ///
  /// String equality check prevents unnecessary textController text assignments.
  void _syncFieldTextFromSelection() {
    final String newText;
    if (_isMultiSelect) {
      if (!_showSelectedItemsInField || selectedItemsNotifier.value.isEmpty) {
        newText = "";
      } else {
        newText =
            selectedItemsConvertor(listData: selectedItemsNotifier.value) ?? "";
      }
    } else {
      if (selectedItemNotifier.value == null) {
        newText = "";
      } else {
        newText = selectedItemConvertor(listData: selectedItemNotifier.value) ??
            "${selectedItemNotifier.value}";
      }
    }

    if (textController.text != newText) {
      textController.text = newText;
    }
  }

  /// Updates focused item index for keyboard arrow key highlight.
  void changeFocusIndex(int index) {
    if (focusedIndexNotifier.value == index) return;
    focusedIndexNotifier.value = index;
  }

  /// Updates keyboard navigation active state flag.
  void changeKeyBool(bool newValue) {
    if (isKeyboardNavigationNotifier.value == newValue) return;
    isKeyboardNavigationNotifier.value = newValue;
  }

  void _restoreFieldValueAfterDismiss() {
    itemsNotifier.value = widget.item;
    _syncFieldTextFromSelection();
  }

  /// Hides the dropdown overlay portal.
  void _dismissOverlay({bool resetText = false}) {
    if (!_overlayController.isShowing) return;
    if (resetText) {
      _restoreFieldValueAfterDismiss();
    }
    _overlayController.hide();
  }

  /// Displays the dropdown overlay portal.
  void _showOverlay() {
    if (_overlayController.isShowing) return;
    _overlayController.show();
  }

  /// Handles focus node changes (fetching API data on focus if [onTap] provided).
  void _focusNodeListener() async {
    if (widget.focusNode!.hasFocus) {
      if (widget.onTap != null) {
        textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textController.text.length,
        );
        isApiLoadingNotifier.value = true;
        try {
          itemsNotifier.value = await widget.onTap!();
        } finally {
          if (mounted) {
            isApiLoadingNotifier.value = widget.isApiLoading;
          }
        }
      }
      if (mounted) {
        focusedIndexNotifier.value = _overlayController.isShowing ? 0 : -1;
      }
    }
  }

  /// Converts single selected item to string via custom builder or toString().
  String? selectedItemConvertor({T? listData}) {
    if (listData != null && widget.selectedItemBuilder != null) {
      return (widget.selectedItemBuilder!(context, listData as T)).data ?? "";
    }
    return null;
  }

  /// Converts multiple selected items to formatted string list.
  String? selectedItemsConvertor({List<T>? listData}) {
    if (listData != null && listData.isNotEmpty) {
      if (widget.selectedItemsBuilder != null) {
        return widget.selectedItemsBuilder!(context, listData);
      }
      return listData.map((item) {
        if (widget.selectedItemBuilder != null) {
          return (widget.selectedItemBuilder!(context, item)).data ?? "";
        }
        return item.toString();
      }).join(', ');
    }
    return null;
  }

  // ===========================================================================
  // KEYBOARD AUTO-SCROLL LOGIC
  // ===========================================================================

  /// Smoothly scrolls list view to ensure focused index is visible during arrow key navigation.
  void scrollToFocusedItem() {
    RenderBox? renderBox =
        itemListKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? addButtonRender =
        addButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) return;

    final double itemHeight = renderBox.size.height;
    final double addButtonHeight =
        (addButtonRender != null && addButtonRender.attached)
            ? addButtonRender.size.height
            : 0;
    final double configuredOverlayHeight =
        widget.decoration?.overlayHeight ?? 150;
    final double usableOverlayHeight =
        (configuredOverlayHeight - addButtonHeight).clamp(
      itemHeight,
      double.infinity,
    );
    final int maxVisibleItems = (usableOverlayHeight / itemHeight).floor();
    final double firstVisibleIndex = scrollController.offset / itemHeight;
    final double lastVisibleIndex = firstVisibleIndex + (maxVisibleItems - 1);

    int fIndex = focusedIndexNotifier.value;
    if (fIndex > lastVisibleIndex) {
      if (fIndex == itemsNotifier.value.length - 1) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
          );
        }
      } else {
        scrollController.jumpTo(
          (fIndex - (maxVisibleItems - 1)) * itemHeight,
        );
      }
    } else if (fIndex < firstVisibleIndex) {
      if (fIndex >= lastVisibleIndex - (maxVisibleItems - 1)) {
        return;
      }
      scrollController.jumpTo(fIndex * itemHeight);
    }
  }

  // ===========================================================================
  // EVENT HANDLERS & SELECTION LOGIC
  // ===========================================================================

  /// Handles user tapping a dropdown item row.
  void onItemSelected(T tappedItem) {
    if (_isMultiSelect) {
      final currentList = List<T>.from(selectedItemsNotifier.value);
      if (currentList.contains(tappedItem)) {
        currentList.remove(tappedItem);
      } else {
        currentList.add(tappedItem);
      }
      selectedItemsNotifier.value = currentList;
      _syncFieldTextFromSelection();
      widget.onChanged?.call(tappedItem);
      widget.onItemsChanged?.call(currentList);
    } else {
      _dismissOverlay();
      selectedItemNotifier.value = tappedItem;
      _syncFieldTextFromSelection();
      widget.onChanged?.call(tappedItem);
      focusedIndexNotifier.value = -1;
      widget.focusNode?.unfocus();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    }
  }

  /// Triggers when user taps text field to open overlay.
  void textFiledOnTap() async {
    _attachAncestorScrollListener();
    focusedIndexNotifier.value = 0;
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textController.text.length,
    );

    if (!_readOnly) {
      _showOverlay();
      if (widget.onTap != null && widget.focusNode == null) {
        isApiLoadingNotifier.value = true;
        try {
          itemsNotifier.value = await widget.onTap!();
        } finally {
          if (mounted) {
            isApiLoadingNotifier.value = widget.isApiLoading;
          }
        }
      } else if (widget.onTap == null) {
        itemsNotifier.value = widget.item;
      }
    }
  }

  /// Triggers when user types inside search text field.
  void onChange(String value) async {
    dropDownOpen();

    RenderBox? renderBox =
        itemListKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null &&
        renderBox.attached &&
        scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    _searchDebounce.run(() {
      if (!mounted) return;
      onSearchCalled(value.isEmpty ? "" : value);
    });
  }

  /// Filters items locally or via [onSearch] async callback.
  void onSearchCalled(String value) async {
    if (widget.onSearch != null) {
      isApiLoadingNotifier.value = true;
      try {
        final result = await widget.onSearch!(value);
        if (mounted) {
          itemsNotifier.value = result;
        }
      } finally {
        if (mounted) {
          isApiLoadingNotifier.value = widget.isApiLoading;
        }
      }
    } else {
      itemsNotifier.value = widget.item.where((item) {
        return item
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase().trim());
      }).toList();
    }
  }

  /// Opens overlay portal if not already showing.
  void dropDownOpen() {
    _attachAncestorScrollListener();
    if (!_overlayController.isShowing) {
      focusedIndexNotifier.value = 0;
      _showOverlay();
    }
    if (textController.text.isEmpty) {
      itemsNotifier.value = widget.item;
    }
  }

  // ===========================================================================
  // WIDGET BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_overlayController.isShowing) {
          _dismissOverlay();
        }
      },
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
            isKeyboardNavigationNotifier.value = true;
            if (focusedIndexNotifier.value > 0) {
              focusedIndexNotifier.value--;
            } else {
              focusedIndexNotifier.value = itemsNotifier.value.length - 1;
            }
            scrollToFocusedItem();
          },
          LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
            dropDownOpen();
            isKeyboardNavigationNotifier.value = true;
            if (focusedIndexNotifier.value < itemsNotifier.value.length - 1) {
              focusedIndexNotifier.value++;
              scrollToFocusedItem();
            } else {
              focusedIndexNotifier.value = 0;
              RenderBox? renderBox =
                  itemListKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null &&
                  renderBox.attached &&
                  scrollController.hasClients) {
                scrollController.jumpTo(
                  focusedIndexNotifier.value * renderBox.size.height,
                );
              }
            }
          },
          LogicalKeySet(LogicalKeyboardKey.enter): () {
            if (focusedIndexNotifier.value >= 0 &&
                focusedIndexNotifier.value < itemsNotifier.value.length) {
              onItemSelected(itemsNotifier.value[focusedIndexNotifier.value]);
            }
          },
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OverlayPortal(
              key: ObjectKey(_overlayController),
              controller: _overlayController,
              overlayChildBuilder: (context) {
                return Stack(
                  children: [
                    // Translucent dismiss barrier — taps outside dismiss menu
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _dismissOverlay(resetText: true);
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                    OverlayBuilder(
                      key: contentKey,
                      fieldKey: textFieldKey,
                      itemsNotifier: itemsNotifier,
                      layerLink: layerLink,
                      selectedItemsNotifier: selectedItemsNotifier,
                      changeKeyBool: changeKeyBool,
                      scrollController: scrollController,
                      focusedIndexNotifier: focusedIndexNotifier,
                      isKeyboardNavigationNotifier:
                          isKeyboardNavigationNotifier,
                      itemListKey: itemListKey,
                      addButtonKey: addButtonKey,
                      dropdownOffset: widget.decoration?.dropdownOffset,
                      decoration: widget.decoration,
                      changeIndex: changeFocusIndex,
                      onItemSelected: onItemSelected,
                      addButton: widget.addButton,
                      controller: _overlayController,
                      textController: textController,
                      isMultiSelect: _isMultiSelect,
                      isApiLoadingNotifier: isApiLoadingNotifier,
                      loaderWidget: widget.loaderWidget,
                      listItemBuilder: widget.listItemBuilder,
                    ),
                  ],
                );
              },
              child: CompositedTransformTarget(
                link: layerLink,
                child: Listener(
                  onPointerDown: (PointerDownEvent event) {
                    final newValue = event.buttons == kSecondaryMouseButton;
                    if (isTypingDisabledNotifier.value != newValue) {
                      isTypingDisabledNotifier.value = newValue;
                    }
                  },
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isTypingDisabledNotifier,
                    builder: (context, isTypingDisabled, child) {
                      return TextFormField(
                        key: textFieldKey,
                        enableInteractiveSelection:
                            widget.enableInteractiveSelection ??
                                (!_fieldReadOnly),
                        style:
                            widget.decoration?.textStyle ?? const TextStyle(),
                        keyboardType: widget.decoration?.keyboardType,
                        inputFormatters: widget.inputFormatters,
                        textAlign:
                            widget.decoration?.textAlign ?? TextAlign.start,
                        readOnly: isTypingDisabled ? true : _fieldReadOnly,
                        focusNode: widget.focusNode,
                        controller: textController,
                        showCursor: widget.decoration?.showCursor,
                        cursorHeight: widget.decoration?.cursorHeight,
                        cursorWidth: widget.decoration?.cursorWidth ?? 2.0,
                        cursorRadius: widget.decoration?.cursorRadius,
                        decoration: widget.decoration?.fieldDecoration ??
                            const InputDecoration(),
                        cursorColor:
                            widget.decoration?.cursorColor ?? Colors.black,
                        cursorErrorColor:
                            widget.decoration?.cursorErrorColor ?? Colors.black,
                        autovalidateMode: widget.autovalidateMode,
                        validator: widget.validator,
                        onChanged: onChange,
                        onTap: textFiledOnTap,
                        onFieldSubmitted: (_) {
                          _dismissOverlay(resetText: true);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isMultiSelect && widget.multiSelectDisplayBuilder != null)
              ValueListenableBuilder<List<T>>(
                valueListenable: selectedItemsNotifier,
                builder: (context, selectedItems, child) {
                  return widget.multiSelectDisplayBuilder!(
                    context,
                    selectedItems,
                    removeSelectedItem,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

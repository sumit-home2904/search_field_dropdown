library search_field_dropdown;

export 'src/signatures.dart';
export 'src/search_field_dropdown_decoration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_field_dropdown/src/overlay_builder.dart';
import 'package:search_field_dropdown/src/search_field_dropdown_decoration.dart';
import 'package:search_field_dropdown/src/signatures.dart';

class SearchFieldDropdown<T> extends StatefulWidget {
  /// List of items to display in the dropdown.
  final List<T> item;

  final double? errorWidgetHeight;

  /// When you have text fields, users can usually long-press to select text,
  /// which brings up the toolbar with options like copy, paste, etc.
  final bool? enableInteractiveSelection;

  /// The automatically generated controller an initial value.
  final T? initialItem;

  /// Use if you are using an API with a loading state.
  final bool isApiLoading;

  /// Set all the styling properties for rendering inside the dropdown natively.
  final SearchFieldDropdownDecoration? decoration;

  /// Use this if you want to provide your custom widget when using the API.
  final Widget? loaderWidget;

  /// Call when we need to focus; your drop-down is searchable.
  final FocusNode? focusNode;

  /// Call when you need to add a button or any custom functionality widget.
  final Widget? addButton;

  /// Callback function when an item is selected.
  /// In multi-select mode, this is called with the item that was toggled.
  final Function(T? value)? onChanged;

  /// Callback when multiple items are selected.
  final Function(List<T>)? onItemsChanged;

  /// Initial multiple items selected.
  final List<T>? initialItems;

  /// Build your selected multiple values UI formatted string using this property.
  final SelectedItemsBuilder<T>? selectedItemsBuilder;

  /// Customize the display of selected items below the search field in multi-select mode.
  final MultiSelectDisplayBuilder<T>? multiSelectDisplayBuilder;

  // (multiSelectCheckBuilder moved to SearchFieldDropdownDecoration)

  // (menuDecoration and fieldDecoration moved to SearchFieldDropdownDecoration)

  /// Call when [SearchFieldDropdown] is using the API or to load your list items.
  final Future<List<T>> Function()? onTap;

  /// Enable the validation listener on item change.
  final AutovalidateMode? autovalidateMode;

  /// Use the [OverlayPortalController] to display or conceal your drop-down.
  final OverlayPortalController? controller;

  /// Build your drop-down listing custom UI using this property.
  final ListItemBuilder<T> listItemBuilder;

  /// Build your selected value UI using this property.
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// To search for items. Can be used for API search.
  final Future<List<T>> Function(String value)? onSearch;

  // (listPadding moved to SearchFieldDropdownDecoration)

  /// Input formatters for the internal text field.
  final List<TextInputFormatter>? inputFormatters;

  /// We can validate your drop-down using a [validator].
  final String? Function(String? value)? validator;

  const SearchFieldDropdown({
    super.key,
    this.onTap,
    this.onSearch,
    this.focusNode,
    this.addButton,
    this.validator,
    this.initialItem,
    this.loaderWidget,
    required this.item,
    this.inputFormatters,
    this.errorWidgetHeight,
    this.autovalidateMode,
    this.onChanged,
    this.onItemsChanged,
    this.initialItems,
    this.selectedItemsBuilder,
    this.multiSelectDisplayBuilder,
    this.controller,
    this.selectedItemBuilder,
    this.isApiLoading = false,
    required this.listItemBuilder,
    this.enableInteractiveSelection,
    this.decoration,
  });

  @override
  State<SearchFieldDropdown<T>> createState() => SearchFieldDropdownState<T>();
}

class SearchFieldDropdownState<T> extends State<SearchFieldDropdown<T>> {
  bool get _isMultiSelect => widget.decoration?.isMultiSelect ?? false;
  bool get _showSelectedItemsInField =>
      widget.decoration?.showSelectedItemsInField ?? true;
  bool get _readOnly => widget.decoration?.readOnly ?? false;
  bool get _fieldReadOnly => widget.decoration?.fieldReadOnly ?? false;
  bool get _closeDropdownOnParentScroll =>
      widget.decoration?.closeDropdownOnParentScroll ?? true;

  final ValueNotifier<T?> selectedItemNotifier = ValueNotifier<T?>(null);
  final ValueNotifier<List<T>> itemsNotifier = ValueNotifier<List<T>>([]);
  final ValueNotifier<List<T>> selectedItemsNotifier =
      ValueNotifier<List<T>>([]);

  final ValueNotifier<int> focusedIndexNotifier = ValueNotifier<int>(-1);

  void removeSelectedItem(T item) {
    if (selectedItemsNotifier.value.contains(item)) {
      final updatedList = List<T>.from(selectedItemsNotifier.value)
        ..remove(item);
      selectedItemsNotifier.value = updatedList;
      if (_showSelectedItemsInField) {
        textController.text =
            selectedItemsConvertor(listData: updatedList) ?? "";
        if (updatedList.isEmpty) textController.clear();
      } else {
        textController.clear();
      }
      widget.onChanged?.call(item);
      widget.onItemsChanged?.call(updatedList);
    }
  }

  final ValueNotifier<bool> isTypingDisabledNotifier =
      ValueNotifier<bool>(false);
  final OverlayPortalController _internalOverlayController =
      OverlayPortalController();
  final ValueNotifier<bool> isKeyboardNavigationNotifier =
      ValueNotifier<bool>(false);

  OverlayPortalController get _overlayController =>
      widget.controller ?? _internalOverlayController;

  final layerLink = LayerLink();
  final GlobalKey textFieldKey = GlobalKey();
  final GlobalKey itemListKey = GlobalKey();
  final GlobalKey addButtonKey = GlobalKey();

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  ScrollPosition? _ancestorScrollPosition;

  /// Debounce timer for onSearch to avoid excessive API calls on rapid typing.
  final SearchTimerMethod _searchDebounce =
      SearchTimerMethod(milliseconds: 350);

  /// Guard: only call setState when focusedIndex actually changes.
  void changeFocusIndex(int index) {
    if (focusedIndexNotifier.value == index) return;
    focusedIndexNotifier.value = index;
  }

  /// Guard: only call setState when keyboard-navigation flag actually changes.
  void changeKeyBool(bool newValue) {
    if (isKeyboardNavigationNotifier.value == newValue) return;
    isKeyboardNavigationNotifier.value = newValue;
  }

  @override
  void initState() {
    super.initState();
    itemsNotifier.value = [];

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_focusNodeListener);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachAncestorScrollListener();
      itemsNotifier.value = widget.item;
      if (_isMultiSelect) {
        selectedItemsNotifier.value = List.from(widget.initialItems ?? []);
        if (_showSelectedItemsInField) {
          textController.text =
              selectedItemsConvertor(listData: selectedItemsNotifier.value) ??
                  "";
        }
      } else {
        textController.text =
            selectedItemConvertor(listData: widget.initialItem) ?? "";
        selectedItemNotifier.value = widget.initialItem;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachAncestorScrollListener();
  }

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

  void _attachAncestorScrollListener() {
    final ScrollPosition? newPosition = _resolveAncestorScrollPosition();
    if (identical(_ancestorScrollPosition, newPosition)) return;

    _ancestorScrollPosition?.removeListener(_handleAncestorScrollChange);
    _ancestorScrollPosition = newPosition;
    _ancestorScrollPosition?.addListener(_handleAncestorScrollChange);
  }

  void _handleAncestorScrollChange() {
    final position = _ancestorScrollPosition;
    if (!_closeDropdownOnParentScroll ||
        position == null ||
        !_overlayController.isShowing) {
      return;
    }
    _dismissOverlay(resetText: true);
  }

  void _restoreFieldValueAfterDismiss() {
    itemsNotifier.value = widget.item;
    if (_isMultiSelect) {
      if (_showSelectedItemsInField) {
        if (selectedItemsNotifier.value.isEmpty) {
          textController.clear();
        } else {
          textController.text =
              selectedItemsConvertor(listData: selectedItemsNotifier.value) ??
                  "";
        }
      } else {
        textController.clear();
      }
      return;
    }

    if (selectedItemNotifier.value == null) {
      textController.clear();
    } else {
      textController.text =
          selectedItemConvertor(listData: selectedItemNotifier.value) ??
              "${selectedItemNotifier.value}";
    }
  }

  void _dismissOverlay({bool resetText = false}) {
    if (!_overlayController.isShowing) return;
    if (resetText) {
      _restoreFieldValueAfterDismiss();
    }
    _overlayController.hide();
  }

  void _showOverlay() {
    if (_overlayController.isShowing) return;
    _overlayController.show();
  }

  void _focusNodeListener() async {
    if (widget.focusNode!.hasFocus) {
      if (widget.onTap != null) {
        textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textController.text.length,
        );
        itemsNotifier.value = await widget.onTap!();
      }
      if (mounted) {
        focusedIndexNotifier.value = _overlayController.isShowing ? 0 : -1;
      }
    } else {
      if (mounted) {
        // Reset search results so the next open shows the full list.
        itemsNotifier.value = widget.item;
        if (_isMultiSelect) {
          if (_showSelectedItemsInField) {
            textController.text =
                selectedItemsConvertor(listData: widget.initialItems) ?? "";
          } else {
            textController.clear();
          }
        } else {
          textController.text =
              selectedItemConvertor(listData: widget.initialItem) ?? "";
        }
      }
    }
  }

  String? selectedItemConvertor({T? listData}) {
    if (listData != null && widget.selectedItemBuilder != null) {
      return (widget.selectedItemBuilder!(context, listData as T)).data ?? "";
    }
    return null;
  }

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

  final ValueNotifier<bool> isApiLoadingNotifier = ValueNotifier<bool>(false);

  @override
  void didUpdateWidget(covariant SearchFieldDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.item != oldWidget.item) {
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
      if (widget.initialItems != oldWidget.initialItems) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItems == null || widget.initialItems!.isEmpty) {
            selectedItemsNotifier.value = [];
            textController.clear();
          } else {
            selectedItemsNotifier.value = List.from(widget.initialItems!);
            if (_showSelectedItemsInField) {
              textController.text = selectedItemsConvertor(
                      listData: selectedItemsNotifier.value) ??
                  "";
            } else {
              textController.clear();
            }
          }
        });
      }
    } else {
      // Only schedule a callback if initialItem actually changed —
      // avoids running a postFrameCallback every didUpdateWidget.
      if (widget.initialItem != oldWidget.initialItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItem == null) {
            selectedItemNotifier.value = null;
            textController.clear();
          } else {
            selectedItemNotifier.value = widget.initialItem;
            textController.text =
                selectedItemConvertor(listData: widget.initialItem) ?? "";
          }
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

  void scrollToFocusedItem() {
    RenderBox? renderBox =
        itemListKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? addButtonRender =
        addButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final double itemHeight = renderBox.size.height;
    final double addButtonHeight = addButtonRender?.size.height ?? 0;
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

  /// Called when the user selects a drop-down item from the list.
  onItemSelected(int index) {
    if (_isMultiSelect) {
      if (itemsNotifier.value.isNotEmpty) {
        T tappedItem = itemsNotifier.value[index];
        final currentList = List<T>.from(selectedItemsNotifier.value);
        if (currentList.contains(tappedItem)) {
          currentList.remove(tappedItem);
        } else {
          currentList.add(tappedItem);
        }
        selectedItemsNotifier.value = currentList;

        if (_showSelectedItemsInField) {
          textController.text =
              selectedItemsConvertor(listData: currentList) ?? "";
          if (currentList.isEmpty) {
            textController.clear();
          }
        }
        widget.onChanged?.call(tappedItem);
        widget.onItemsChanged?.call(currentList);
      }
    } else {
      _dismissOverlay();
      if (itemsNotifier.value.isNotEmpty) {
        selectedItemNotifier.value = itemsNotifier.value[index];
        textController.text =
            selectedItemConvertor(listData: selectedItemNotifier.value) ??
                "${selectedItemNotifier.value}";
        widget.onChanged?.call(itemsNotifier.value[index]);

        if (widget.initialItem == null) {
          textController.clear();
          selectedItemNotifier.value = null;
        }
        focusedIndexNotifier.value = -1;
      }
    }
  }

  final GlobalKey contentKey = GlobalKey();

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
              if (renderBox != null && scrollController.hasClients) {
                scrollController.jumpTo(
                  focusedIndexNotifier.value * renderBox.size.height,
                );
              }
            }
          },
          LogicalKeySet(LogicalKeyboardKey.enter): () {
            if (focusedIndexNotifier.value >= 0) {
              onItemSelected(focusedIndexNotifier.value);
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
                    // Dismiss barrier — translucent so keyboard shortcuts and
                    // focus still work normally. Scroll events are now claimed
                    // by the dropdown's own ListView (which is hit-tested first
                    // via SizedBox.expand in OverlayBuilder) and never reach
                    // the background ListView.
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
                      onChanged: widget.onChanged,
                      dropdownOffset: widget.decoration?.dropdownOffset,
                      decoration: widget.decoration,
                      changeIndex: changeFocusIndex,
                      onItemSelected: onItemSelected,
                      addButton: widget.addButton,
                      controller: _overlayController,
                      textController: textController,
                      initialItem: widget.initialItem,
                      isApiLoadingNotifier: isApiLoadingNotifier,
                      loaderWidget: widget.loaderWidget,
                      listItemBuilder: widget.listItemBuilder,
                      errorWidgetHeight: widget.errorWidgetHeight,
                      selectedItemBuilder: widget.selectedItemBuilder,
                      readOnly: isTypingDisabledNotifier.value
                          ? true
                          : widget.decoration?.readOnly ?? false,
                      fieldReadOnly: _fieldReadOnly,
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

  /// Drop-down on tap function.
  textFiledOnTap() async {
    _attachAncestorScrollListener();
    focusedIndexNotifier.value = 0;
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textController.text.length,
    );

    if (!_readOnly) {
      _showOverlay();
      if (widget.onTap != null && widget.focusNode == null) {
        itemsNotifier.value = await widget.onTap!();
      } else if (widget.onTap == null) {
        // Local list mode: always reset to full list on re-open so previous
        // search results don't persist after the dropdown was dismissed.
        itemsNotifier.value = widget.item;
      }
    }
  }

  /// Drop-down search / text field onChange — debounced to avoid API floods.
  onChange(String value) async {
    dropDownOpen();

    RenderBox? renderBox =
        itemListKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    // Debounce search calls — prevents hammering the API on every keystroke.
    _searchDebounce.run(() {
      if (!mounted) return;
      onSearchCalled(value.isEmpty ? "" : value);
    });
  }

  /// Calls onSearch if provided.
  onSearchCalled(String value) async {
    if (widget.onSearch != null) {
      final result = await widget.onSearch!(value);
      if (mounted) {
        itemsNotifier.value = result;
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

  /// Opens the dropdown when any event triggers.
  dropDownOpen() {
    _attachAncestorScrollListener();
    if (!_overlayController.isShowing) {
      focusedIndexNotifier.value = 0;
      _showOverlay();
    }
    if (textController.text.isEmpty) {
      itemsNotifier.value = widget.item;
    }
  }
}

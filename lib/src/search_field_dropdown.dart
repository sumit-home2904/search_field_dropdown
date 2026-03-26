import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'overlay_builder.dart';
import 'signatures.dart';
import 'search_field_dropdown_decoration.dart';

class SearchFieldDropdown<T> extends StatefulWidget {
  /// List of items to display in the dropdown.
  final List<T> item;

  /// Use this for [TextFormField] text form fields you want to read only.
  final bool fieldReadOnly;

  /// Call when change drop-down opening offset.
  final Offset? dropdownOffset;
  final double? errorWidgetHeight;

  /// When you have text fields, users can usually long-press to select text,
  /// which brings up the toolbar with options like copy, paste, etc.
  final bool? enableInteractiveSelection;

  /// Use this for [SearchFieldDropdown] to make the entire dropdown read only.
  final bool readOnly;

  /// The automatically generated controller an initial value.
  final T? initialItem;

  /// Use if you are using an API with a loading state.
  final bool isApiLoading;

  /// Call when you want to show cursor.
  final bool? showCursor;

  /// Set all the styling properties for rendering inside the dropdown natively.
  final SearchFieldDropdownDecoration? decoration;

  /// Use this if you want to provide your custom widget when using the API.
  final Widget? loaderWidget;

  /// Call when we need to focus; your drop-down is searchable.
  final FocusNode? focusNode;

  /// [errorMessage] shows a custom message when [item] is empty.
  final Text? errorMessage;

  /// Provide drop-down tile height.
  final double? overlayHeight;

  /// Call when you need to add a button or any custom functionality widget.
  final Widget? addButton;

  /// Callback function when an item is selected.
  final Function(T? value)? onChanged;

  /// Whether the dropdown allows multiple selections. default is false.
  final bool isMultiSelect;

  /// Callback when multiple items are selected.
  final Function(List<T>)? onItemsChanged;

  /// Initial multiple items selected.
  final List<T>? initialItems;

  /// Build your selected multiple values UI formatted string using this property.
  final SelectedItemsBuilder<T>? selectedItemsBuilder;

  /// Customize the display of selected items below the search field in multi-select mode.
  final MultiSelectDisplayBuilder<T>? multiSelectDisplayBuilder;

  // (multiSelectCheckBuilder moved to SearchFieldDropdownDecoration)

  /// Whether to display the text of selected items inside the search field. default is true.
  final bool showSelectedItemsInField;

  // (menuDecoration and fieldDecoration moved to SearchFieldDropdownDecoration)

  /// Call when [SearchFieldDropdown] is using the API or to load your list items.
  final Future<List<T>> Function()? onTap;

  /// Enable the validation listener on item change.
  final AutovalidateMode? autovalidateMode;

  /// Use the [OverlayPortalController] to display or conceal your drop-down.
  final OverlayPortalController controller;

  /// Build your drop-down listing custom UI using this property.
  final ListItemBuilder<T> listItemBuilder;

  /// Build your selected value UI using this property.
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// To search for items. Can be used for API search.
  final Future<List<T>> Function(String value)? onSearch;

  // (listPadding moved to SearchFieldDropdownDecoration)

  /// When the value of [canShowButton] is true, the add button becomes visible.
  final bool canShowButton;

  /// Call when you need to change the search field textAlign.
  final TextAlign textAlign;

  /// Call when [keyboardType] you need to obtain a specific type of input.
  final TextInputType? keyboardType;

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
    this.showCursor,
    this.initialItem,
    this.keyboardType,
    this.loaderWidget,
    this.errorMessage,
    required this.item,
    this.overlayHeight,
    this.dropdownOffset,
    this.inputFormatters,
    this.readOnly = false,
    this.errorWidgetHeight,
    this.autovalidateMode,
    this.onChanged,
    this.isMultiSelect = false,
    this.onItemsChanged,
    this.initialItems,
    this.selectedItemsBuilder,
    this.multiSelectDisplayBuilder,
    this.showSelectedItemsInField = true,
    required this.controller,
    this.selectedItemBuilder,
    this.isApiLoading = false,
    this.fieldReadOnly = false,
    this.canShowButton = false,
    required this.listItemBuilder,
    this.enableInteractiveSelection,
    this.textAlign = TextAlign.start,
    this.decoration,
  });

  @override
  State<SearchFieldDropdown<T>> createState() => SearchFieldDropdownState<T>();
}

class SearchFieldDropdownState<T> extends State<SearchFieldDropdown<T>> {
  T? selectedItem;
  late List<T> items;
  List<T> selectedItemsList = [];

  int focusedIndex = -1;

  void removeSelectedItem(T item) {
    if (selectedItemsList.contains(item)) {
      setState(() {
        selectedItemsList.remove(item);
        if (widget.showSelectedItemsInField) {
          textController.text =
              selectedItemsConvertor(listData: selectedItemsList) ?? "";
          if (selectedItemsList.isEmpty) textController.clear();
        } else {
          textController.clear();
        }
        widget.onItemsChanged?.call(selectedItemsList);
      });
    }
  }

  bool isTypingDisabled = false;
  bool isKeyboardNavigation = false;

  final layerLink = LayerLink();
  final GlobalKey textFieldKey = GlobalKey();
  final GlobalKey itemListKey = GlobalKey();
  final GlobalKey addButtonKey = GlobalKey();

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  /// Debounce timer for onSearch to avoid excessive API calls on rapid typing.
  final SearchTimerMethod _searchDebounce =
      SearchTimerMethod(milliseconds: 350);

  /// Guard: only call setState when focusedIndex actually changes.
  void changeFocusIndex(int index) {
    if (focusedIndex == index) return;
    focusedIndex = index;
    setState(() {});
  }

  /// Guard: only call setState when keyboard-navigation flag actually changes.
  void changeKeyBool(bool newValue) {
    if (isKeyboardNavigation == newValue) return;
    isKeyboardNavigation = newValue;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    items = [];

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_focusNodeListener);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      items = widget.item;
      if (widget.isMultiSelect) {
        selectedItemsList = List.from(widget.initialItems ?? []);
        if (widget.showSelectedItemsInField) {
          textController.text =
              selectedItemsConvertor(listData: selectedItemsList) ?? "";
        }
      } else {
        textController.text =
            selectedItemConvertor(listData: widget.initialItem) ?? "";
        selectedItem = widget.initialItem;
      }
    });
  }

  void _focusNodeListener() async {
    if (widget.focusNode!.hasFocus) {
      if (widget.onTap != null) {
        textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textController.text.length,
        );
        items = await widget.onTap!();
      }
      if (mounted) {
        setState(() {
          focusedIndex = widget.controller.isShowing ? 0 : -1;
        });
      }
    } else {
      if (mounted) {
        // Reset search results so the next open shows the full list.
        items = widget.item;
        if (widget.isMultiSelect) {
          if (widget.showSelectedItemsInField) {
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

  bool isApiLoading = false;

  @override
  void didUpdateWidget(covariant SearchFieldDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.item != oldWidget.item) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        items = widget.item;
        setState(() {});
      });
    }

    if (widget.isApiLoading != oldWidget.isApiLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        isApiLoading = widget.isApiLoading;
        setState(() {});
      });
    }

    if (widget.isMultiSelect) {
      if (widget.initialItems != oldWidget.initialItems) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItems == null || widget.initialItems!.isEmpty) {
            selectedItemsList.clear();
            textController.clear();
          } else {
            selectedItemsList = List.from(widget.initialItems!);
            if (widget.showSelectedItemsInField) {
              textController.text =
                  selectedItemsConvertor(listData: selectedItemsList) ?? "";
            } else {
              textController.clear();
            }
          }
          setState(() {});
        });
      }
    } else {
      // Only schedule a callback if initialItem actually changed —
      // avoids running a postFrameCallback every didUpdateWidget.
      if (widget.initialItem != oldWidget.initialItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (widget.initialItem == null) {
            selectedItem = null;
            textController.clear();
          } else {
            selectedItem = widget.initialItem;
            textController.text =
                selectedItemConvertor(listData: widget.initialItem) ?? "";
          }
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_focusNodeListener);
    _searchDebounce.cancel();
    textController.dispose();
    scrollController.dispose();
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

    final int maxVisibleItems =
        (((widget.overlayHeight ?? 150) - addButtonHeight) / itemHeight)
            .floor();
    final double firstVisibleIndex = scrollController.offset / itemHeight;
    final double lastVisibleIndex = firstVisibleIndex + (maxVisibleItems - 1);

    if (focusedIndex > lastVisibleIndex) {
      if (focusedIndex == items.length - 1) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
          );
        }
      } else {
        scrollController.jumpTo(
          (focusedIndex - (maxVisibleItems - 1)) * itemHeight,
        );
      }
    } else if (focusedIndex < firstVisibleIndex) {
      if (focusedIndex >= lastVisibleIndex - (maxVisibleItems - 1)) {
        return;
      }
      scrollController.jumpTo(focusedIndex * itemHeight);
    }
  }

  /// Called when the user selects a drop-down item from the list.
  onItemSelected(int index) {
    if (widget.isMultiSelect) {
      if (items.isNotEmpty) {
        T tappedItem = items[index];
        if (selectedItemsList.contains(tappedItem)) {
          selectedItemsList.remove(tappedItem);
        } else {
          selectedItemsList.add(tappedItem);
        }

        if (widget.showSelectedItemsInField) {
          textController.text =
              selectedItemsConvertor(listData: selectedItemsList) ?? "";
          if (selectedItemsList.isEmpty) {
            textController.clear();
          }
        } else {
          // Keep search text and results unmodified so the dropdown
          // doesn't jump abruptly resulting in visual bouncy artifacts.
        }

        widget.onItemsChanged?.call(selectedItemsList);
        // Do not reset focusedIndex to -1 here for multi-select.
        // This ensures hover/focus highlighting remains on the tapped item!
        setState(() {});
      }
    } else {
      widget.controller.hide();
      if (items.isNotEmpty) {
        selectedItem = items[index];
        textController.text =
            selectedItemConvertor(listData: selectedItem) ?? "$selectedItem";
        widget.onChanged?.call(items[index]);

        if (widget.initialItem == null) {
          textController.clear();
          selectedItem = null;
        }
        focusedIndex = -1;
        setState(() {});
      }
    }
  }

  final GlobalKey contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (widget.controller.isShowing) {
          widget.controller.hide();
        }
      },
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
            setState(() {
              isKeyboardNavigation = true;
              if (focusedIndex > 0) {
                focusedIndex--;
              } else {
                focusedIndex = items.length - 1;
              }
              scrollToFocusedItem();
            });
          },
          LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
            dropDownOpen();
            setState(() {
              isKeyboardNavigation = true;
              if (focusedIndex < items.length - 1) {
                focusedIndex++;
                scrollToFocusedItem();
              } else {
                focusedIndex = 0;
                RenderBox? renderBox = itemListKey.currentContext
                    ?.findRenderObject() as RenderBox?;
                if (renderBox != null && scrollController.hasClients) {
                  scrollController.jumpTo(
                    focusedIndex * renderBox.size.height,
                  );
                }
              }
            });
          },
          LogicalKeySet(LogicalKeyboardKey.enter): () {
            if (focusedIndex >= 0) {
              onItemSelected(focusedIndex);
            }
          },
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OverlayPortal(
              controller: widget.controller,
              overlayChildBuilder: (context) {
                final RenderBox? renderBox = textFieldKey.currentContext
                    ?.findRenderObject() as RenderBox?;
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
                          // Reset items so that next open shows the full list,
                          // not the previously filtered search results.
                          items = widget.item;
                          if (widget.isMultiSelect) {
                            if (widget.showSelectedItemsInField) {
                              if (selectedItemsList.isEmpty) {
                                textController.clear();
                              } else {
                                textController.text = selectedItemsConvertor(
                                        listData: selectedItemsList) ??
                                    "";
                              }
                            } else {
                              textController.clear();
                            }
                          } else {
                            if (selectedItem == null) {
                              textController.clear();
                            } else {
                              textController.text = selectedItemConvertor(
                                      listData: widget.initialItem) ??
                                  "";
                            }
                          }
                          setState(() {});
                          widget.controller.hide();
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                    OverlayBuilder(
                      key: contentKey,
                      fieldKey: textFieldKey,
                      item: items,
                      layerLink: layerLink,
                      isMultiSelect: widget.isMultiSelect,
                      selectedItemsList: selectedItemsList,
                      readOnly: isTypingDisabled ? true : widget.fieldReadOnly,
                      renderBox: renderBox,
                      changeKeyBool: changeKeyBool,
                      scrollController: scrollController,
                      focusedIndex: focusedIndex,
                      isKeyboardNavigation: isKeyboardNavigation,
                      itemListKey: itemListKey,
                      addButtonKey: addButtonKey,
                      onChanged: widget.onChanged,
                      decoration: widget.decoration,
                      changeIndex: changeFocusIndex,
                      onItemSelected: onItemSelected,
                      addButton: widget.addButton,
                      controller: widget.controller,
                      textController: textController,
                      initialItem: widget.initialItem,
                      isApiLoading: widget.isApiLoading,
                      loaderWidget: widget.loaderWidget,
                      errorMessage: widget.errorMessage,
                      fieldReadOnly: widget.fieldReadOnly,
                      overlayHeight: widget.overlayHeight,
                      canShowButton: widget.canShowButton,
                      dropdownOffset: widget.dropdownOffset,
                      listItemBuilder: widget.listItemBuilder,
                      errorWidgetHeight: widget.errorWidgetHeight,
                      selectedItemBuilder: widget.selectedItemBuilder,
                    ),
                  ],
                );
              },
              child: CompositedTransformTarget(
                link: layerLink,
                child: Listener(
                  onPointerDown: (PointerDownEvent event) {
                    final newValue = event.buttons == kSecondaryMouseButton;
                    if (isTypingDisabled != newValue) {
                      setState(() => isTypingDisabled = newValue);
                    }
                  },
                  child: TextFormField(
                    key: textFieldKey,
                    enableInteractiveSelection:
                        widget.enableInteractiveSelection ??
                            (!widget.fieldReadOnly),
                    style: widget.decoration?.textStyle ?? const TextStyle(),
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    textAlign: widget.textAlign,
                    readOnly: isTypingDisabled ? true : widget.fieldReadOnly,
                    focusNode: widget.focusNode,
                    controller: textController,
                    showCursor: widget.showCursor,
                    cursorHeight: widget.decoration?.cursorHeight,
                    cursorWidth: widget.decoration?.cursorWidth ?? 2.0,
                    cursorRadius: widget.decoration?.cursorRadius,
                    decoration: widget.decoration?.fieldDecoration ??
                        const InputDecoration(),
                    cursorColor: widget.decoration?.cursorColor ?? Colors.black,
                    cursorErrorColor:
                        widget.decoration?.cursorErrorColor ?? Colors.black,
                    autovalidateMode: widget.autovalidateMode,
                    validator: widget.validator,
                    onChanged: onChange,
                    onTap: textFiledOnTap,
                  ),
                ),
              ),
            ),
            if (widget.isMultiSelect &&
                widget.multiSelectDisplayBuilder != null)
              widget.multiSelectDisplayBuilder!(
                context,
                selectedItemsList,
                removeSelectedItem,
              ),
          ],
        ),
      ),
    );
  }

  /// Drop-down on tap function.
  textFiledOnTap() async {
    focusedIndex = 0;
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textController.text.length,
    );

    if (!widget.readOnly) {
      widget.controller.show();
      if (widget.onTap != null && widget.focusNode == null) {
        items = await widget.onTap!();
      } else if (widget.onTap == null) {
        // Local list mode: always reset to full list on re-open so previous
        // search results don't persist after the dropdown was dismissed.
        items = widget.item;
      }
      if (mounted) setState(() {});
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

    setState(() {});
  }

  /// Calls onSearch if provided.
  onSearchCalled(String value) async {
    if (widget.onSearch != null) {
      final result = await widget.onSearch!(value);
      if (mounted) {
        setState(() => items = result);
      }
    }
  }

  /// Opens the dropdown when any event triggers.
  dropDownOpen() {
    if (!widget.controller.isShowing) {
      focusedIndex = 0;
      widget.controller.show();
    }
    if (textController.text.isEmpty) {
      items = widget.item;
    }
  }
}

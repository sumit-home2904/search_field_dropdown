import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'overlay_builder.dart';
import 'signatures.dart';

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

  /// Use this to style your search or selected text.
  final TextStyle textStyle;

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
  final Function(T? value) onChanged;

  /// Give your drop-down a custom decoration style.
  final BoxDecoration? menuDecoration;

  /// Creates a [TextFormField] with an [InputDecoration].
  final InputDecoration filedDecoration;

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

  /// Call for [listPadding] to provide padding for the list view.
  final EdgeInsets? listPadding;

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

  final double? elevation;

  const SearchFieldDropdown(
      {super.key,
      this.onTap,
      this.onSearch,
      this.focusNode,
      this.addButton,
      this.validator,
      this.showCursor,
      this.listPadding,
      this.cursorColor,
      this.initialItem,
      this.cursorWidth,
      this.keyboardType,
      this.cursorRadius,
      this.cursorHeight,
      this.loaderWidget,
      this.errorMessage,
      required this.item,
      this.overlayHeight,
      this.menuDecoration,
      this.dropdownOffset,
      this.inputFormatters,
      this.cursorErrorColor,
      this.readOnly = false,
      this.errorWidgetHeight,
      this.autovalidateMode,
      required this.textStyle,
      required this.onChanged,
      required this.controller,
      this.selectedItemBuilder,
      this.isApiLoading = false,
      this.fieldReadOnly = false,
      this.canShowButton = false,
      required this.listItemBuilder,
      required this.filedDecoration,
      this.enableInteractiveSelection,
      this.textAlign = TextAlign.start,
      this.elevation = 0});

  @override
  State<SearchFieldDropdown<T>> createState() => SearchFieldDropdownState<T>();
}

class SearchFieldDropdownState<T> extends State<SearchFieldDropdown<T>> {
  T? selectedItem;
  late List<T> items;

  int focusedIndex = -1;

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
      textController.text =
          selectedItemConvertor(listData: widget.initialItem) ?? "";
      selectedItem = widget.initialItem;
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
        textController.text =
            selectedItemConvertor(listData: widget.initialItem) ?? "";
      }
    }
  }

  String? selectedItemConvertor({T? listData}) {
    if (listData != null && widget.selectedItemBuilder != null) {
      return (widget.selectedItemBuilder!(context, listData as T)).data ?? "";
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
    widget.controller.hide();
    if (items.isNotEmpty) {
      selectedItem = items[index];
      textController.text =
          selectedItemConvertor(listData: selectedItem) ?? "$selectedItem";
      widget.onChanged(items[index]);

      if (widget.initialItem == null) {
        textController.clear();
        selectedItem = null;
      }
      focusedIndex = -1;
      setState(() {});
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
        child: OverlayPortal(
          controller: widget.controller,
          overlayChildBuilder: (context) {
            final RenderBox? renderBox =
                textFieldKey.currentContext?.findRenderObject() as RenderBox?;
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
                      if (selectedItem == null) {
                        textController.clear();
                      } else {
                        textController.text =
                            selectedItemConvertor(
                                    listData: widget.initialItem) ??
                                "";
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
                  readOnly: isTypingDisabled ? true : widget.fieldReadOnly,
                  renderBox: renderBox,
                  changeKeyBool: changeKeyBool,
                  scrollController: scrollController,
                  focusedIndex: focusedIndex,
                  isKeyboardNavigation: isKeyboardNavigation,
                  itemListKey: itemListKey,
                  addButtonKey: addButtonKey,
                  onChanged: widget.onChanged,
                  elevation: widget.elevation,
                  changeIndex: changeFocusIndex,
                  onItemSelected: onItemSelected,
                  textStyle: widget.textStyle,
                  addButton: widget.addButton,
                  controller: widget.controller,
                  textController: textController,
                  initialItem: widget.initialItem,
                  listPadding: widget.listPadding,
                  isApiLoading: widget.isApiLoading,
                  loaderWidget: widget.loaderWidget,
                  errorMessage: widget.errorMessage,
                  cursorRadius: widget.cursorRadius,
                  fieldReadOnly: widget.fieldReadOnly,
                  overlayHeight: widget.overlayHeight,
                  canShowButton: widget.canShowButton,
                  menuDecoration: widget.menuDecoration,
                  dropdownOffset: widget.dropdownOffset,
                  listItemBuilder: widget.listItemBuilder,
                  cursorErrorColor: widget.cursorErrorColor,
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
                enableInteractiveSelection: widget.enableInteractiveSelection ??
                    (!widget.fieldReadOnly),
                style: widget.textStyle,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textAlign: widget.textAlign,
                readOnly: isTypingDisabled ? true : widget.fieldReadOnly,
                focusNode: widget.focusNode,
                controller: textController,
                showCursor: widget.showCursor,
                cursorHeight: widget.cursorHeight,
                cursorWidth: widget.cursorWidth ?? 2.0,
                cursorRadius: widget.cursorRadius,
                decoration: widget.filedDecoration,
                cursorColor: widget.cursorColor ?? Colors.black,
                cursorErrorColor: widget.cursorErrorColor ?? Colors.black,
                autovalidateMode: widget.autovalidateMode,
                validator: widget.validator,
                onChanged: onChange,
                onTap: textFiledOnTap,
              ),
            ),
          ),
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

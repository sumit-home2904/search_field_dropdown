import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'overlay_builder.dart';
import 'signatures.dart';

class SearchFieldDropdown<T> extends StatefulWidget {
  /// List of strings to display in the dropdown.
  final List<T> item;

  /// Use this for[TextFormField] text form fields you want to read only.
  final bool fieldReadOnly;

  /// call when change drop-down opening offset
  final Offset? dropdownOffset;
  final double? errorWidgetHeight;

  /// when you have text fields, users can usually long-press to select text,
  /// which brings up the toolbar with options like copy, paste, etc. So,
  /// [enableInteractiveSelection] probably relates to enabling or disabling that behavior.
  final bool? enableInteractiveSelection;

  /// Use this for [FromFieldDropDown] to read only from the dropdown you want.
  final bool readOnly;

  /// the automatically generated controller an initial value.
  final T? initialItem;

  /// use if you using api api
  final bool isApiLoading;

  /// call when you want to show cursor
  final bool? showCursor;

  /// call when you need to change cursor color
  final Color? cursorColor;

  /// call when you need to change cursor Height
  final double? cursorHeight;

  /// call when you need to change cursor Width
  final double? cursorWidth;

  /// call when you need to change cursor Radius
  final Radius? cursorRadius;

  /// call when you need to change cursor cursor Error Color
  final Color? cursorErrorColor;

  /// Use this to style your search or selected text.
  final TextStyle textStyle;

  /// Use this if you want to provide your custom widget when using the API
  final Widget? loaderWidget;

  /// Call when we need to focus; your drop-down is searchable.
  final FocusNode? focusNode;

  /// [errorMessage] Show a custom message when [item] is empty.
  final Text? errorMessage;

  /// provide drop-down tile height
  final double? overlayHeight;

  /// call when you need add button or need any kind for button functionality
  /// open a dialog navigate to other page's ect...
  /// dart
  /// InkWell(
  ///   onTap: () {
  ///     // add your event's
  ///  },
  /// child: Container(
  ///       height: 40,
  ///       padding: const EdgeInsets.all(10),
  ///       decoration:BoxDecoration(
  ///         color: Colors.green,
  ///         borderRadius: BorderRadius.circular(2),
  ///       ),
  ///       child: Row(
  ///         children: [
  ///           Expanded(
  ///             child: Text(
  ///                 "Add",
  ///                 maxLines: 1,
  ///                 textAlign:TextAlign.start,
  ///                 overflow: TextOverflow.ellipsis,
  ///                 style: const TextStyle(color: Colors.white)
  ///             ),
  ///           ),
  ///           Icon(
  ///            Icons.add,
  ///             color: Colors.white,
  ///          )
  ///         ],
  ///      ),
  ///    ),
  /// )
  final Widget? addButton;

  /// Callback function when an item is selected.
  final Function(T? value) onChanged;

  /// give your drop-down custom decoration style
  /// dart
  /// BoxDecoration(
  ///    color: Colors.white,
  ///    borderRadius: BorderRadius.circular(2),
  ///   ),
  final BoxDecoration? menuDecoration;

  /// * [InputDecorator], which shows the labels and other visual elements that
  /// Creates a [TextFormField] with an [InputDecoration]
  /// ///
  /// dart
  /// TextFormField(
  ///   decoration: const InputDecoration(
  ///     icon: Icon(Icons.person),
  ///     hintText: 'What do people call you?',
  ///     labelText: 'Name *',
  ///   ),
  final InputDecoration filedDecoration;

  /// call when [SearchFieldDropdown] you are using the API or to load your list items
  final Future<List<T>> Function()? onTap;

  /// Enable the validation listener on item change.
  /// This implies to [validator] everytime when the item change.
  final AutovalidateMode? autovalidateMode;

  /// Use the [OverlayPortalController] to display or conceal your drop-down.
  final OverlayPortalController controller;

  /// Build your drop-down listing custom UI using this property.
  /// dart
  /// listItemBuilder: (context, item, isSelected, onItemSelect) {
  ///    return Container(
  ///      decoration: BoxDecoration(
  ///        color: isSelected ? Colors.green : Colors.transparent,
  ///        borderRadius: BorderRadius.circular(2)
  ///    ),
  ///    child: Text(
  ///       item,
  ///       style: TextStyle(
  ///       fontSize: 12,
  ///       color: Colors.black,
  ///         fontWeight: FontWeight.w400
  ///      ),
  ///     ),
  ///   );
  /// },
  final ListItemBuilder<T> listItemBuilder;

  /// Build your selected value UI using this property.
  /// ```dart
  /// selectedItemBuilder: (context, item) {
  ///    return Text(
  ///      item!,
  ///      style: const TextStyle(
  ///         fontSize: 12,
  ///         fontWeight: FontWeight.w400
  ///      ),
  ///    );
  /// },
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// To search for your item, use the search functionality in the enter list,
  /// or we can utilize the API search functionality.
  final Future<List<T>> Function(String value)? onSearch;

  /// call for [listPadding] to provide padding for the list view
  final EdgeInsets? listPadding;


  /// When the value of [canShowButton] is true, the add button becomes visible.
  final bool canShowButton;

  /// ccall when you need to change the search field textAlign [TextAlign.start]
  final TextAlign textAlign;

  /// call when [keyboardType] you need to obtain a specific type of input, such as a number, email, etc.
  final TextInputType? keyboardType;

  /// When [canShowButton] is true, the add button becomes available, allowing
  /// you to use onButtonTab to navigate or open a dialog box, etc..
  final List<TextInputFormatter>? inputFormatters;

  /// we can validate your drop-down using a [validator]
  final String? Function(String? value)? validator;

  /// Creates a [Drop-down] that contains a [TextField].
  ///
  /// When a [controller] is specified, [initialItem] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialItem] or the empty string.
  ///

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

  void changeFocusIndex(int index) {
    focusedIndex = index;
    setState(() {});
  }

  void changeKeyBool(bool newValue) {
    isKeyboardNavigation = newValue;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    items = [];

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(() async {
        if (widget.focusNode!.hasFocus) {
          if (widget.onTap != null) {
            textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: textController.text.length,
            );
            items = await widget.onTap!();
          }
          if (widget.controller.isShowing) {
            focusedIndex = 0;
          } else {
            focusedIndex = -1;
          }
        } else {
          textController.text =
              selectedItemConvertor(listData: widget.initialItem) ?? "";
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      items = widget.item;

      textController.text =
          selectedItemConvertor(listData: widget.initialItem) ?? "";
      selectedItem = widget.initialItem;
    });
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

    if (widget.item != oldWidget.item ||
        widget.onSearch != oldWidget.onSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        items = widget.item;
        setState(() {});
      });
    }

    if (widget.isApiLoading != oldWidget.isApiLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isApiLoading = widget.isApiLoading;
        setState(() {});
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialItem != oldWidget.initialItem) {
        if (widget.initialItem == null) {
          selectedItem = null;
          // widget.onChanged(null);
          textController.clear();
          // if (widget.onSearch != null) widget.onSearch!("");
        } else {
          selectedItem = widget.initialItem;
          textController.text =
              selectedItemConvertor(listData: widget.initialItem) ?? "";
        }
      }
      setState(() {});
    });
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
            .floor(); // How many items fit in the view
    final double firstVisibleIndex = scrollController.offset / itemHeight;
    final double lastVisibleIndex = firstVisibleIndex + (maxVisibleItems - 1);

    // Scroll down logic
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
    }

    // Scroll up logic (only scroll when reaching firstVisibleIndex)
    else if (focusedIndex < firstVisibleIndex) {
      if (focusedIndex >= lastVisibleIndex - (maxVisibleItems - 1)) {
        // Do NOT scroll yet, allow selection to move up first
        return;
      }
      scrollController.jumpTo(
        focusedIndex * itemHeight,
      );
    }
  }

  /// This method is called when the user selects a drop-down value item from the list
  onItemSelected(index) {
    widget.controller.hide();
    if (items.isNotEmpty) {
      selectedItem = items[index];
      textController.text =
          selectedItemConvertor(listData: selectedItem) ?? "${selectedItem}";
      widget.onChanged(items[index]);

      ///If the onChange method in the dropdown does not set the initial item, none of the items will be selected.
      if (widget.initialItem == null) {
        textController.clear();
        selectedItem = null;
        setState(() {});
      }
      focusedIndex = -1;
      setState(() {});
    }
  }
  final GlobalKey contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: !widget.controller.isShowing, // Only allow pop when dropdown is hidden

      onPopInvokedWithResult:(didPop, result) {
        if (widget.controller.isShowing) {
          widget.controller.hide();
        }
      },
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
            // dropDownOpen();
            setState(() {
              isKeyboardNavigation = true;
              if (focusedIndex > 0) {
                focusedIndex--;
                scrollToFocusedItem();
              } else {
                focusedIndex = (items.length - 1);
                scrollToFocusedItem();
              }
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
                RenderBox? renderBox =
                    itemListKey.currentContext?.findRenderObject() as RenderBox?;
                scrollController.jumpTo(
                  focusedIndex * renderBox!.size.height, // Adjust height per item
                );
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
            return GestureDetector(
              // behavior: HitTestBehavior.translucent,
              // onTapDown: (details) {
              //   // Check if tap is outside the dropdown content
              //   final RenderBox contentBox = contentKey.currentContext!.findRenderObject() as RenderBox;
              //   final Offset localPosition = contentBox.globalToLocal(details.globalPosition);
              //
              //   if (!contentBox.size.contains(localPosition)) {
              //     widget.controller.hide();
              //   }
              // },

              onTap: () {
                if (selectedItem == null) {
                  textController.clear();
                } else {
                  textController.text =
                      selectedItemConvertor(listData: widget.initialItem) ?? "";
                }
                setState(() {});
                widget.controller.hide();
              },
              child: Container(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    OverlayBuilder(
                      key: contentKey,
                      item: items,
                      layerLink: layerLink,
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
                    )
                  ],
                ),
              ),
            );
          },
          child: CompositedTransformTarget(
            link: layerLink,
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                if (event.buttons == kSecondaryMouseButton) {
                  // Disable typing on secondary mouse button press
                  setState(() {
                    isTypingDisabled = true;
                  });
                } else {
                  setState(() {
                    isTypingDisabled = false;
                  });
                }
              },
              child: TextFormField(
                key: textFieldKey,
                enableInteractiveSelection:
                    widget.enableInteractiveSelection ?? (!widget.fieldReadOnly),
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

  /// drop-down on tap function
  textFiledOnTap() async {
    focusedIndex = 0;
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textController.text.length,
    );

    if (!(widget.readOnly)) {
      widget.controller.show();
      if (widget.onTap != null && widget.focusNode == null) {
        items = await widget.onTap!();
      }
      setState(() {});
    }
  }

  /// drop-down search or text form filed on change function
  onChange(value) async {
    dropDownOpen();
    RenderBox? renderBox =
        itemListKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      focusedIndex = 0;
      scrollController.jumpTo(
        focusedIndex * renderBox.size.height, // Adjust height per item
      );
    }

    if (value.isEmpty) {
      onSearchCalled("");
    } else {
      onSearchCalled(value);
    }
    setState(() {});
  }

  /// when on search is not null then call this function
  onSearchCalled(value) async {
    if (widget.onSearch != null) items = await widget.onSearch!(value);
  }

  ///open drop down when any event trigger.
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

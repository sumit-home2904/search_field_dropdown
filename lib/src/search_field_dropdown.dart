import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'overlay_builder.dart';
import 'signatures.dart';

class SearchFieldDropdown<T> extends StatefulWidget {
  /// List of strings to display in the dropdown.
  final List<T> item;

  /// Use this for[TextFormField] text form fields you want to read only.
  final bool filedReadOnly;

  /// call when change drop-down opening offset
  final Offset? dropdownOffset;
  final double? errorWidgetHeight;

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

  /// call for [menuMargin] to provide Margin for the list view item container
  final EdgeInsets? menuMargin;

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

  const SearchFieldDropdown({
    super.key,
    this.onTap,
    this.onSearch,
    this.focusNode,
    this.addButton,
    this.validator,
    this.showCursor,
    this.menuMargin,
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
    this.isApiLoading = false,
    this.filedReadOnly = false,
    this.canShowButton = false,
    required this.listItemBuilder,
    required this.filedDecoration,
    this.selectedItemBuilder,
    this.textAlign = TextAlign.start,
  });

  @override
  State<SearchFieldDropdown<T>> createState() => SearchFieldDropdownState<T>();
}

class SearchFieldDropdownState<T> extends State<SearchFieldDropdown<T>> {
  T? selectedItem;
  late List<T> items;
  final layerLink = LayerLink();
  final GlobalKey textFieldKey = GlobalKey();
  bool isTypingDisabled = false;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = [];
    if (widget.focusNode != null) {
      widget.focusNode!.addListener(() async {
        if (widget.focusNode!.hasFocus) {
          if (widget.onTap != null) {
            items = await widget.onTap!();
          }
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialItem != oldWidget.initialItem) {
        if (widget.initialItem == null) {
          selectedItem = null;
          widget.onChanged(null);
          textController.clear();
          if (widget.onSearch != null) widget.onSearch!("");
        } else {
          selectedItem = widget.initialItem;
          textController.text =
              selectedItemConvertor(listData: widget.initialItem) ?? "";
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: widget.controller,
      overlayChildBuilder: (context) {
        final RenderBox? renderBox =
            textFieldKey.currentContext?.findRenderObject() as RenderBox?;
        return GestureDetector(
          onTap: () {
            if (selectedItem == null) {
              textController.clear();
              if (widget.onSearch != null) {
                widget.onSearch!("");
              }
            } else {
              textController.text =
                  selectedItemConvertor(listData: widget.initialItem) ?? "";
              if (widget.onSearch != null) {
                widget.onSearch!("");
              }
            }
            setState(() {});
            widget.controller.hide();
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                OverlayBuilder(
                  selectedItemBuilder: widget.selectedItemBuilder,
                  textController: textController,
                  controller: widget.controller,
                  textStyle: widget.textStyle,
                  onChanged: widget.onChanged,
                  listItemBuilder: widget.listItemBuilder,
                  item: items,
                  layerLink: layerLink,
                  overlayHeight: widget.overlayHeight,
                  listPadding: widget.listPadding,
                  errorWidgetHeight: widget.errorWidgetHeight,
                  dropdownOffset: widget.dropdownOffset,
                  filedReadOnly: widget.filedReadOnly,
                  isApiLoading: widget.isApiLoading,
                  addButton: widget.addButton,
                  canShowButton: widget.canShowButton,
                  loaderWidget: widget.loaderWidget,
                  errorMessage: widget.errorMessage,
                  menuDecoration: widget.menuDecoration,
                  cursorRadius: widget.cursorRadius,
                  cursorErrorColor: widget.cursorErrorColor,
                  initialItem: widget.initialItem,
                  menuMargin: widget.menuMargin,
                  renderBox: renderBox,
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
            style: widget.textStyle,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textAlign: widget.textAlign,
            readOnly: isTypingDisabled ? true : widget.filedReadOnly,
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
    );
  }

  /// drop-down on tap function
  textFiledOnTap() async {
    if (!(widget.readOnly)) {
      widget.controller.show();
      if (widget.onTap != null) {
        items = await widget.onTap!();
      }
      setState(() {});
    }
  }

  /// drop-down search or text form filed on change function
  onChange(value) async {
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
}

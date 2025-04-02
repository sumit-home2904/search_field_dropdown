import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/animated_section.dart';
import 'package:search_field_dropdown/src/signatures.dart';

class OverlayBuilder<T> extends StatefulWidget {
  final LayerLink layerLink;
  final List<T> item;
  final T? initialItem;
  final bool isApiLoading;
  final Widget? addButton;
  final bool fieldReadOnly;
  final Text? errorMessage;
  final bool canShowButton;
  final TextStyle textStyle;
  final Radius? cursorRadius;
  final RenderBox? renderBox;
  final Widget? loaderWidget;
  final double? overlayHeight;
  final Offset? dropdownOffset;
  final Color? cursorErrorColor;
  final EdgeInsets? listPadding;
  final double? errorWidgetHeight;
  final Function(T? value) onChanged;
  final BoxDecoration? menuDecoration;
  final List<FocusNode> itemsFocusNodeList;
  final OverlayPortalController controller;
  final ScrollController? scrollController;
  final ListItemBuilder<T> listItemBuilder;
  final TextEditingController textController;
  final SelectedItemBuilder<T>? selectedItemBuilder;
  const OverlayBuilder({
    super.key,
    this.renderBox,
    this.addButton,
    this.listPadding,
    this.initialItem,
    this.cursorRadius,
    this.loaderWidget,
    this.errorMessage,
    required this.item,
    this.overlayHeight,
    this.menuDecoration,
    this.dropdownOffset,
    this.scrollController,
    this.cursorErrorColor,
    this.errorWidgetHeight,
    required this.textStyle,
    required this.layerLink,
    required this.onChanged,
    required this.controller,
    this.selectedItemBuilder,
    this.isApiLoading = false,
    this.fieldReadOnly = false,
    this.canShowButton = false,
    required this.itemsFocusNodeList,
    required this.textController,
    required this.listItemBuilder,
  });

  @override
  State<OverlayBuilder<T>> createState() => _OverlayOutBuilderState<T>();
}

class _OverlayOutBuilderState<T> extends State<OverlayBuilder<T>> {
  T? selectedItem;
  bool displayOverlayBottom = true;

  final GlobalKey itemListKey = GlobalKey();
  final GlobalKey errorButtonKey = GlobalKey();
  final GlobalKey addButtonKey = GlobalKey();
  final key1 = GlobalKey(), key2 = GlobalKey();

  /// calculate drop-down height base on item length
  double baseOnHeightCalculate() {
    try {
      final context = addButtonKey.currentContext;
      final itemKeyContext = itemListKey.currentContext;
      final errorKeyContext = errorButtonKey.currentContext;
      double addButtonHeight = 0;
      double errorButtonHeight = 0;
      double itemHeight = 40; // Default height

      // Calculate add button height
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        addButtonHeight = renderBox?.size.height ?? 0.0;
      }

      // Calculate item height
      if (itemKeyContext != null) {
        final renderBox = itemKeyContext.findRenderObject() as RenderBox?;
        itemHeight = renderBox?.size.height ?? 40; // Default to 40
      }

      if (errorKeyContext != null) {
        final renderBox = errorKeyContext.findRenderObject() as RenderBox?;
        errorButtonHeight = renderBox?.size.height ?? 40; // Default to 40
      }

      if (widget.canShowButton) {
        if (widget.item.isNotEmpty) {
          return widget.item.length * itemHeight +
              errorButtonHeight +
              addButtonHeight;
        } else {
          return widget.errorWidgetHeight ??
              (errorButtonHeight + addButtonHeight + 40);
        }
      } else {
        if (widget.item.isNotEmpty) {
          return widget.item.length * itemHeight + 10;
        }
        if (widget.isApiLoading) {
          return 150; // Default loading height
        } else {
          return widget.errorWidgetHeight ??
              (errorButtonHeight + addButtonHeight + 40);
        }
      }
    } catch (_) {
      return widget.errorWidgetHeight ?? 125;
    }
  }

  /// The height of the drop-down container is calculated based on the item length or
  /// the add button, and when no items are available, the default pass height is displayed.
  double calculateHeight() {
    const double staticHeight = 150.0; // Static value fallback
    final double calculatedHeight = baseOnHeightCalculate();

    // If widget.overlayHeight is not provided, use staticHeight
    final double maxHeight = widget.overlayHeight ?? staticHeight;

    // Return the smaller value between the calculated height and maxHeight
    return calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialItem != null) {
        selectedItem = (widget.initialItem as T);
      }
      checkRenderObjects(); // Start checking render objects.
    });
  }

  /// use for move up and down when not scroll available
  void checkRenderObjects() {
    if (key1.currentContext != null && key2.currentContext != null) {
      final RenderBox? render1 =
          key1.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? render2 =
          key2.currentContext?.findRenderObject() as RenderBox?;

      if (render1 != null && render2 != null) {
        final screenHeight = MediaQuery.of(context).size.height;
        double y = render1.localToGlobal(Offset.zero).dy;

        if (screenHeight - y < render2.size.height) {
          displayOverlayBottom = false;
        }

        setState(() {}); // Update the state after calculation.
      }
    }
  }

  @override
  void didUpdateWidget(covariant OverlayBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialItem != oldWidget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedItem = (widget.initialItem as T) ?? null;
        });
      });
    }

    // Check if the item list or its length has changed
    if (oldWidget.item != widget.item ||
        oldWidget.item.length != widget.item.length) {
      // Trigger a recalculation and rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          baseOnHeightCalculate();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(calculateHeight());
    return CompositedTransformFollower(
        link: widget.layerLink,
        offset: setOffset(),
        followerAnchor:
            displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
        child: LayoutBuilder(builder: (context, c) {
          return Container(
            key: key1,
            height: calculateHeight() + 4,
            width: widget.renderBox?.size.width ?? c.maxWidth,
            decoration: menuDecoration(),
            child: AnimatedSection(
              expand: true,
              animationDismissed: widget.controller.hide,
              axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
              child: Container(
                  key: key2,
                  height: calculateHeight() + 4,
                  width: MediaQuery.sizeOf(context).width,
                  child: widget.isApiLoading
                      ? loaderWidget()
                      : (widget.item).isEmpty
                          ? emptyErrorWidget()
                          : uiListWidget()),
            ),
          );
        }));
  }

  /// This function returns the UI of drop-down tiles when the user clicks on
  /// the drop-down. After that, how the drop-down will look is all defined in
  /// this function.
  Widget uiListWidget() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: Container(
        height: calculateHeight(),
        // decoration: menuDecoration(),
        child: Column(
          children: [
            if (widget.canShowButton)
              if (widget.addButton != null)
                SizedBox(
                    key: addButtonKey,
                    child: widget.addButton ?? SizedBox(key: addButtonKey)),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                addRepaintBoundaries: false,
                addAutomaticKeepAlives: false,
                itemCount: widget.item.length,
                controller: widget.scrollController,
                physics: const ClampingScrollPhysics(),
                padding: widget.listPadding ?? EdgeInsets.zero,
                itemBuilder: (_, index) {
                  bool selected = isItemSelected(index);
                  return InkWell(
                    key: index == 0 ? itemListKey : null,
                    onTap: () => onItemSelected(index),
                    child: widget.listItemBuilder(
                      context,
                      widget.item[index],
                      selected,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This method returns a boolean value for the selected item from the list
  /// or user-defined in the selected item builder. You must first define what
  /// kind of value is visible when the user selects any type of value from the
  /// drop-down, or that kind of data will be available in your list; otherwise,
  /// you will encounter an error.
  bool isItemSelected(int index) {
    String? selectedValue = selectedItemConvertor(selectedItem) ?? "";
    String? selectedIndexValue = selectedItemConvertor(widget.item[index]);
    if (selectedItem != null) {
      return selectedItem as T == widget.item[index];
    } else {
      return selectedValue == selectedIndexValue;
    }
  }

  ///This is for the drop-down container decoration. If the user wants to provide
  /// a custom decoration, they can do so. However, if the widget is not set for
  /// the user side, we will provide our own default decoration.
  BoxDecoration menuDecoration() {
    if (widget.menuDecoration != null) return widget.menuDecoration!;
    return BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(5));
  }

  Offset setOffset() {
    return Offset(widget.dropdownOffset?.dx ?? 0,
        displayOverlayBottom ? widget.dropdownOffset?.dy ?? 55 : -10);
  }

  /// This method is called when the user selects a drop-down value item from the list
  onItemSelected(index) {
    widget.controller.hide();
    selectedItem = widget.item[index];
    widget.textController.text =
        selectedItemConvertor(selectedItem) ?? "${selectedItem}";
    widget.onChanged(widget.item[index]);
    setState(() {});
  }

  String? selectedItemConvertor(T? listData) {
    if (listData != null && widget.selectedItemBuilder != null) {
      return (widget.selectedItemBuilder!(context, listData as T)).data ?? "";
    }
    return null;
  }

  /// This call displays an error message to the user when the item list is
  /// empty or the search value is not found, helping them understand what
  /// is happening in the UI. Additionally, the user can enter their custom message as well.
  Widget emptyErrorWidget() {
    return Container(
      key: errorButtonKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.canShowButton)
            if (widget.addButton != null)
              SizedBox(
                  key: addButtonKey,
                  child: widget.addButton ?? SizedBox(key: addButtonKey)),
          Spacer(),
          widget.errorMessage ?? const Text("No options"),
          Spacer(),
        ],
      ),
    );
  }

  /// this function return loader widget
  Widget loaderWidget() {
    return Container(
      alignment: Alignment.center,
      height: calculateHeight(),
      child: Center(
        child: widget.loaderWidget ?? const CircularProgressIndicator(),
      ),
    );
  }
}

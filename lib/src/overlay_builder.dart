import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/signatures.dart';
import 'package:search_field_dropdown/src/animated_section.dart';

class OverlayBuilder<T> extends StatefulWidget {
  final List<T> item;
  final LayerLink layerLink;
  final GlobalKey itemListKey;
  final GlobalKey addButtonKey;
  final GlobalKey fieldKey;
  final ScrollController scrollController;
  final T? initialItem;
  final int focusedIndex;
  final bool isApiLoading;
  final Widget? addButton;
  final bool fieldReadOnly;
  final bool isKeyboardNavigation;
  final Text? errorMessage;
  final bool canShowButton;
  final bool readOnly;
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
  final OverlayPortalController controller;
  final ListItemBuilder<T> listItemBuilder;
  final TextEditingController textController;
  final SelectedItemBuilder<T>? selectedItemBuilder;
  final Function(int) changeIndex;
  final Function(int) onItemSelected;
  final Function(bool) changeKeyBool;
  final double? elevation;

  const OverlayBuilder({
    super.key,
    this.renderBox,
    this.addButton,
    this.listPadding,
    this.initialItem,
    this.cursorRadius,
    required this.fieldKey,
    required this.readOnly,
    this.loaderWidget,
    required this.itemListKey,
    required this.addButtonKey,
    required this.isKeyboardNavigation,
    required this.focusedIndex,
    required this.scrollController,
    required this.changeKeyBool,
    this.errorMessage,
    required this.item,
    this.overlayHeight,
    this.menuDecoration,
    this.dropdownOffset,
    this.cursorErrorColor,
    this.errorWidgetHeight,
    required this.changeIndex,
    required this.onItemSelected,
    required this.textStyle,
    required this.layerLink,
    required this.onChanged,
    required this.controller,
    this.isApiLoading = false,
    this.fieldReadOnly = false,
    this.canShowButton = false,
    required this.textController,
    required this.listItemBuilder,
    this.selectedItemBuilder,
    this.elevation = 0,
  });

  @override
  State<OverlayBuilder<T>> createState() => _OverlayOutBuilderState<T>();
}

class _OverlayOutBuilderState<T> extends State<OverlayBuilder<T>> {
  T? selectedItem;
  bool displayOverlayBottom = true;

  final GlobalKey errorButtonKey = GlobalKey();
  final key1 = GlobalKey(), key2 = GlobalKey();

  /// Reusable timer for scroll-hover index tracking — prevents per-event allocations
  late final SearchTimerMethod _hoverScrollTimer;

  @override
  void initState() {
    super.initState();
    _hoverScrollTimer = SearchTimerMethod(milliseconds: 300);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialItem != null) {
        selectedItem = widget.initialItem as T;
      }
      checkRenderObjects();
    });
  }

  /// Calculate drop-down height based on item length
  double baseOnHeightCalculate() {
    try {
      final context = widget.addButtonKey.currentContext;
      final itemKeyContext = widget.itemListKey.currentContext;
      final errorKeyContext = errorButtonKey.currentContext;
      double addButtonHeight = 0;
      double errorButtonHeight = 0;
      double itemHeight = 40;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        addButtonHeight = renderBox?.size.height ?? 0.0;
      }

      if (itemKeyContext != null) {
        final renderBox = itemKeyContext.findRenderObject() as RenderBox?;
        itemHeight = renderBox?.size.height ?? 40;
      }

      if (errorKeyContext != null) {
        final renderBox = errorKeyContext.findRenderObject() as RenderBox?;
        errorButtonHeight = renderBox?.size.height ?? 40;
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
          return 150;
        } else {
          return widget.errorWidgetHeight ??
              (errorButtonHeight + addButtonHeight + 40);
        }
      }
    } catch (_) {
      return widget.errorWidgetHeight ?? 125;
    }
  }

  double calculateHeight() {
    const double staticHeight = 150.0;
    final double calculatedHeight = baseOnHeightCalculate();
    final double maxHeight = widget.overlayHeight ?? staticHeight;
    return calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
  }

  /// Determine whether dropdown opens below or above the text field.
  void checkRenderObjects() {
    if (!mounted) return;
    if (key1.currentContext == null || key2.currentContext == null) return;

    final RenderBox? render1 =
        key1.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? render2 =
        key2.currentContext?.findRenderObject() as RenderBox?;

    if (render1 == null || render2 == null) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final double y = render1.localToGlobal(Offset.zero).dy;

    bool newDisplayOverlayBottom;

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      newDisplayOverlayBottom = !(y -
              (widget.readOnly
                  ? 0
                  : MediaQuery.of(context).size.height * 0.4) >
          (widget.readOnly ? screenHeight - 150 : 50));
    } else {
      // Desktop / web: check if there is enough space below
      newDisplayOverlayBottom = (screenHeight - y) >= render2.size.height;
    }

    if (newDisplayOverlayBottom != displayOverlayBottom) {
      setState(() {
        displayOverlayBottom = newDisplayOverlayBottom;
      });
    }
  }

  @override
  void didUpdateWidget(covariant OverlayBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialItem != oldWidget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedItem = widget.initialItem;
          });
        }
      });
    }

    if (oldWidget.item != widget.item ||
        oldWidget.item.length != widget.item.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Calculate the overlay height that fits on screen (never negative).
  double customSize() {
    final RenderBox? renderBox =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return widget.overlayHeight ?? 150;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardOffset =
        widget.readOnly ? 0.0 : screenHeight * 0.4;

    if (!displayOverlayBottom) {
      final available = offset.dy - 50 - keyboardOffset;
      final max = widget.overlayHeight ?? 0;
      return available > max ? max : available.clamp(0, double.infinity);
    } else {
      final available = screenHeight - offset.dy - 50 - keyboardOffset;
      final max = widget.overlayHeight ?? 0;
      return available > max ? max : available.clamp(0, double.infinity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    // Compute a safe max height for the dropdown card.
    // customSize() uses the field's screen position to decide how much room is
    // available above or below the text field.
    final double rawSize = customSize();
    final double maxH =
        rawSize > 0 ? rawSize : (widget.overlayHeight ?? 150);

    // SizedBox.expand fills the full overlay area for correct hit-testing —
    // the dropdown's visual position (via CompositedTransformFollower) is
    // always inside this layout bounds, so scroll/click events reach the
    // inner ListView instead of the background.
    //
    // IMPORTANT: SizedBox.expand passes TIGHT constraints to its child.
    // UnconstrainedBox breaks that chain so ConstrainedBox(maxHeight) and
    // the inner SizedBox(height: calculateHeight()) work as intended.
    // Without this, the card would expand to full-screen height and
    // SizeTransition would show items starting from the very bottom.
    return SizedBox.expand(
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        child: CompositedTransformFollower(
          link: widget.layerLink,
          offset: setOffset(),
          followerAnchor:
              displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: LayoutBuilder(builder: (context, c) {
              return SizedBox(
                height: calculateHeight() + 4,
                width: widget.renderBox?.size.width ?? c.maxWidth,
                child: Card(
                  elevation: widget.elevation,
                  color: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Container(
                    key: key1,
                    height: calculateHeight() + 4,
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
                            : widget.item.isEmpty
                                ? emptyErrorWidget()
                                : uiListWidget(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }



  Widget uiListWidget() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: SizedBox(
        height: calculateHeight(),
        child: Column(
          children: [
            if (widget.canShowButton)
              if (widget.addButton != null)
                SizedBox(
                    key: widget.addButtonKey,
                    child:
                        widget.addButton ?? SizedBox(key: widget.addButtonKey)),
            const SizedBox(height: 2),
            Expanded(
              child: Listener(
                onPointerSignal: (event) {
                  // Reuse the timer field — do NOT create a new instance here
                  _hoverScrollTimer.run(() {
                    if (!mounted) return;
                    RenderBox? renderBox = widget.itemListKey.currentContext
                        ?.findRenderObject() as RenderBox?;
                    final double itemHeight = renderBox?.size.height ?? 30;
                    final double firstVisibleIndex =
                        widget.scrollController.offset / itemHeight;
                    final int museCourse =
                        ((event.localPosition.dy / itemHeight) - 1).ceil();
                    final int scrollIndex =
                        firstVisibleIndex.toInt() + museCourse;
                    widget.changeIndex(scrollIndex);
                  });
                },
                child: ListView.builder(
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  padding: widget.listPadding ?? EdgeInsets.zero,
                  itemCount: widget.item.length,
                  itemBuilder: (_, index) {
                    final bool selected = widget.focusedIndex == index;
                    return MouseRegion(
                      onHover: (event) {
                        // Guard: only call if value actually changes
                        if (widget.isKeyboardNavigation) {
                          widget.changeKeyBool(false);
                        }
                      },
                      onEnter: (event) {
                        // Guard: only update index if not in keyboard nav mode
                        if (!widget.isKeyboardNavigation &&
                            widget.focusedIndex != index) {
                          widget.changeIndex(index);
                        }
                      },
                      child: InkWell(
                        key: widget.focusedIndex == index
                            ? widget.itemListKey
                            : null,
                        onTap: () => widget.onItemSelected(index),
                        child: widget.listItemBuilder(
                          context,
                          widget.item[index],
                          selected,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isItemSelected(int index) {
    String? selectedValue = selectedItemConvertor(selectedItem) ?? "";
    String? selectedIndexValue = selectedItemConvertor(widget.item[index]);
    if (selectedItem != null) {
      return selectedItem as T == widget.item[index];
    } else {
      return selectedValue == selectedIndexValue;
    }
  }

  BoxDecoration menuDecoration() {
    if (widget.menuDecoration != null) return widget.menuDecoration!;
    return BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(5));
  }

  Offset setOffset() {
    return Offset(widget.dropdownOffset?.dx ?? 0,
        displayOverlayBottom ? widget.dropdownOffset?.dy ?? 55 : -10);
  }

  String? selectedItemConvertor(T? listData) {
    if (listData != null && widget.selectedItemBuilder != null) {
      return (widget.selectedItemBuilder!(context, listData as T)).data ?? "";
    }
    return null;
  }

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
                  key: widget.addButtonKey,
                  child:
                      widget.addButton ?? SizedBox(key: widget.addButtonKey)),
          const Spacer(),
          widget.errorMessage ?? const Text("No options"),
          const Spacer(),
        ],
      ),
    );
  }

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

class SearchTimerMethod {
  final int milliseconds;
  Timer? _timer;

  SearchTimerMethod({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

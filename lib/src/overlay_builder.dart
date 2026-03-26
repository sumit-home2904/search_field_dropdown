import 'dart:async';
import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/signatures.dart';
import 'package:search_field_dropdown/src/animated_section.dart';
import 'package:search_field_dropdown/src/search_field_dropdown_decoration.dart';

class OverlayBuilder<T> extends StatefulWidget {
  final ValueNotifier<List<T>> itemsNotifier;
  final LayerLink layerLink;
  final GlobalKey itemListKey;
  final GlobalKey addButtonKey;
  final GlobalKey fieldKey;
  final ScrollController scrollController;
  final T? initialItem;
  final ValueNotifier<int> focusedIndexNotifier;
  final ValueNotifier<bool> isApiLoadingNotifier;
  final Widget? addButton;
  final bool fieldReadOnly;
  final ValueNotifier<bool> isKeyboardNavigationNotifier;
  final Text? errorMessage;
  final bool canShowButton;
  final bool readOnly;
  final SearchFieldDropdownDecoration? decoration;
  final RenderBox? renderBox;
  final Widget? loaderWidget;
  final double? overlayHeight;
  final Offset? dropdownOffset;
  final double? errorWidgetHeight;
  final Function(T? value)? onChanged;
  final OverlayPortalController controller;
  final ListItemBuilder<T> listItemBuilder;
  final TextEditingController textController;
  final SelectedItemBuilder<T>? selectedItemBuilder;
  final Function(int) changeIndex;
  final Function(int) onItemSelected;
  final Function(bool) changeKeyBool;
  final bool isMultiSelect;
  final ValueNotifier<List<T>> selectedItemsNotifier;
  // Loose parameters moved to SearchFieldDropdownDecoration

  const OverlayBuilder({
    super.key,
    this.renderBox,
    this.addButton,
    this.initialItem,
    required this.fieldKey,
    required this.readOnly,
    this.loaderWidget,
    required this.itemListKey,
    required this.addButtonKey,
    required this.isKeyboardNavigationNotifier,
    required this.focusedIndexNotifier,
    required this.scrollController,
    required this.changeKeyBool,
    this.errorMessage,
    required this.itemsNotifier,
    this.overlayHeight,
    this.dropdownOffset,
    this.errorWidgetHeight,
    required this.changeIndex,
    required this.onItemSelected,
    this.decoration,
    required this.layerLink,
    this.onChanged,
    required this.controller,
    this.isMultiSelect = false,
    required this.selectedItemsNotifier,
    required this.isApiLoadingNotifier,
    this.fieldReadOnly = false,
    this.canShowButton = false,
    required this.textController,
    required this.listItemBuilder,
    this.selectedItemBuilder,
  });

  @override
  State<OverlayBuilder<T>> createState() => _OverlayOutBuilderState<T>();
}

class _OverlayOutBuilderState<T> extends State<OverlayBuilder<T>> {
  T? selectedItem;
  bool displayOverlayBottom = true;

  final GlobalKey errorButtonKey = GlobalKey();
  final key1 = GlobalKey(), key2 = GlobalKey();

  // Cached measurements updated after each frame
  double _addButtonHeight = 0;
  double _itemHeight = 40;
  double _fieldHeight = 56; // actual rendered height of the trigger field

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
      _measureField();
      _updateCachedHeights();
      checkRenderObjects();
    });
  }

  /// Measure the trigger field height so offsets use the real value.
  void _measureField() {
    if (!mounted) return;
    final fb = widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb != null) {
      final h = fb.size.height;
      if (h != _fieldHeight) setState(() => _fieldHeight = h);
    }
  }

  /// Read rendered sizes and store them so height calculation is always fresh.
  void _updateCachedHeights() {
    if (!mounted) return;
    double newItemH = _itemHeight;
    double newAddH = _addButtonHeight;

    final itemCtx = widget.itemListKey.currentContext;
    if (itemCtx != null) {
      final rb = itemCtx.findRenderObject() as RenderBox?;
      if (rb != null) newItemH = rb.size.height;
    }

    final addCtx = widget.addButtonKey.currentContext;
    if (addCtx != null) {
      final rb = addCtx.findRenderObject() as RenderBox?;
      if (rb != null) newAddH = rb.size.height;
    }

    if (newItemH != _itemHeight || newAddH != _addButtonHeight) {
      setState(() {
        _itemHeight = newItemH;
        _addButtonHeight = newAddH;
      });
    }
  }

  /// Calculate drop-down height based on current state.
  /// Uses cached [_itemHeight] and [_addButtonHeight] so it stays
  /// accurate across API-loading, empty, and populated states.
  double baseOnHeightCalculate(List<T> currentItems, bool isLoading) {
    // API loading takes priority — show loader regardless of items
    if (isLoading) return 150;

    final double addH = _addButtonHeight;
    final double itemH = _itemHeight > 0 ? _itemHeight : 40;

    if (widget.canShowButton) {
      if (currentItems.isNotEmpty) {
        // List + optional add-button at the top
        return currentItems.length * itemH + addH + 2;
      } else {
        // Empty state: error message + add-button
        return widget.errorWidgetHeight ?? (addH + 80);
      }
    } else {
      if (currentItems.isNotEmpty) {
        return currentItems.length * itemH + 2;
      }
      // Empty state without add-button
      return widget.errorWidgetHeight ?? 80;
    }
  }

  /// Default max height when user does not provide [overlayHeight].
  static const double _defaultMaxHeight = 250.0;

  /// Final height the dropdown renders at.
  /// = min(contentHeight, userOverlayHeight ?? 250, availableScreenSpace)
  double calculateHeight(List<T> currentItems, bool isLoading) {
    final double content = baseOnHeightCalculate(currentItems, isLoading);
    final double screen = _availableScreenHeight();
    // Cap at user's max or the 250 default
    final double userMax = widget.overlayHeight ?? _defaultMaxHeight;
    final double capped = content < userMax ? content : userMax;
    // Never exceed physical space available on screen
    final double result = (screen > 0 && capped > screen) ? screen : capped;
    return result.clamp(0.0, double.infinity);
  }

  /// Physical screen space available above or below the field.
  /// Uses [MediaQuery.viewInsets.bottom] for the REAL keyboard height
  /// instead of a blanket 40% subtraction.
  double _availableScreenHeight() {
    final RenderBox? fb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb == null) return widget.overlayHeight ?? 250;
    final offset = fb.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final double keyboardH = mq.viewInsets.bottom;
    final double usableH = mq.size.height - keyboardH;
    const double safeMargin = 8.0;

    if (displayOverlayBottom) {
      // Space from the BOTTOM of the field to the top of keyboard/screen edge
      final double fieldBottom = offset.dy + fb.size.height;
      return (usableH - fieldBottom - safeMargin).clamp(0.0, double.infinity);
    } else {
      // Space from screen top to the TOP of the field
      return (offset.dy - safeMargin).clamp(0.0, double.infinity);
    }
  }

  /// Determine whether dropdown opens below or above the text field.
  /// Uses the field's actual position + keyboard-aware usable height.
  void checkRenderObjects() {
    if (!mounted) return;
    final RenderBox? fb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb == null) return;

    final mq = MediaQuery.of(context);
    final double keyboardH = mq.viewInsets.bottom;
    final double usableH = mq.size.height - keyboardH;
    final offset = fb.localToGlobal(Offset.zero);
    final double fieldBottom = offset.dy + fb.size.height;

    final double spaceBelow = usableH - fieldBottom;
    final double spaceAbove = offset.dy;
    // Use the INTENDED max height (not the screen-capped value) so the
    // above/below decision reflects the user's desired dropdown size.
    final double intended = widget.overlayHeight ?? _defaultMaxHeight;

    // Open below if enough space; otherwise open above (like a native select)
    final bool newBottom = spaceBelow >= intended || spaceBelow >= spaceAbove;

    if (newBottom != displayOverlayBottom) {
      setState(() => displayOverlayBottom = newBottom);
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

    if (oldWidget.canShowButton != widget.canShowButton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          checkRenderObjects();
          // Re-measure item/button heights after the new frame renders
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _measureField();
            _updateCachedHeights();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? fieldRb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fieldRb == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.itemsNotifier,
        widget.focusedIndexNotifier,
        widget.selectedItemsNotifier,
        widget.isApiLoadingNotifier,
      ]),
      builder: (context, child) {
        final currentItems = widget.itemsNotifier.value;
        final isLoading = widget.isApiLoadingNotifier.value;
        final fIndex = widget.focusedIndexNotifier.value;
        final sItems = widget.selectedItemsNotifier.value;

        final double h = calculateHeight(currentItems, isLoading);
        final double w = widget.renderBox?.size.width ?? fieldRb.size.width;

        return SizedBox.expand(
          child: UnconstrainedBox(
            alignment: Alignment.topLeft,
            clipBehavior: Clip.none,
            child: CompositedTransformFollower(
              link: widget.layerLink,
              offset: setOffset(),
              followerAnchor:
                  displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
              child: SizedBox(
                height: h,
                width: w,
                child: Card(
                  elevation: widget.decoration?.elevation ?? 0.0,
                  color: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Container(
                    key: key1,
                    height: h,
                    decoration: menuDecoration(),
                    child: AnimatedSection(
                      expand: true,
                      animationDismissed: widget.controller.hide,
                      axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                      child: Container(
                        key: key2,
                        height: h,
                        width: w,
                        child: isLoading
                            ? loaderWidget(currentItems, isLoading)
                            : currentItems.isEmpty
                                ? emptyErrorWidget()
                                : uiListWidget(currentItems, isLoading, fIndex, sItems),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget uiListWidget(List<T> currentItems, bool isLoading, int fIndex, List<T> sItems) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: SizedBox(
        height: calculateHeight(currentItems, isLoading),
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
                  padding: widget.decoration?.listPadding ?? EdgeInsets.zero,
                  itemCount: currentItems.length,
                  itemBuilder: (_, index) {
                    final bool selected = fIndex == index;
                    return MouseRegion(
                      onHover: (event) {
                        // Guard: only call if value actually changes
                        if (widget.isKeyboardNavigationNotifier.value) {
                          widget.changeKeyBool(false);
                        }
                      },
                      onEnter: (event) {
                        // Guard: only update index if not in keyboard nav mode
                        if (!widget.isKeyboardNavigationNotifier.value &&
                            fIndex != index) {
                          widget.changeIndex(index);
                        }
                      },
                      child: InkWell(
                        key: fIndex == index
                            ? widget.itemListKey
                            : null,
                        onTap: () => widget.onItemSelected(index),
                        child: Container(
                          padding: widget.decoration?.itemPadding,
                          decoration: selected
                              ? widget.decoration?.focusedItemDecoration
                              : widget.decoration?.unfocusedItemDecoration,
                          child: widget.isMultiSelect
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: widget.listItemBuilder(
                                        context,
                                        currentItems[index],
                                        selected,
                                      ),
                                    ),
                                    if (widget.decoration
                                            ?.multiSelectCheckBuilder !=
                                        null)
                                      widget.decoration!
                                              .multiSelectCheckBuilder!(
                                          context, isItemSelected(index, currentItems, sItems))
                                    else if (widget.isMultiSelect)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Icon(
                                          isItemSelected(index, currentItems, sItems)
                                              ? (widget.decoration
                                                      ?.multiSelectCheckedIcon ??
                                                  Icons.check_box)
                                              : (widget.decoration
                                                      ?.multiSelectUncheckedIcon ??
                                                  Icons
                                                      .check_box_outline_blank),
                                          size: 20,
                                          color: isItemSelected(index, currentItems, sItems)
                                              ? (widget.decoration
                                                      ?.multiSelectCheckedIconColor ??
                                                  Colors.blue)
                                              : (widget.decoration
                                                      ?.multiSelectUncheckedIconColor ??
                                                  Colors.grey.shade400),
                                        ),
                                      ),
                                  ],
                                )
                              : widget.listItemBuilder(
                                  context,
                                  currentItems[index],
                                  selected,
                                ),
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

  bool isItemSelected(int index, List<T> currentItems, List<T> sItems) {
    if (widget.isMultiSelect) {
      return sItems.contains(currentItems[index]);
    } else {
      String? selectedValue = selectedItemConvertor(selectedItem) ?? "";
      String? selectedIndexValue = selectedItemConvertor(currentItems[index]);
      if (selectedItem != null) {
        return selectedItem as T == currentItems[index];
      } else {
        return selectedValue == selectedIndexValue;
      }
    }
  }

  BoxDecoration menuDecoration() {
    if (widget.decoration?.menuDecoration != null)
      return widget.decoration!.menuDecoration!;
    return BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(5));
  }

  Offset setOffset() {
    final double dx = widget.dropdownOffset?.dx ?? 0;
    if (displayOverlayBottom) {
      // Below: position the overlay starting at the field's bottom edge.
      // Use actual _fieldHeight so no magic numbers are needed.
      final double dy = widget.dropdownOffset?.dy ?? _fieldHeight;
      return Offset(dx, dy);
    } else {
      // Above: followerAnchor=bottomLeft so overlay bottom aligns to
      // the target's origin (field top-left). No dy offset needed.
      return Offset(dx, 0);
    }
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

  Widget loaderWidget(List<T> currentItems, bool isLoading) {
    return Container(
      alignment: Alignment.center,
      height: calculateHeight(currentItems, isLoading),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/signatures.dart';
import 'package:search_field_dropdown/src/animated_section.dart';
import 'package:search_field_dropdown/src/search_field_dropdown_decoration.dart';

/// Pure overlay renderer for the dropdown.
///
/// All selection mutations stay in `SearchFieldDropdownState`; this widget
/// only reflects the current notifiers and forwards row taps back upward.
class OverlayBuilder<T> extends StatefulWidget {
  final Widget? addButton;
  final bool isMultiSelect;
  final GlobalKey fieldKey;
  final LayerLink layerLink;
  final Widget? loaderWidget;
  final GlobalKey itemListKey;
  final Offset? dropdownOffset;
  final GlobalKey addButtonKey;
  final double? errorWidgetHeight;
  final Function(int) changeIndex;
  final Function(int) onItemSelected;
  final Function(bool) changeKeyBool;
  final ScrollController scrollController;
  final OverlayPortalController controller;
  final ListItemBuilder<T> listItemBuilder;
  final TextEditingController textController;
  final ValueNotifier<List<T>> itemsNotifier;
  final ValueNotifier<int> focusedIndexNotifier;
  final ValueNotifier<bool> isApiLoadingNotifier;
  final SearchFieldDropdownDecoration? decoration;
  final ValueNotifier<List<T>> selectedItemsNotifier;
  final ValueNotifier<bool> isKeyboardNavigationNotifier;

  const OverlayBuilder({
    super.key,
    this.decoration,
    this.addButton,
    this.loaderWidget,
    this.dropdownOffset,
    required this.fieldKey,
    this.errorWidgetHeight,
    required this.layerLink,
    required this.controller,
    required this.changeIndex,
    required this.itemListKey,
    required this.addButtonKey,
    this.isMultiSelect = false,
    required this.changeKeyBool,
    required this.itemsNotifier,
    required this.textController,
    required this.onItemSelected,
    required this.listItemBuilder,
    required this.scrollController,
    required this.focusedIndexNotifier,
    required this.isApiLoadingNotifier,
    required this.selectedItemsNotifier,
    required this.isKeyboardNavigationNotifier,
  });

  @override
  State<OverlayBuilder<T>> createState() => _OverlayOutBuilderState<T>();
}

class _OverlayOutBuilderState<T> extends State<OverlayBuilder<T>>
    with WidgetsBindingObserver {
  final ValueNotifier<bool> displayOverlayBottomNotifier =
      ValueNotifier<bool>(true);

  final GlobalKey errorButtonKey = GlobalKey();
  final key1 = GlobalKey(), key2 = GlobalKey();

  // Cached measurements updated after each frame
  final ValueNotifier<double> fieldHeightNotifier =
      ValueNotifier<double>(56); // actual rendered height of the trigger field
  final ValueNotifier<double> fieldWidthNotifier = ValueNotifier<double>(0);

  /// Reusable timer for scroll-hover index tracking — prevents per-event allocations
  late final SearchTimerMethod _hoverScrollTimer;
  bool _measurementScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hoverScrollTimer = SearchTimerMethod(milliseconds: 300);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOverlayMetrics();
    });
  }

  @override
  void didChangeMetrics() {
    _scheduleOverlayMeasurement();
  }

  /// Measure the trigger field height so offsets use the real value.
  void _measureField() {
    if (!mounted) return;
    final fb = widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb != null && fb.attached) {
      final size = fb.size;
      if (size.height != fieldHeightNotifier.value) {
        fieldHeightNotifier.value = size.height;
      }
      if (size.width != fieldWidthNotifier.value) {
        fieldWidthNotifier.value = size.width;
      }
    }
  }

  void _syncOverlayMetrics() {
    _measureField();
    checkRenderObjects();
  }

  void _scheduleOverlayMeasurement() {
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      _syncOverlayMetrics();
    });
  }

  /// Default max height when user does not provide [overlayHeight].
  static const double _defaultMaxHeight = 250.0;

  double _requestedOverlayHeight(bool isLoading) {
    return widget.decoration?.overlayHeight ??
        (isLoading ? 150 : _defaultMaxHeight);
  }

  double calculateMaxHeight(bool isLoading) {
    final double screen = _availableScreenHeight();
    final double userMax = _requestedOverlayHeight(isLoading);
    final double result = (screen > 0 && userMax > screen) ? screen : userMax;
    return result.clamp(0.0, double.infinity);
  }

  /// Physical screen space available above or below the field.
  /// Uses [MediaQuery.viewInsets.bottom] for the REAL keyboard height
  /// instead of a blanket 40% subtraction.
  double _availableScreenHeight() {
    final RenderBox? fb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb == null || !fb.attached) return _requestedOverlayHeight(false);
    final offset = fb.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final double keyboardH = mq.viewInsets.bottom;
    final double usableH = mq.size.height - keyboardH;
    const double safeMargin = 8.0;

    if (displayOverlayBottomNotifier.value) {
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
    if (fb == null || !fb.attached) return;

    final mq = MediaQuery.of(context);
    final double keyboardH = mq.viewInsets.bottom;
    final double usableH = mq.size.height - keyboardH;
    final offset = fb.localToGlobal(Offset.zero);
    final double fieldBottom = offset.dy + fb.size.height;

    final double spaceBelow = usableH - fieldBottom;
    final double spaceAbove = offset.dy;
    // Use the INTENDED max height (not the screen-capped value) so the
    // above/below decision reflects the user's desired dropdown size.
    final double intended = _requestedOverlayHeight(false);

    // Open below if enough space; otherwise open above (like a native select)
    final bool newBottom = spaceBelow >= intended || spaceBelow >= spaceAbove;

    if (newBottom != displayOverlayBottomNotifier.value) {
      displayOverlayBottomNotifier.value = newBottom;
    }
  }

  @override
  void didUpdateWidget(covariant OverlayBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.decoration?.canShowButton !=
        widget.decoration?.canShowButton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleOverlayMeasurement();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    displayOverlayBottomNotifier.dispose();
    fieldHeightNotifier.dispose();
    fieldWidthNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleOverlayMeasurement();
    final RenderBox? fieldRb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fieldRb == null || !fieldRb.attached) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.itemsNotifier,
        widget.focusedIndexNotifier,
        widget.selectedItemsNotifier,
        widget.isApiLoadingNotifier,
        displayOverlayBottomNotifier,
        fieldHeightNotifier,
        fieldWidthNotifier,
      ]),
      builder: (context, child) {
        // Re-check attachment inside the builder callback — the render
        // object may have been detached between the outer build() and
        // this callback (e.g. when a DataTable row is removed).
        final RenderBox? rb =
            widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (rb == null || !rb.attached) return const SizedBox.shrink();

        final currentItems = widget.itemsNotifier.value;
        final isLoading = widget.isApiLoadingNotifier.value;
        final fIndex = widget.focusedIndexNotifier.value;
        final sItems = widget.selectedItemsNotifier.value;

        final double maxH = calculateMaxHeight(isLoading);
        final double w = fieldWidthNotifier.value > 0
            ? fieldWidthNotifier.value
            : fieldRb.size.width;

        return SizedBox.expand(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0.0,
            maxWidth: double.infinity,
            minHeight: 0.0,
            maxHeight: double.infinity,
            child: CompositedTransformFollower(
              link: widget.layerLink,
              showWhenUnlinked: false,
              offset: setOffset(),
              followerAnchor: displayOverlayBottomNotifier.value
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: SizedBox(
                  width: w,
                  child: Card(
                    elevation: widget.decoration?.elevation ?? 0.0,
                    color: Colors.transparent,
                    margin: EdgeInsets.zero,
                    child: Container(
                      key: key1,
                      decoration: menuDecoration(),
                      child: AnimatedSection(
                        expand: true,
                        animationDismissed: widget.controller.hide,
                        axisAlignment:
                            displayOverlayBottomNotifier.value ? 1.0 : -1.0,
                        child: Container(
                          key: key2,
                          width: w,
                          child: isLoading
                              ? loaderWidget(currentItems, isLoading)
                              : currentItems.isEmpty
                                  ? emptyErrorWidget()
                                  : uiListWidget(currentItems, fIndex, sItems),
                        ),
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

  Widget uiListWidget(List<T> currentItems, int fIndex, List<T> sItems) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.decoration?.canShowButton ?? false)
            if (widget.addButton != null)
              SizedBox(
                  key: widget.addButtonKey,
                  child:
                      widget.addButton ?? SizedBox(key: widget.addButtonKey)),
          const SizedBox(height: 2),
          Flexible(
            child: Listener(
              onPointerSignal: (event) {
                // Reuse the timer field — do NOT create a new instance here
                _hoverScrollTimer.run(() {
                  if (!mounted) return;
                  RenderBox? renderBox = widget.itemListKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  if (renderBox != null && !renderBox.attached) return;
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
                      key: fIndex == index ? widget.itemListKey : null,
                      onTap: () => widget.onItemSelected(index),
                      child: Container(
                        padding: widget.decoration?.itemPadding,
                        decoration: selected
                            ? widget.decoration?.focusedItemDecoration
                            : widget.decoration?.unfocusedItemDecoration,
                        child: widget.isMultiSelect
                            ? Row(
                                children: [
                                  // Keep the row as the primary tap target so
                                  // custom indicators and native icons follow
                                  // the same selection path.
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
                                    widget.decoration!.multiSelectCheckBuilder!(
                                        context,
                                        isItemSelected(
                                            index, currentItems, sItems))
                                  else if (widget.isMultiSelect)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Icon(
                                        isItemSelected(
                                                index, currentItems, sItems)
                                            ? (widget.decoration
                                                    ?.multiSelectCheckedIcon ??
                                                Icons.check_box)
                                            : (widget.decoration
                                                    ?.multiSelectUncheckedIcon ??
                                                Icons.check_box_outline_blank),
                                        size: 20,
                                        color: isItemSelected(
                                                index, currentItems, sItems)
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
    );
  }

  bool isItemSelected(int index, List<T> currentItems, List<T> sItems) =>
      sItems.contains(currentItems[index]);

  BoxDecoration menuDecoration() {
    if (widget.decoration?.menuDecoration != null)
      return widget.decoration!.menuDecoration!;
    return BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(5));
  }

  Offset setOffset() {
    final double dx = widget.dropdownOffset?.dx ?? 0;
    if (displayOverlayBottomNotifier.value) {
      // Below: position the overlay starting at the field's bottom edge.
      // Use actual field height so no magic numbers are needed.
      final double dy = widget.dropdownOffset?.dy ?? fieldHeightNotifier.value;
      return Offset(dx, dy);
    } else {
      // Above: followerAnchor=bottomLeft so overlay bottom aligns to
      // the target's origin (field top-left). No dy offset needed.
      return Offset(dx, 0);
    }
  }

  Widget emptyErrorWidget() {
    return Container(
      key: errorButtonKey,
      child: SizedBox(
        height: widget.errorWidgetHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.decoration?.canShowButton ?? false)
              if (widget.addButton != null)
                SizedBox(
                    key: widget.addButtonKey,
                    child:
                        widget.addButton ?? SizedBox(key: widget.addButtonKey)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child:
                  widget.decoration?.errorMessage ?? const Text("No options"),
            ),
          ],
        ),
      ),
    );
  }

  Widget loaderWidget(List<T> currentItems, bool isLoading) {
    return Container(
      alignment: Alignment.center,
      height: 150,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:search_field_dropdown/src/signatures.dart';
import 'package:search_field_dropdown/src/animated_section.dart';
import 'package:search_field_dropdown/src/search_field_dropdown_decoration.dart';

/// Pure visual overlay renderer for [SearchFieldDropdown].
///
/// Handles overlay positioning, dynamic height calculation (avoiding soft keyboards),
/// animated expansion, and performance-isolated row item building via [_DropdownListItemTile].
class OverlayBuilder<T> extends StatefulWidget {
  final Widget? addButton;
  final bool isMultiSelect;
  final GlobalKey fieldKey;
  final LayerLink layerLink;
  final Widget? loaderWidget;
  final GlobalKey itemListKey;
  final Offset? dropdownOffset;
  final GlobalKey addButtonKey;
  final Function(int) changeIndex;
  final Function(T) onItemSelected;
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
  // ===========================================================================
  // OVERLAY METRICS & NOTIFIERS
  // ===========================================================================

  /// Tracks whether dropdown opens below (`true`) or above (`false`) the text field.
  final ValueNotifier<bool> displayOverlayBottomNotifier =
      ValueNotifier<bool>(true);

  final GlobalKey errorButtonKey = GlobalKey();
  final GlobalKey key1 = GlobalKey(), key2 = GlobalKey();

  /// Actual rendered height of the target text field.
  final ValueNotifier<double> fieldHeightNotifier = ValueNotifier<double>(56);

  /// Actual rendered width of the target text field.
  final ValueNotifier<double> fieldWidthNotifier = ValueNotifier<double>(0);

  /// Reusable timer for scroll-hover index tracking — prevents per-event allocations.
  late final SearchTimerMethod _hoverScrollTimer;
  bool _measurementScheduled = false;

  /// Default max overlay height when not overridden in decoration.
  static const double _defaultMaxHeight = 250.0;

  // ===========================================================================
  // LIFECYCLE HOOKS
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hoverScrollTimer = SearchTimerMethod(milliseconds: 300);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncOverlayMetrics();
  }

  @override
  void didChangeMetrics() {
    _scheduleOverlayMeasurement();
  }

  @override
  void didUpdateWidget(covariant OverlayBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleOverlayMeasurement();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    displayOverlayBottomNotifier.dispose();
    fieldHeightNotifier.dispose();
    fieldWidthNotifier.dispose();
    super.dispose();
  }

  // ===========================================================================
  // OVERLAY MEASUREMENT & POSITION CALCULATIONS
  // ===========================================================================

  /// Measures the target field dimensions so follower offset uses exact pixels.
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
    _syncOverlayMetrics();
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      _syncOverlayMetrics();
    });
  }

  double _requestedOverlayHeight(bool isLoading) {
    return widget.decoration?.overlayHeight ??
        (isLoading ? 150 : _defaultMaxHeight);
  }

  /// Determines whether there is sufficient space to open the overlay below the field.
  ///
  /// Takes soft keyboard height (~280px) into account so menu flips upward if necessary.
  bool computeShouldOpenBottom() {
    final RenderBox? fb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb == null || !fb.attached) return true;

    final mq = MediaQuery.of(context);
    final bool isReadOnly = (widget.decoration?.readOnly ?? false) ||
        (widget.decoration?.fieldReadOnly ?? false);

    final double keyboardH = mq.viewInsets.bottom > 0
        ? mq.viewInsets.bottom
        : (isReadOnly ? 0.0 : 280.0);

    final double usableH = mq.size.height - keyboardH;
    final offset = fb.localToGlobal(Offset.zero);
    final double fieldBottom = offset.dy + fb.size.height;

    final double spaceBelow = usableH - fieldBottom;
    final double spaceAbove = offset.dy;
    final double intended = _requestedOverlayHeight(false);

    return spaceBelow >= intended || spaceBelow >= spaceAbove;
  }

  /// Calculates max height allowed for the overlay constrained by screen space.
  double calculateMaxHeight(bool isLoading, bool isBottom) {
    final double screen = _availableScreenHeight(isBottom);
    final double userMax = _requestedOverlayHeight(isLoading);
    final double result = (screen > 0 && userMax > screen) ? screen : userMax;
    return result.clamp(0.0, double.infinity);
  }

  /// Physical screen space available above or below the target field.
  double _availableScreenHeight(bool isBottom) {
    final RenderBox? fb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fb == null || !fb.attached) return _requestedOverlayHeight(false);
    final offset = fb.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final bool isReadOnly = (widget.decoration?.readOnly ?? false) ||
        (widget.decoration?.fieldReadOnly ?? false);
    final double keyboardH = mq.viewInsets.bottom > 0
        ? mq.viewInsets.bottom
        : (isReadOnly ? 0.0 : 280.0);
    final double usableH = mq.size.height - keyboardH;
    const double safeMargin = 8.0;

    final double fieldH = fb.size.height;
    double gap = 0.0;
    if (widget.dropdownOffset != null) {
      final double userDy = widget.dropdownOffset!.dy;
      if (userDy > fieldH) {
        gap = userDy - fieldH;
      } else if (userDy < 0) {
        gap = userDy.abs();
      }
    }

    if (isBottom) {
      final double fieldBottom = offset.dy + fieldH;
      return (usableH - fieldBottom - safeMargin - gap)
          .clamp(0.0, double.infinity);
    } else {
      return (offset.dy - safeMargin - gap).clamp(0.0, double.infinity);
    }
  }

  void checkRenderObjects() {
    if (!mounted) return;
    final bool newBottom = computeShouldOpenBottom();

    if (newBottom != displayOverlayBottomNotifier.value) {
      displayOverlayBottomNotifier.value = newBottom;
    }
  }

  /// Computes target offset for CompositedTransformFollower.
  Offset setOffset(bool isBottom) {
    final double dx = widget.dropdownOffset?.dx ?? 0;
    if (isBottom) {
      final double dy = widget.dropdownOffset?.dy ?? fieldHeightNotifier.value;
      return Offset(dx, dy);
    } else {
      final double fieldH = fieldHeightNotifier.value;
      double dy = 0;
      if (widget.dropdownOffset != null) {
        final double userDy = widget.dropdownOffset!.dy;
        if (userDy >= fieldH) {
          dy = -(userDy - fieldH);
        } else if (userDy < 0) {
          dy = userDy;
        } else if (userDy > 0 && userDy < fieldH) {
          dy = -userDy;
        }
      }
      return Offset(dx, dy);
    }
  }

  BoxDecoration menuDecoration() {
    if (widget.decoration?.menuDecoration != null) {
      return widget.decoration!.menuDecoration!;
    }
    return BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(5));
  }

  // ===========================================================================
  // ROOT OVERLAY BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    _measureField();
    final RenderBox? fieldRb =
        widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fieldRb == null || !fieldRb.attached) return const SizedBox.shrink();

    final bool isBottom = computeShouldOpenBottom();

    // PERFORMANCE OPTIMIZATION: Only merge layout & items notifiers here.
    // focusedIndexNotifier and selectedItemsNotifier are deliberately excluded
    // so arrow keypresses do NOT rebuild the entire overlay shell!
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.itemsNotifier,
        widget.isApiLoadingNotifier,
        displayOverlayBottomNotifier,
        fieldHeightNotifier,
        fieldWidthNotifier,
      ]),
      builder: (context, child) {
        final RenderBox? rb =
            widget.fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (rb == null || !rb.attached) return const SizedBox.shrink();

        final currentItems = widget.itemsNotifier.value;
        final isLoading = widget.isApiLoadingNotifier.value;

        final double maxH = calculateMaxHeight(isLoading, isBottom);
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
              offset: setOffset(isBottom),
              followerAnchor:
                  isBottom ? Alignment.topLeft : Alignment.bottomLeft,
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
                                  : uiListWidget(currentItems),
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

  // ===========================================================================
  // OVERLAY CONTENT BUILDERS
  // ===========================================================================

  Widget uiListWidget(List<T> currentItems) {
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
          if (widget.decoration?.canShowButton ?? false)
            if (widget.addButton != null) const SizedBox(height: 2),
          Flexible(
            child: Listener(
              onPointerSignal: (event) {
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
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListView.builder(
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  padding: widget.decoration?.listPadding ?? EdgeInsets.zero,
                  itemCount: currentItems.length,
                  itemBuilder: (_, index) {
                    return _DropdownListItemTile<T>(
                      index: index,
                      item: currentItems[index],
                      isMultiSelect: widget.isMultiSelect,
                      focusedIndexNotifier: widget.focusedIndexNotifier,
                      selectedItemsNotifier: widget.selectedItemsNotifier,
                      isKeyboardNavigationNotifier:
                          widget.isKeyboardNavigationNotifier,
                      changeIndex: widget.changeIndex,
                      changeKeyBool: widget.changeKeyBool,
                      onItemSelected: widget.onItemSelected,
                      listItemBuilder: widget.listItemBuilder,
                      decoration: widget.decoration,
                      itemListKey: widget.itemListKey,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyErrorWidget() {
    return Container(
      key: errorButtonKey,
      child: SizedBox(
        height: widget.decoration?.errorWidgetHeight ?? 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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

// =============================================================================
// PERFORMANCE ISOLATED ITEM TILE
// =============================================================================

/// Performance-isolated list tile widget for dropdown rows.
///
/// Listens to [focusedIndexNotifier] and [selectedItemsNotifier] locally so that
/// keyboard focus changes or checking a multi-select box only rebuilds the specific
/// affected item tile rather than the whole list or overlay menu.
class _DropdownListItemTile<T> extends StatelessWidget {
  final int index;
  final T item;
  final bool isMultiSelect;
  final ValueNotifier<int> focusedIndexNotifier;
  final ValueNotifier<List<T>> selectedItemsNotifier;
  final ValueNotifier<bool> isKeyboardNavigationNotifier;
  final Function(int) changeIndex;
  final Function(bool) changeKeyBool;
  final Function(T) onItemSelected;
  final ListItemBuilder<T> listItemBuilder;
  final SearchFieldDropdownDecoration? decoration;
  final GlobalKey itemListKey;

  const _DropdownListItemTile({
    super.key,
    required this.index,
    required this.item,
    required this.isMultiSelect,
    required this.focusedIndexNotifier,
    required this.selectedItemsNotifier,
    required this.isKeyboardNavigationNotifier,
    required this.changeIndex,
    required this.changeKeyBool,
    required this.onItemSelected,
    required this.listItemBuilder,
    required this.decoration,
    required this.itemListKey,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusedIndexNotifier,
      builder: (context, fIndex, child) {
        final bool isFocused = fIndex == index;
        return ValueListenableBuilder<List<T>>(
          valueListenable: selectedItemsNotifier,
          builder: (context, sItems, child) {
            final bool isChecked = sItems.contains(item);
            return MouseRegion(
              onHover: (event) {
                if (isKeyboardNavigationNotifier.value) {
                  changeKeyBool(false);
                }
              },
              onEnter: (event) {
                if (!isKeyboardNavigationNotifier.value && fIndex != index) {
                  changeIndex(index);
                }
              },
              child: InkWell(
                key: isFocused ? itemListKey : null,
                onTap: () => onItemSelected(item),
                child: Container(
                  padding: decoration?.itemPadding,
                  decoration: isFocused
                      ? decoration?.focusedItemDecoration
                      : decoration?.unfocusedItemDecoration,
                  child: isMultiSelect
                      ? Row(
                          children: [
                            Expanded(
                              child: listItemBuilder(
                                context,
                                item,
                                isFocused,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(
                                isChecked
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 20,
                                color: isChecked
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        )
                      : listItemBuilder(
                          context,
                          item,
                          isFocused,
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// DEBOUNCE / RATE-LIMIT TIMER HELPER
// =============================================================================

/// Lightweight timer wrapper for debouncing search inputs and rate-limiting scroll hovers.
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

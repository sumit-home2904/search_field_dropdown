import 'package:flutter/material.dart';

/// Smooth fade and size animation wrapper for opening/closing the dropdown overlay menu.
class AnimatedSection extends StatefulWidget {
  /// Controls whether the animation expands (`true`) or collapses (`false`).
  final bool expand;

  /// Child widget wrapped by fade and scale transitions.
  final Widget child;

  /// Axis alignment for scale transition (1.0 for opening downward, -1.0 for opening upward).
  final double axisAlignment;

  /// Callback executed when collapse animation finishes dismissing.
  final VoidCallback animationDismissed;

  const AnimatedSection({
    super.key,
    this.expand = false,
    required this.child,
    required this.axisAlignment,
    required this.animationDismissed,
  });

  @override
  State<AnimatedSection> createState() => AnimatedSectionState();
}

class AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animController;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    runExpand();
  }

  void prepareAnimations() {
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.animationDismissed();
        }
      });

    animation = CurvedAnimation(
      parent: animController,
      curve: Curves.linearToEaseOut,
    );
  }

  void runExpand() {
    if (widget.expand) {
      animController.forward();
    } else {
      animController.reverse();
    }
  }

  @override
  void didUpdateWidget(AnimatedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    runExpand();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        alignment: Alignment(0.0, widget.axisAlignment),
        sizeFactor: animation,
        child: widget.child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A widget that animates its child using a scale transition.
///
/// This widget applies a reverse scale animation to its child when it's built,
/// giving it an animated appearance that starts from a smaller scale and grows.
class AnimatedScrollViewItem extends StatefulWidget {
  const AnimatedScrollViewItem({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<AnimatedScrollViewItem> createState() => _AnimatedScrollViewItemState();
}

class _AnimatedScrollViewItemState extends State<AnimatedScrollViewItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a duration of 300 milliseconds.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward(); // Start the animation immediately upon initialization.

    // Create a reverse scale animation using a Tween and CurvedAnimation for smoothness.
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Ensure the AutomaticKeepAliveClientMixin is satisfied.
    return ScaleTransition(
      scale: _scaleAnimation, // Apply the reverse scale animation to the child.
      child: widget.child, // The child widget that will be animated.
    );
  }

  @override
  bool get wantKeepAlive =>
      false; // Do not keep the state alive when scrolled off-screen.
}

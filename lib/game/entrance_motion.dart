import 'package:flutter/material.dart';

/// Small decorative entrance that leaves the child interactive throughout.
class EntranceMotion extends StatelessWidget {
  const EntranceMotion({
    super.key,
    required this.child,
    this.delayFraction = 0,
  });

  final Widget child;
  final double delayFraction;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Opacity(opacity: 1, child: child);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Interval(
        delayFraction.clamp(0, .8),
        1,
        curve: Curves.easeOutCubic,
      ),
      child: child,
      builder: (context, progress, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - progress)),
        child: Opacity(opacity: .75 + .25 * progress, child: child),
      ),
    );
  }
}

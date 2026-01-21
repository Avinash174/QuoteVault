import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double offset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 375),
    this.offset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Calculate a staggered delay effect by using the value
        // or just rely on the builder running.
        // For true stagger without complex controllers, we can just delay the start?
        // TweenAnimationBuilder starts immediately.
        // We can simulate stagger by modifying the curve or duration based on index,
        // but that might be inconsistent.
        // Simple Slide + Fade is robust.

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

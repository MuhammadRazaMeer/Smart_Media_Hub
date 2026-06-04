import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.color,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Theme.of(context).cardColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

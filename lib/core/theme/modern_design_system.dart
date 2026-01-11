import 'package:flutter/material.dart';

/// Flat Design System - No gradients, shadows, or glassmorphism
/// Clean, minimal, flat UI với borders và màu sắc đơn giản
class ModernDesignSystem {
  // Flat Color Palette - Simple, clean colors
  static const Color primary = Color(0xFF757575); // Grey
  static const Color secondary = Color(0xFF9E9E9E); // Light grey
  static const Color accent = Color(0xFF90A4AE); // Blue grey
  static const Color success = Color(0xFF81C784); // Green
  
  // Neutral tones for backgrounds
  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralMedium = Color(0xFFE0E0E0);
  static const Color neutralDark = Color(0xFF9E9E9E);


  // Flat Card Styles - No shadows, no gradients
  static BoxDecoration modernCardDecoration(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? (isDark ? Colors.grey.shade900 : Colors.white),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // Text Styles
  static TextStyle modernTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        );
  }

  static TextStyle modernSubtitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Colors.grey.shade600,
          letterSpacing: 0,
        );
  }

  static TextStyle modernBody(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          height: 1.5,
        );
  }

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 999.0;
}

/// Helper widget cho flat container
class FlatContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;

  const FlatContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: ModernDesignSystem.modernCardDecoration(context).copyWith(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

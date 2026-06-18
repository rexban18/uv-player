import 'dart:ui';

import 'package:flutter/material.dart';

class GlassColors {
  static Color lightBackground = const Color(0xFFF0F0F5);
  static Color darkBackground = const Color(0xFF0D0D1A);

  static Color glassLight = Colors.white.withOpacity(0.25);
  static Color glassDark = Colors.white.withOpacity(0.08);

  static Color borderLight = Colors.white.withOpacity(0.4);
  static Color borderDark = Colors.white.withOpacity(0.15);

  static Color glowLight = Colors.white.withOpacity(0.3);
  static Color glowDark = Colors.purpleAccent.withOpacity(0.2);
}

class GlassStyle {
  static BoxDecoration glassDecoration({
    required bool isDark,
    Color? accentColor,
    double borderRadius = 20,
    double borderOpacity = 0.3,
  }) {
    final baseColor = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.45);
    final borderColor = isDark
        ? Colors.white.withOpacity(borderOpacity * 0.5)
        : Colors.white.withOpacity(borderOpacity);
    final glowColor = accentColor?.withOpacity(0.15) ??
        (isDark ? Colors.purpleAccent.withOpacity(0.1) : Colors.blue.withOpacity(0.1));

    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: glowColor,
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static ClipRRect glassClip({
    required bool isDark,
    double borderRadius = 20,
    double sigmaX = 15,
    double sigmaY = 15,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

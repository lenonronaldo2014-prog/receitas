import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fontFamily = 'Poppins';

  static TextTheme textTheme(AppColors c) {
    TextStyle s(double size, FontWeight weight, Color color, [double? h]) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: h,
        );

    return TextTheme(
      // Título grande (24–28)
      headlineLarge: s(28, FontWeight.bold, c.textPrimary, 1.2),
      headlineMedium: s(24, FontWeight.bold, c.textPrimary, 1.25),
      headlineSmall: s(22, FontWeight.bold, c.textPrimary, 1.25),
      // Título de seção (18–20)
      titleLarge: s(19, FontWeight.w600, c.textPrimary, 1.3),
      titleMedium: s(16, FontWeight.w600, c.textPrimary, 1.3),
      titleSmall: s(14, FontWeight.w600, c.textPrimary, 1.3),
      // Texto normal (14–16)
      bodyLarge: s(15, FontWeight.normal, c.textPrimary, 1.5),
      bodyMedium: s(14, FontWeight.normal, c.textPrimary, 1.45),
      // Texto secundário (12–14)
      bodySmall: s(12.5, FontWeight.normal, c.textSecondary, 1.4),
      // Botões (14–16)
      labelLarge: s(15, FontWeight.w600, c.textPrimary),
      labelMedium: s(13, FontWeight.w500, c.textSecondary),
      labelSmall: s(11, FontWeight.w500, c.textSecondary),
    );
  }
}

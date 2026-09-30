import 'package:flutter/material.dart';

/// Paleta do app. Fica registrada no ThemeData como extensão, então as telas
/// leem as cores com `context.colors` em vez de usar hex espalhado pelo código.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.backgroundSecondary,
    required this.card,
    required this.cardElevated,
    required this.accent,
    required this.accentSecondary,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.success,
    required this.error,
    required this.shadow,
  });

  final Color background;
  final Color backgroundSecondary;
  final Color card;
  final Color cardElevated;
  final Color accent;
  final Color accentSecondary;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color success;
  final Color error;
  final Color shadow;

  static const defaultAccent = Color(0xFFFFB21C);

  static const dark = AppColors(
    background: Color(0xFF080D14),
    backgroundSecondary: Color(0xFF101722),
    card: Color(0xFF151E2B),
    cardElevated: Color(0xFF1B2635),
    accent: defaultAccent,
    accentSecondary: Color(0xFFFF8A00),
    onAccent: Color(0xFF080D14),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA8B0BC),
    textDisabled: Color(0xFF687384),
    border: Color(0xFF263244),
    success: Color(0xFF35C759),
    error: Color(0xFFFF4D4F),
    shadow: Color(0xFF000000),
  );

  static const light = AppColors(
    background: Color(0xFFF6F7F9),
    backgroundSecondary: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFEEF1F5),
    accent: defaultAccent,
    accentSecondary: Color(0xFFFF8A00),
    onAccent: Color(0xFF080D14),
    textPrimary: Color(0xFF101722),
    textSecondary: Color(0xFF5B6574),
    textDisabled: Color(0xFF8A94A3),
    border: Color(0xFFE1E5EB),
    success: Color(0xFF2EA94D),
    error: Color(0xFFE53935),
    shadow: Color(0xFF1B2635),
  );

  /// Troca a cor de destaque, derivando a secundária e a cor do texto sobre ela.
  AppColors withAccent(Color color) {
    if (color.toARGB32() == defaultAccent.toARGB32()) return this;
    final hsl = HSLColor.fromColor(color);
    return copyWith(
      accent: color,
      accentSecondary: hsl
          .withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0))
          .toColor(),
      onAccent: color.computeLuminance() > 0.35
          ? const Color(0xFF080D14)
          : Colors.white,
    );
  }

  LinearGradient get accentGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentSecondary],
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? card,
    Color? cardElevated,
    Color? accent,
    Color? accentSecondary,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? border,
    Color? success,
    Color? error,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      success: success ?? this.success,
      error: error ?? this.error,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      backgroundSecondary: l(backgroundSecondary, other.backgroundSecondary),
      card: l(card, other.card),
      cardElevated: l(cardElevated, other.cardElevated),
      accent: l(accent, other.accent),
      accentSecondary: l(accentSecondary, other.accentSecondary),
      onAccent: l(onAccent, other.onAccent),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textDisabled: l(textDisabled, other.textDisabled),
      border: l(border, other.border),
      success: l(success, other.success),
      error: l(error, other.error),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

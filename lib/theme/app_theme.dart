import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_spacing.dart';
export 'app_style.dart';
export 'app_typography.dart';

/// ThemeData central do app — todas as telas herdam daqui.
abstract final class AppTheme {
  static ThemeData build(AppColors c, Brightness brightness) {
    final text = AppTypography.textTheme(c);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accentSecondary,
      onSecondary: c.onAccent,
      error: c.error,
      onError: Colors.white,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.backgroundSecondary,
      surfaceContainer: c.card,
      surfaceContainerHigh: c.card,
      surfaceContainerHighest: c.cardElevated,
      outline: c.border,
      outlineVariant: c.border,
      shadow: c.shadow,
    );

    OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: color, width: width),
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: AppRadius.buttonAll,
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 15);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: c.background,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      iconTheme: IconThemeData(color: c.textPrimary),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: c.border.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        hintStyle: text.bodyMedium?.copyWith(color: c.textDisabled),
        labelStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        prefixIconColor: c.textDisabled,
        suffixIconColor: c.textDisabled,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: fieldBorder(c.border),
        enabledBorder: fieldBorder(c.border),
        focusedBorder: fieldBorder(c.accent, 1.4),
        errorBorder: fieldBorder(c.error),
        focusedErrorBorder: fieldBorder(c.error, 1.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.cardElevated,
          disabledForegroundColor: c.textDisabled,
          textStyle: text.labelLarge,
          padding: buttonPadding,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.card,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.border),
          textStyle: text.labelLarge,
          padding: buttonPadding,
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.card,
        selectedColor: c.accent,
        disabledColor: c.card,
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chipAll),
        labelStyle: text.labelMedium?.copyWith(color: c.textPrimary),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: c.onAccent),
        checkmarkColor: c.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.cardElevated,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldAll),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.cardElevated,
        contentTextStyle: text.bodyMedium,
        actionTextColor: c.accent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldAll),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.cardElevated,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : c.textDisabled,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.card,
        ),
        trackOutlineColor: WidgetStatePropertyAll(c.border),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.card,
          foregroundColor: c.textSecondary,
          selectedBackgroundColor: c.accent,
          selectedForegroundColor: c.onAccent,
          side: BorderSide(color: c.border),
          textStyle: text.labelMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldAll),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldAll),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.cardElevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _WithBackground(
            _FadeSlideTransitionsBuilder(),
          ),
          TargetPlatform.iOS: _WithBackground(
            CupertinoPageTransitionsBuilder(),
          ),
          TargetPlatform.windows: _WithBackground(
            _FadeSlideTransitionsBuilder(),
          ),
          TargetPlatform.macOS: _WithBackground(
            CupertinoPageTransitionsBuilder(),
          ),
          TargetPlatform.linux: _WithBackground(_FadeSlideTransitionsBuilder()),
        },
      ),
    );
  }
}

/// Coloca o [AppBackground] atrás de cada tela, dentro da transição —
/// assim cada rota é opaca e as telas não "vazam" uma sobre a outra.
class _WithBackground extends PageTransitionsBuilder {
  const _WithBackground(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => inner.buildTransitions(
    route,
    context,
    animation,
    secondaryAnimation,
    AppBackground(child: child),
  );
}

/// Transição suave: fade + leve deslize para cima.
class _FadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

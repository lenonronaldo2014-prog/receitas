import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Cores de destaque que o usuário pode escolher em Configurações.
const accentOptions = <String, Color>{
  'Dourado': AppColors.defaultAccent,
  'Laranja': Color(0xFFFF8A00),
  'Coral': Color(0xFFFF6B5B),
  'Rosa': Color(0xFFFF6FAE),
  'Lilás': Color(0xFFA78BFA),
  'Azul': Color(0xFF4DA3FF),
  'Turquesa': Color(0xFF2DD4BF),
  'Verde': Color(0xFF35C759),
};

class ThemeController extends ChangeNotifier {
  static const _colorKey = 'theme_accent';
  static const _styleKey = 'theme_style';
  static const _legacyModeKey = 'theme_mode';

  Color _accent = AppColors.defaultAccent;
  AppStyle _style = AppStyle.padrao;

  Color get accent => _accent;
  AppStyle get style => _style;

  ThemeData get theme =>
      AppTheme.build(_style.colors.withAccent(_accent), _style.brightness);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getInt(_colorKey);
    if (color != null) _accent = Color(color);
    final style = prefs.getString(_styleKey);
    if (style != null) {
      _style = AppStyle.fromName(style);
    } else if (prefs.getString(_legacyModeKey) == 'light') {
      // Versões antigas tinham só Escuro/Claro.
      _style = AppStyle.white;
    }
    notifyListeners();
  }

  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.toARGB32());
  }

  Future<void> setStyle(AppStyle style) async {
    _style = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_styleKey, style.name);
  }
}

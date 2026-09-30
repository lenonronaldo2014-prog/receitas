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
  static const _modeKey = 'theme_mode';

  Color _accent = AppColors.defaultAccent;
  ThemeMode _mode = ThemeMode.dark;

  Color get accent => _accent;
  ThemeMode get mode => _mode;

  ThemeData get darkTheme =>
      AppTheme.build(AppColors.dark.withAccent(_accent), Brightness.dark);
  ThemeData get lightTheme =>
      AppTheme.build(AppColors.light.withAccent(_accent), Brightness.light);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getInt(_colorKey);
    if (color != null) _accent = Color(color);
    final mode = prefs.getString(_modeKey);
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => ThemeMode.dark,
    );
    notifyListeners();
  }

  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.toARGB32());
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }
}

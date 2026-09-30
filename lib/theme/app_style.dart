import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos visuais do app (fundo + paleta), escolhidos em Configurações.
enum AppStyle {
  padrao('Padrão', Brightness.dark),
  dark('Dark', Brightness.dark),
  white('White 1', Brightness.light),
  white2('White 2', Brightness.light);

  const AppStyle(this.label, this.brightness);

  final String label;
  final Brightness brightness;

  AppColors get colors => switch (this) {
    padrao => AppColors.dark,
    dark => AppColors.black,
    white => AppColors.light,
    white2 => AppColors.light2,
  };

  static AppStyle fromName(String? name) => AppStyle.values.firstWhere(
    (s) => s.name == name,
    orElse: () => AppStyle.padrao,
  );
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fundo das telas: no tema escuro, a textura com ícones de cozinha;
/// no claro, a cor lisa. Aplicado automaticamente em toda rota pelo tema.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  static const image = AssetImage('assets/images/background.png');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        image: dark
            ? const DecorationImage(
                image: image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            : null,
      ),
      child: child,
    );
  }
}

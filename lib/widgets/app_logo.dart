import 'package:flutter/material.dart';

/// Ícone do app (o mesmo da tela inicial do celular), com cantos arredondados.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  static const image = AssetImage('assets/icon/icon.png');

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.23),
      child: Image(image: image, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

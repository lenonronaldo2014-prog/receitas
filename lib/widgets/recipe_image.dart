import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_theme.dart';

/// Foto da receita (BoxFit.cover). Sem foto, mostra o ícone da categoria.
/// [gradient] escurece a parte de baixo quando há texto por cima.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.borderRadius,
    this.gradient = false,
    this.iconSize = 40,
  });

  final Recipe recipe;
  final BorderRadius? borderRadius;
  final bool gradient;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final path = recipe.imagePath;

    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardElevated, c.card],
        ),
      ),
      child: Center(
        child: Icon(
          recipe.category.icon,
          size: iconSize,
          color: c.accent.withValues(alpha: 0.7),
        ),
      ),
    );

    final image = (path == null || kIsWeb)
        ? placeholder
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );

    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.cardAll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (gradient)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

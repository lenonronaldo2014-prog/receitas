import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';

/// Coração que alterna o favorito com uma pequena animação.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.recipe,
    this.size = 22,
    this.background,
  });

  final Recipe recipe;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fav = recipe.favorite;
    return IconButton(
      tooltip: fav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      style: background == null
          ? null
          : IconButton.styleFrom(backgroundColor: background),
      onPressed: () => context.read<RecipeStore>().toggleFavorite(recipe.id),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: Tween(
            begin: 0.4,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
          child: child,
        ),
        child: Icon(
          fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(fav),
          size: size,
          color: fav ? c.accent : c.textSecondary,
        ),
      ),
    );
  }
}

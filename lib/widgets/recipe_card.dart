import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'pressable.dart';
import 'recipe_image.dart';

/// Card vertical (imagem em cima), usado nas listas horizontais.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, this.onTap});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardAll,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RecipeImage(
                recipe: recipe,
                borderRadius: BorderRadius.circular(AppRadius.card - 4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  Text(recipe.summary, style: text.bodySmall, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card horizontal (imagem à esquerda), usado em Favoritos e resultados.
class RecipeListCard extends StatelessWidget {
  const RecipeListCard({super.key, required this.recipe, this.onTap});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardAll,
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: RecipeImage(
                recipe: recipe,
                iconSize: 30,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${recipe.category.label} • ${recipe.summary}',
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            FavoriteButton(recipe: recipe),
          ],
        ),
      ),
    );
  }
}

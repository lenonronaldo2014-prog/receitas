import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';
import 'recipe_image.dart';

class FeaturedRecipeCard extends StatelessWidget {
  const FeaturedRecipeCard({super.key, required this.recipe, this.onTap});

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardAll,
            boxShadow: [
              BoxShadow(
                color: c.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RecipeImage(recipe: recipe, gradient: true, iconSize: 72),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: AppRadius.chipAll,
                      ),
                      child: Text(
                        'Destaque',
                        style: text.labelSmall?.copyWith(
                          color: c.onAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                recipe.summary,
                                style: text.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

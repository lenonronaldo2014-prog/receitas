import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/favorite_button.dart';
import '../widgets/recipe_image.dart';
import '../widgets/recipe_parts.dart';
import '../widgets/section_title.dart';
import '../widgets/share_recipe_sheet.dart';

enum _MenuAction { edit, share, delete }

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text('"${recipe.title}" será excluída permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.pop(context);
      await context.read<RecipeStore>().delete(recipe.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = context.watch<RecipeStore>().byId(recipeId);
    if (recipe == null) return const Scaffold();

    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final overlay = c.background.withValues(alpha: 0.55);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: c.background,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton(
                tooltip: 'Voltar',
                style: IconButton.styleFrom(backgroundColor: overlay),
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              FavoriteButton(recipe: recipe, background: overlay),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Compartilhar',
                style: IconButton.styleFrom(backgroundColor: overlay),
                icon: const Icon(Icons.share_rounded),
                onPressed: () => ShareRecipeSheet.show(context, recipe),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<_MenuAction>(
                tooltip: 'Mais opções',
                style: IconButton.styleFrom(backgroundColor: overlay),
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (a) => switch (a) {
                  _MenuAction.edit => AppNav.editRecipe(context, recipe),
                  _MenuAction.share => ShareRecipeSheet.show(context, recipe),
                  _MenuAction.delete => _confirmDelete(context, recipe),
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _MenuAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: _MenuAction.share,
                    child: ListTile(
                      leading: Icon(Icons.share_rounded),
                      title: Text('Compartilhar código'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _MenuAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: c.error),
                      title: Text('Excluir', style: TextStyle(color: c.error)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(
                recipe: recipe,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.card * 1.5),
                ),
                iconSize: 96,
              ),
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    recipe.category.label.toUpperCase(),
                    style: t.labelSmall?.copyWith(
                      color: c.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(recipe.title, style: t.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (recipe.prepMinutes != null)
                        MetaItem(
                          icon: Icons.schedule_rounded,
                          label: '${recipe.prepMinutes} min',
                        ),
                      MetaItem(
                        icon: Icons.star_outline_rounded,
                        label: recipe.difficulty.label,
                      ),
                      if (recipe.servings != null)
                        MetaItem(
                          icon: Icons.people_outline_rounded,
                          label: '${recipe.servings} porções',
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionTitle('Ingredientes'),
                  if (recipe.ingredients.isEmpty)
                    Text('Nenhum ingrediente informado.', style: t.bodySmall),
                  for (final ing in recipe.ingredients) RecipeIngredient(ing),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionTitle('Modo de preparo'),
                  if (recipe.steps.isEmpty)
                    Text('Nenhum passo informado.', style: t.bodySmall),
                  for (var i = 0; i < recipe.steps.length; i++)
                    RecipeStep(index: i, text: recipe.steps[i]),
                  if (recipe.notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle('Observações'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: AppRadius.cardAll,
                      ),
                      child: Text(recipe.notes, style: t.bodyMedium),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              SecondaryButton(
                label: 'Editar',
                icon: Icons.edit_outlined,
                expanded: false,
                onPressed: () => AppNav.editRecipe(context, recipe),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: recipe.favorite
                    ? SecondaryButton(
                        label: 'Remover dos favoritos',
                        icon: Icons.favorite_rounded,
                        onPressed: () => context
                            .read<RecipeStore>()
                            .toggleFavorite(recipe.id),
                      )
                    : PrimaryButton(
                        label: 'Adicionar aos favoritos',
                        icon: Icons.favorite_border_rounded,
                        onPressed: () => context
                            .read<RecipeStore>()
                            .toggleFavorite(recipe.id),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

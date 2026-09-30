import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback_widgets.dart';
import '../widgets/recipe_card.dart';

/// Lista genérica de receitas (categoria, sugestão, "ver todas"...).
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key, required this.title, this.where});

  final String title;
  final bool Function(Recipe)? where;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<RecipeStore>().recipes;
    final list = where == null ? all : all.where(where!).toList();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: list.isEmpty
            ? const EmptyState(
                icon: Icons.menu_book_rounded,
                title: 'Nenhuma receita aqui ainda',
                message: 'Toque no + para adicionar uma receita.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.xs,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => RecipeListCard(
                  recipe: list[i],
                  onTap: () => AppNav.recipe(context, list[i]),
                ),
              ),
      ),
    );
  }
}

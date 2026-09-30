import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback_widgets.dart';
import '../widgets/recipe_card.dart';
import '../widgets/tab_header.dart';
import 'search_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<RecipeStore>().favorites;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          TabHeader(
            title: 'Favoritos',
            action: IconButton(
              tooltip: 'Pesquisar',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => AppNav.push(context, const SearchScreen()),
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'Nenhuma favorita ainda',
                    message:
                        'Toque no coração de uma receita para salvá-la aqui.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.xl,
                    ),
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => RecipeListCard(
                      key: ValueKey(favorites[i].id),
                      recipe: favorites[i],
                      onTap: () => AppNav.recipe(context, favorites[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

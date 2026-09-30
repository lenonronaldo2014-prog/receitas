import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/tab_header.dart';
import 'search_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: 'Categorias',
              action: IconButton(
                tooltip: 'Pesquisar',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => AppNav.push(context, const SearchScreen()),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 140,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
              ),
              itemCount: RecipeCategory.values.length,
              itemBuilder: (_, i) {
                final c = RecipeCategory.values[i];
                return CategoryCard(
                  category: c,
                  count: store.countIn(c),
                  onTap: () => AppNav.category(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

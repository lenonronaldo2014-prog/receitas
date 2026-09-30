import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../providers/user_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/category_card.dart';
import '../widgets/featured_recipe_card.dart';
import '../widgets/feedback_widgets.dart';
import '../widgets/recipe_card.dart';
import '../widgets/section_title.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();
    final name = context.watch<UserData>().firstName;
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Olá!' : 'Olá, $name!',
                      style: t.headlineMedium,
                    ),
                    Text(
                      'Desenvolvido para o uso da Anna ❤️',
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Notificações',
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nenhuma notificação por aqui.'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSearchBar(onTap: () => AppNav.push(context, const SearchScreen())),
          const SizedBox(height: AppSpacing.xl),
          if (!store.loaded)
            const _HomeSkeleton()
          else if (store.recipes.isEmpty)
            EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'Nenhuma receita ainda',
              message:
                  'Salve sua primeira receita de bolo, salgado ou o que quiser!',
              action: Column(
                children: [
                  PrimaryButton(
                    label: 'Criar receita',
                    icon: Icons.add_rounded,
                    onPressed: () => AppNav.newRecipe(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'Adicionar por código',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: () => AppNav.importRecipe(context),
                  ),
                ],
              ),
            )
          else ...[
            FeaturedRecipeCard(
              recipe: store.featured!,
              onTap: () => AppNav.recipe(context, store.featured!),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionTitle(
              'Receitas Recentes',
              actionLabel: 'Ver todas',
              onAction: () => AppNav.list(context, title: 'Todas as receitas'),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: store.recent.take(10).length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final r = store.recent[i];
                  return SizedBox(
                    width: 150,
                    child: RecipeCard(
                      recipe: r,
                      onTap: () => AppNav.recipe(context, r),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle('Suas categorias'),
            _UsedCategories(store: store),
          ],
        ],
      ),
    );
  }
}

/// Mostra só as categorias que já têm receitas.
class _UsedCategories extends StatelessWidget {
  const _UsedCategories({required this.store});

  final RecipeStore store;

  @override
  Widget build(BuildContext context) {
    final used = {for (final r in store.recipes) r.category}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: used.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => SizedBox(
          width: 120,
          child: CategoryCard(
            category: used[i],
            count: store.countIn(used[i]),
            onTap: () => AppNav.category(context, used[i]),
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(aspectRatio: 16 / 10, child: Skeleton()),
        const SizedBox(height: AppSpacing.xl),
        const Skeleton(width: 180, height: 22, radius: 8),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                const SizedBox(width: 150, child: Skeleton()),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

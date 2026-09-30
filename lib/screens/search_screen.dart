import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../providers/user_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/feedback_widgets.dart';
import '../widgets/menu_tile.dart';
import '../widgets/recipe_card.dart';
import '../widgets/section_title.dart';

class _Suggestion {
  const _Suggestion(this.label, this.icon, this.where);

  final String label;
  final IconData icon;
  final bool Function(Recipe) where;
}

final _suggestions = [
  _Suggestion(
    'Receitas rápidas',
    Icons.bolt_rounded,
    (r) => r.prepMinutes != null && r.prepMinutes! <= 30,
  ),
  _Suggestion(
    'Receitas fáceis',
    Icons.thumb_up_alt_outlined,
    (r) => r.difficulty == Difficulty.facil,
  ),
  _Suggestion(
    'Receitas vegetarianas',
    RecipeCategory.vegetariana.icon,
    (r) => r.category == RecipeCategory.vegetariana,
  ),
  _Suggestion(
    'Receitas com carne',
    RecipeCategory.carne.icon,
    (r) => r.category == RecipeCategory.carne,
  ),
  _Suggestion(
    'Bolos',
    RecipeCategory.bolo.icon,
    (r) => r.category == RecipeCategory.bolo,
  ),
  _Suggestion(
    'Sobremesas',
    RecipeCategory.sobremesa.icon,
    (r) => r.category == RecipeCategory.sobremesa,
  ),
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
    context.read<UserData>().addSearch(term);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();
    final user = context.watch<UserData>();
    final results = store.recipes.where((r) => r.matches(_query)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xs,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: AppSearchBar(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: _search,
                onClear: () => setState(() => _query = ''),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? _idle(user)
                  : results.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nenhuma receita encontrada',
                      message: 'Tente buscar por outro nome ou ingrediente.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        AppSpacing.xl,
                      ),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => RecipeListCard(
                        recipe: results[i],
                        onTap: () {
                          user.addSearch(_query);
                          AppNav.recipe(context, results[i]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _idle(UserData user) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      children: [
        if (user.recentSearches.isNotEmpty) ...[
          SectionTitle(
            'Buscas recentes',
            actionLabel: 'Limpar',
            onAction: user.clearSearches,
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in user.recentSearches)
                ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(s),
                  onPressed: () => _search(s),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        const SectionTitle('Sugestões'),
        for (final s in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: MenuTile(
              icon: s.icon,
              title: s.label,
              onTap: () => AppNav.list(context, title: s.label, where: s.where),
            ),
          ),
      ],
    );
  }
}

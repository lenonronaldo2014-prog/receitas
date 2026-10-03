import 'package:flutter/material.dart';

import 'models/recipe.dart';
import 'screens/import_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipe_form_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/scan_recipe_screen.dart';

/// Atalhos de navegação usados por várias telas.
abstract final class AppNav {
  static Future<void> push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  static Future<void> recipe(BuildContext context, Recipe recipe) =>
      push(context, RecipeDetailScreen(recipeId: recipe.id));

  static Future<void> newRecipe(BuildContext context) =>
      push(context, const RecipeFormScreen());

  static Future<void> importRecipe(BuildContext context) =>
      push(context, const ImportRecipeScreen());

  /// Menu do botão "+": criar do zero ou adicionar por código.
  static Future<void> addMenu(BuildContext context) async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adicionar receita', style: t.titleLarge),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('Criar receita'),
                  subtitle: const Text('Escrever uma receita nova'),
                  onTap: () => Navigator.pop(ctx, 0),
                ),
                ListTile(
                  leading: const Icon(Icons.document_scanner_outlined),
                  title: const Text('Escanear receita'),
                  subtitle: const Text('Ler uma receita de uma foto'),
                  onTap: () => Navigator.pop(ctx, 2),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_2_rounded),
                  title: const Text('Adicionar por código'),
                  subtitle: const Text(
                    'Colar o código que alguém compartilhou',
                  ),
                  onTap: () => Navigator.pop(ctx, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!context.mounted) return;
    switch (choice) {
      case 0:
        await newRecipe(context);
      case 1:
        await importRecipe(context);
      case 2:
        await push(context, const ScanRecipeScreen());
    }
  }

  static Future<void> editRecipe(BuildContext context, Recipe recipe) =>
      push(context, RecipeFormScreen(recipe: recipe));

  static Future<void> list(
    BuildContext context, {
    required String title,
    bool Function(Recipe)? where,
  }) => push(context, RecipeListScreen(title: title, where: where));

  static Future<void> category(BuildContext context, RecipeCategory c) =>
      list(context, title: c.label, where: (r) => r.category == c);
}

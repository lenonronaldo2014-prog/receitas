import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../providers/recipe_store.dart';
import '../providers/user_data.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/menu_tile.dart';
import '../widgets/tab_header.dart';
import 'main_shell.dart';
import 'settings_screen.dart';
import 'shopping_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, UserData user) async {
    final name = TextEditingController(text: user.name);
    final email = TextEditingController(text: user.email);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Seu nome'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Seu e-mail'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok == true) await user.setProfile(name.text, email.text);
    name.dispose();
    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserData>();
    final store = context.watch<RecipeStore>();
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    String count(int n) => n == 1 ? '1 receita' : '$n receitas';

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: 'Perfil',
              action: IconButton(
                tooltip: 'Configurações',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => AppNav.push(context, const SettingsScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  InkWell(
                    borderRadius: AppRadius.cardAll,
                    onTap: () => _editProfile(context, user),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: c.cardElevated,
                            child: initials.isEmpty
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 34,
                                    color: c.textSecondary,
                                  )
                                : Text(
                                    initials,
                                    style: t.titleLarge?.copyWith(
                                      color: c.accent,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.isEmpty
                                      ? 'Toque para definir seu nome'
                                      : user.name,
                                  style: t.titleMedium,
                                ),
                                if (user.email.isNotEmpty)
                                  Text(user.email, style: t.bodySmall),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: c.textDisabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  MenuTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Minhas Receitas',
                    subtitle: count(store.recipes.length),
                    onTap: () => AppNav.list(context, title: 'Minhas Receitas'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MenuTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favoritos',
                    subtitle: count(store.favorites.length),
                    onTap: () => MainShell.goTo(context, MainShell.favorites),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MenuTile(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Lista de Compras',
                    subtitle: user.shopping.isEmpty
                        ? null
                        : '${user.shopping.length} itens',
                    onTap: () =>
                        AppNav.push(context, const ShoppingListScreen()),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MenuTile(
                    icon: Icons.palette_outlined,
                    title: 'Configurações',
                    subtitle: 'Cores e tema',
                    onTap: () => AppNav.push(context, const SettingsScreen()),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Sobre o app',
                    onTap: () async {
                      final version = await UpdateService.currentVersion();
                      if (!context.mounted) return;
                      showAboutDialog(
                        context: context,
                        applicationName: 'Receitas da Anna',
                        applicationVersion: version,
                        applicationIcon: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: c.accentGradient,
                            borderRadius: BorderRadius.circular(
                              AppRadius.button,
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: c.onAccent,
                          ),
                        ),
                        children: const [
                          Text(
                            'Guarde todas as suas receitas favoritas em um só lugar.',
                          ),
                          SizedBox(height: 8),
                          Text(UpdateService.repoUrl),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverFillRemaining(hasScrollBody: false, child: AppFooter()),
        ],
      ),
    );
  }
}

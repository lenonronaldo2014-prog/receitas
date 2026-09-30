import 'package:flutter/material.dart';

import '../navigation.dart';
import '../widgets/app_bottom_navigation.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Estrutura principal com a barra de navegação inferior.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Permite que uma aba troque para outra (ex: Perfil → Favoritos).
  static void goTo(BuildContext context, int index) =>
      context.findAncestorStateOfType<_MainShellState>()?._select(index);

  static const home = 0, categories = 1, favorites = 2, profile = 3;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = [
    AppNavItem(Icons.home_outlined, Icons.home_rounded, 'Início'),
    AppNavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categorias'),
    AppNavItem(
      Icons.favorite_border_rounded,
      Icons.favorite_rounded,
      'Favoritos',
    ),
    AppNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  static const _pages = [
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
      bottomNavigationBar: AppBottomNavigation(
        items: _items,
        currentIndex: _index,
        onSelect: _select,
        onAdd: () => AppNav.addMenu(context),
      ),
    );
  }
}

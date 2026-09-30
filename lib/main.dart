import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/recipe_store.dart';
import 'providers/theme_controller.dart';
import 'providers/user_data.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => RecipeStore()),
        ChangeNotifierProvider(create: (_) => UserData()),
      ],
      child: const ReceitasApp(),
    ),
  );
}

class ReceitasApp extends StatelessWidget {
  const ReceitasApp({super.key, this.home = const SplashScreen()});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp(
      title: 'Receitas da Anna',
      debugShowCheckedModeBanner: false,
      theme: theme.theme,
      home: home,
    );
  }
}

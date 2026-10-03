import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_controller.dart';
import 'providers/recipe_store.dart';
import 'providers/theme_controller.dart';
import 'providers/user_data.dart';
import 'services/recipe_scanner.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider<AuthController>(
          create: (_) => FirebaseAuthController(),
        ),
        ChangeNotifierProvider(create: (_) => RecipeStore()),
        ChangeNotifierProvider(create: (_) => UserData()),
        Provider<RecipeScanner>(create: (_) => GeminiRecipeScanner()),
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

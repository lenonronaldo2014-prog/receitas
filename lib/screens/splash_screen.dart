import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_store.dart';
import '../providers/theme_controller.dart';
import '../providers/user_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import 'main_shell.dart';

/// Abertura do app: carrega os dados salvos e vai para a tela principal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AppLogo.image, context);
    // Carrega as imagens de fundo antes de abrir as telas.
    for (final style in AppStyle.values) {
      precacheImage(AssetImage(style.colors.backgroundImage!), context);
    }
  }

  Future<void> _start() async {
    await Future.wait([
      context.read<ThemeController>().load(),
      context.read<RecipeStore>().load(),
      context.read<UserData>().load(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const AppBackground(child: MainShell()),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: const AppLogo(size: 120),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Receitas', style: t.headlineLarge?.copyWith(fontSize: 38)),
              Text(
                'da Anna',
                style: t.headlineSmall?.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Mais sabor no seu dia',
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl * 2),
              SizedBox(
                width: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(minHeight: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

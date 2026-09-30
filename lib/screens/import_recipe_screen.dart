import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';
import '../screens/recipe_detail_screen.dart';
import '../services/recipe_share.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/recipe_parts.dart';

/// Adiciona uma receita a partir de um código compartilhado.
class ImportRecipeScreen extends StatefulWidget {
  const ImportRecipeScreen({super.key});

  @override
  State<ImportRecipeScreen> createState() => _ImportRecipeScreenState();
}

class _ImportRecipeScreenState extends State<ImportRecipeScreen> {
  final _controller = TextEditingController();
  Recipe? _preview;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse(String text) =>
      setState(() => _preview = RecipeShare.decode(text));

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    _controller.text = text;
    _parse(text);
  }

  Future<void> _import() async {
    final recipe = _preview!;
    await context.read<RecipeStore>().upsert(recipe);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${recipe.title}" adicionada!')));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final hasText = _controller.text.trim().isNotEmpty;
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar por código')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          children: [
            Text(
              'Cole aqui o código (ou a mensagem inteira) que recebeu de outra pessoa.',
              style: t.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 8,
              onChanged: _parse,
              style: t.bodySmall?.copyWith(color: c.textPrimary),
              decoration: const InputDecoration(hintText: 'RDA1-...'),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Colar da área de transferência',
              icon: Icons.content_paste_rounded,
              onPressed: _paste,
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: preview != null
                  ? _Preview(key: ValueKey(preview.id), recipe: preview)
                  : hasText
                  ? Row(
                      key: const ValueKey('error'),
                      children: [
                        Icon(Icons.error_outline_rounded, color: c.error),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Código inválido. Confira se copiou ele inteiro.',
                            style: t.bodyMedium?.copyWith(color: c.error),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: 'Adicionar receita',
            icon: Icons.download_rounded,
            onPressed: preview == null ? null : _import,
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: c.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: c.success, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text('Receita encontrada', style: t.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fieldAll,
                ),
                child: Icon(recipe.category.icon, color: c.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: t.titleMedium),
                    Text(
                      '${recipe.category.label} • ${recipe.summary}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              MetaItem(
                icon: Icons.format_list_bulleted_rounded,
                label: '${recipe.ingredients.length} ingredientes',
              ),
              MetaItem(
                icon: Icons.format_list_numbered_rounded,
                label: '${recipe.steps.length} passos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/recipe.dart';
import '../services/recipe_share.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Painel que gera o código da receita e permite enviar ou copiar.
class ShareRecipeSheet extends StatelessWidget {
  const ShareRecipeSheet({super.key, required this.recipe});

  final Recipe recipe;

  static Future<void> show(BuildContext context, Recipe recipe) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ShareRecipeSheet(recipe: recipe),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final code = RecipeShare.encode(recipe);
    final message = RecipeShare.message(recipe);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compartilhar receita', style: t.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Envie o código para outra pessoa. Ela adiciona pelo botão + → '
              '"Adicionar por código". A foto não vai junto.',
              style: t.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: AppRadius.fieldAll,
                border: Border.all(color: c.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  code,
                  style: t.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Builder(
              builder: (ctx) => PrimaryButton(
                label: 'Compartilhar',
                icon: Icons.share_rounded,
                onPressed: () {
                  final box = ctx.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text: message,
                      subject: 'Receita: ${recipe.title}',
                      sharePositionOrigin: box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Copiar código',
              icon: Icons.copy_rounded,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

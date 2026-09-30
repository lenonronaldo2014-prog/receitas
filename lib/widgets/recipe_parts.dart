import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Linha de ingrediente com marcador.
class RecipeIngredient extends StatelessWidget {
  const RecipeIngredient(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: AppSpacing.sm),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Passo do modo de preparo, com número "01", "02"...
class RecipeStep extends StatelessWidget {
  const RecipeStep({super.key, required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              (index + 1).toString().padLeft(2, '0'),
              style: t.labelMedium?.copyWith(
                color: c.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: t.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícone + texto (ex: "⏱ 30 min").
class MetaItem extends StatelessWidget {
  const MetaItem({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c.accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

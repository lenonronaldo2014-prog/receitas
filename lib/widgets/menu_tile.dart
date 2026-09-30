import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

/// Item de menu: ícone, texto (e subtítulo opcional) e seta.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardAll,
        ),
        child: Row(
          children: [
            Icon(icon, color: c.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyMedium),
                  if (subtitle != null) Text(subtitle!, style: t.bodySmall),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: c.textDisabled),
          ],
        ),
      ),
    );
  }
}

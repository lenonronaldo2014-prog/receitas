import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          children: [
            const SectionTitle('Estilo'),
            Row(
              children: [
                for (final (i, style) in AppStyle.values.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StyleOption(
                      style: style,
                      selected: theme.style == style,
                      onTap: () => theme.setStyle(style),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Cor de destaque'),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final e in accentOptions.entries)
                  _ColorOption(
                    name: e.key,
                    color: e.value,
                    selected: theme.accent.toARGB32() == e.value.toARGB32(),
                    onTap: () => theme.setAccent(e.value),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle('Pré-visualização'),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: AppRadius.cardAll,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Botão principal',
                    icon: Icons.favorite_border_rounded,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(label: 'Botão secundário', onPressed: () {}),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(
                    decoration: InputDecoration(hintText: 'Campo de texto'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fieldAll,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? c.textPrimary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: color.computeLuminance() > 0.35
                            ? AppColors.dark.background
                            : Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniatura de um estilo: o fundo real + o nome.
class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final preview = style.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Estilo ${style.label}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.field + 3),
                border: Border.all(
                  color: selected ? c.accent : c.border,
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.fieldAll,
                child: AspectRatio(
                  aspectRatio: 9 / 20,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        preview.backgroundImage!,
                        fit: BoxFit.cover,
                        cacheWidth: 240,
                      ),
                      // Mini "card" para dar ideia do contraste.
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.62,
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: preview.card,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: preview.border),
                            ),
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: c.accent,
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: c.onAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              style.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelMedium?.copyWith(
                color: selected ? c.textPrimary : c.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

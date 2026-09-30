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
            const SectionTitle('Modo'),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Escuro'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_outlined),
                  label: Text('Sistema'),
                ),
              ],
              selected: {theme.mode},
              onSelectionChanged: (s) => theme.setMode(s.first),
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

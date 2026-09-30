import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cabeçalho das abas principais: título grande + ação à direita.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

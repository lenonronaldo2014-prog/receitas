import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Campo de busca. Com [onTap] e sem [controller], funciona como "botão"
/// que abre a tela de pesquisa.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final readOnly = onTap != null;
    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Buscar receitas...',
        prefixIcon: const Icon(Icons.search_rounded),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: controller == null || readOnly
            ? null
            : ValueListenableBuilder(
                valueListenable: controller!,
                builder: (_, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Limpar',
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: context.colors.textDisabled,
                        ),
                        onPressed: () {
                          controller!.clear();
                          onClear?.call();
                        },
                      ),
              ),
      ),
    );
  }
}

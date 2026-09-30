import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/update_service.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Rodapé do Perfil: nome do app, versão e botão de buscar atualização.
class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  String _version = '';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    UpdateService.currentVersion().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final update = await UpdateService.check();
      if (!mounted) return;
      if (update == null) {
        _snack('Você já está na versão mais recente 🎉');
      } else {
        await _showUpdate(update);
      }
    } on UpdateException catch (e) {
      if (mounted) _snack('Não foi possível verificar: ${e.message}');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _showUpdate(AppUpdate update) async {
    final download = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nova versão ${update.version}'),
        content: SingleChildScrollView(
          child: Text(
            update.notes.isEmpty
                ? 'Há uma versão nova do app disponível.'
                : update.notes,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Depois'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
    if (download != true) return;
    final ok = await launchUrl(
      Uri.parse(update.downloadUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) _snack('Não foi possível abrir o link de download.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xl,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: c.accentGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: c.onAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              text: 'Receitas ',
              children: [
                TextSpan(
                  text: 'da Anna',
                  style: TextStyle(color: c.accent),
                ),
              ],
            ),
            style: t.headlineSmall,
          ),
          if (_version.isNotEmpty) Text('Versão $_version', style: t.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: _checking ? 'Verificando...' : 'Buscar atualização',
            icon: Icons.system_update_rounded,
            onPressed: _checking ? null : _check,
          ),
        ],
      ),
    );
  }
}

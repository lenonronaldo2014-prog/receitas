import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/recipe_scanner.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import 'recipe_form_screen.dart';

/// Tira/escolhe fotos de uma receita e preenche "Nova Receita" com o que leu.
class ScanRecipeScreen extends StatefulWidget {
  const ScanRecipeScreen({super.key});

  static const maxPages = 4;

  @override
  State<ScanRecipeScreen> createState() => _ScanRecipeScreenState();
}

class _ScanRecipeScreenState extends State<ScanRecipeScreen> {
  final _pages = <Uint8List>[];
  bool _reading = false;

  static bool get _cameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _add(ImageSource source) async {
    final left = ScanRecipeScreen.maxPages - _pages.length;
    if (left <= 0) return;
    try {
      // Boa resolução para o texto ficar legível.
      final picker = ImagePicker();
      final files = source == ImageSource.camera
          ? [
              ?await picker.pickImage(
                source: source,
                maxWidth: 1800,
                imageQuality: 85,
              ),
            ]
          : await picker.pickMultiImage(
              maxWidth: 1800,
              imageQuality: 85,
              limit: left > 1 ? left : null,
            );
      final bytes = [for (final f in files.take(left)) await f.readAsBytes()];
      if (mounted) setState(() => _pages.addAll(bytes));
    } catch (_) {
      if (mounted) _snack('Não foi possível abrir as fotos.');
    }
  }

  Future<void> _read() async {
    setState(() => _reading = true);
    try {
      final draft = await context.read<RecipeScanner>().scan(_pages);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RecipeFormScreen(draft: draft)),
      );
    } on ScanException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final canAdd = _pages.length < ScanRecipeScreen.maxPages && !_reading;

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear receita')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: AppRadius.cardAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: c.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Fotografe a receita (livro, caderno ou print). '
                      'Vou separar o nome, os ingredientes e o modo de '
                      'preparo para você conferir e salvar.\n\n'
                      'Se a receita ocupa mais de uma página, adicione '
                      'até ${ScanRecipeScreen.maxPages} fotos.',
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_pages.isNotEmpty) ...[
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pages.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => _PageThumb(
                    bytes: _pages[i],
                    label: 'Foto ${i + 1}',
                    onRemove: _reading
                        ? null
                        : () => setState(() => _pages.removeAt(i)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_cameraSupported) ...[
              SecondaryButton(
                label: _pages.isEmpty ? 'Tirar foto' : 'Tirar outra foto',
                icon: Icons.photo_camera_outlined,
                onPressed: canAdd ? () => _add(ImageSource.camera) : null,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SecondaryButton(
              label: 'Escolher da galeria',
              icon: Icons.photo_library_outlined,
              onPressed: canAdd ? () => _add(ImageSource.gallery) : null,
            ),
            if (_reading) ...[
              const SizedBox(height: AppSpacing.xl),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Lendo a receita... isso leva alguns segundos.',
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
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
            label: 'Ler receita',
            icon: Icons.auto_awesome_rounded,
            loading: _reading,
            onPressed: _pages.isEmpty ? null : _read,
          ),
        ),
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  const _PageThumb({required this.bytes, required this.label, this.onRemove});

  final Uint8List bytes;
  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 400),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: AppRadius.chipAll,
                ),
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: 'Remover foto',
                  style: IconButton.styleFrom(
                    backgroundColor: c.background.withValues(alpha: 0.7),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onRemove,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

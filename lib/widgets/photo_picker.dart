import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

/// Resultado de [pickPhoto].
sealed class PhotoPick {
  const PhotoPick();
}

class PhotoPicked extends PhotoPick {
  const PhotoPicked(this.file);

  final XFile file;
}

class PhotoRemoved extends PhotoPick {
  const PhotoRemoved();
}

/// Fotos só funcionam fora da Web (são salvas como arquivo no aparelho).
bool get photosSupported => !kIsWeb;

bool get _cameraSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Mostra as opções Câmera / Galeria / Remover. Retorna null se cancelar.
Future<PhotoPick?> pickPhoto(
  BuildContext context, {
  required bool hasPhoto,
  double maxWidth = 1600,
  int quality = 85,
}) async {
  final source = await showModalBottomSheet<Object>(
    context: context,
    builder: (ctx) {
      final c = ctx.colors;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_cameraSupported)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline, color: c.error),
                title: Text('Remover foto', style: TextStyle(color: c.error)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      );
    },
  );
  if (source == null) return null;
  if (source == 'remove') return const PhotoRemoved();
  try {
    final file = await ImagePicker().pickImage(
      source: source as ImageSource,
      maxWidth: maxWidth,
      imageQuality: quality,
    );
    return file == null ? null : PhotoPicked(file);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir as fotos.')),
      );
    }
    return null;
  }
}

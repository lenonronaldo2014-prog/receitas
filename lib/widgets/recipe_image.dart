import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';

/// Foto da receita (BoxFit.cover). Sem foto, mostra o ícone da categoria.
/// [gradient] escurece a parte de baixo quando há texto por cima.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.borderRadius,
    this.gradient = false,
    this.iconSize = 40,
  });

  final Recipe recipe;
  final BorderRadius? borderRadius;
  final bool gradient;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardElevated, c.card],
        ),
      ),
      child: Center(
        child: Icon(
          recipe.category.icon,
          size: iconSize,
          color: c.accent.withValues(alpha: 0.7),
        ),
      ),
    );

    final photoId = recipe.photoId;
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.cardAll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoId == null || kIsWeb)
            placeholder
          else
            CloudPhoto(photoId: photoId, placeholder: placeholder),
          if (gradient)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Foto salva na conta: usa a cópia do aparelho ou baixa da nuvem.
class CloudPhoto extends StatefulWidget {
  const CloudPhoto({
    super.key,
    required this.photoId,
    required this.placeholder,
  });

  final String photoId;
  final Widget placeholder;

  @override
  State<CloudPhoto> createState() => _CloudPhotoState();
}

class _CloudPhotoState extends State<CloudPhoto> {
  late Future<File?> _file;

  @override
  void initState() {
    super.initState();
    _file = context.read<RecipeStore>().photoFile(widget.photoId);
  }

  @override
  void didUpdateWidget(CloudPhoto old) {
    super.didUpdateWidget(old);
    if (old.photoId != widget.photoId) {
      _file = context.read<RecipeStore>().photoFile(widget.photoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _file,
      builder: (_, snap) {
        final f = snap.data;
        if (f == null) return widget.placeholder;
        return Image.file(
          f,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => widget.placeholder,
        );
      },
    );
  }
}

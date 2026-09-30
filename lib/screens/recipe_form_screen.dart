import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/photo_picker.dart';
import '../widgets/recipe_image.dart';

/// Tela usada tanto para criar quanto para editar uma receita.
class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _prep;
  late final TextEditingController _servings;
  late final TextEditingController _steps;
  late final TextEditingController _notes;
  late final List<TextEditingController> _ingredients;
  RecipeCategory? _category;
  late Difficulty _difficulty;

  /// Foto: a já salva, uma nova escolhida agora, ou removida.
  String? _photoId;
  XFile? _newImage;
  bool _saving = false;
  int? _focusIngredient;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _title = TextEditingController(text: r?.title);
    _prep = TextEditingController(text: r?.prepMinutes?.toString());
    _servings = TextEditingController(text: r?.servings?.toString());
    _steps = TextEditingController(text: r?.steps.join('\n'));
    _notes = TextEditingController(text: r?.notes);
    _category = r?.category;
    _difficulty = r?.difficulty ?? Difficulty.facil;
    _photoId = r?.photoId;
    _ingredients = [
      for (final i in r?.ingredients ?? const <String>[])
        TextEditingController(text: i),
    ];
    if (_ingredients.isEmpty) _ingredients.add(TextEditingController());
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _prep,
      _servings,
      _steps,
      _notes,
      ..._ingredients,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pick = await pickPhoto(
      context,
      hasPhoto: _newImage != null || _photoId != null,
      // Menor e mais comprimida: a foto vai para a nuvem.
      maxWidth: 1080,
      quality: 70,
    );
    if (pick == null || !mounted) return;
    setState(() {
      switch (pick) {
        case PhotoPicked(:final file):
          _newImage = file;
        case PhotoRemoved():
          _newImage = null;
          _photoId = null;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final store = context.read<RecipeStore>();
    final now = DateTime.now();
    final base = widget.recipe;

    String? photoId = _photoId;
    if (_newImage != null) {
      try {
        photoId = await store.savePhoto(await _newImage!.readAsBytes());
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PhotoTooLargeException
                  ? 'Foto muito grande. Escolha outra.'
                  : 'Não foi possível salvar a foto.',
            ),
          ),
        );
        return;
      }
    }

    final recipe = Recipe(
      id: base?.id ?? RecipeStore.newId(),
      title: _title.text.trim(),
      category: _category!,
      difficulty: _difficulty,
      ingredients: _ingredients
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      steps: _steps.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      prepMinutes: int.tryParse(_prep.text.trim()),
      servings: int.tryParse(_servings.text.trim()),
      notes: _notes.text.trim(),
      photoId: photoId,
      favorite: base?.favorite ?? false,
      createdAt: base?.createdAt ?? now,
      updatedAt: now,
    );
    await store.upsert(recipe);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Alterações salvas!' : 'Receita criada!'),
      ),
    );
    Navigator.pop(context);
  }

  String? _optionalNumber(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? 'Número inválido' : null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: t.labelMedium),
    );

    const gap = SizedBox(height: AppSpacing.lg);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xs,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            children: [
              if (photosSupported) ...[_photoPicker(c, t), gap],
              label('Nome da receita'),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ex: Bolo de cenoura',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              gap,
              label('Categoria'),
              DropdownButtonFormField<RecipeCategory>(
                initialValue: _category,
                isExpanded: true,
                hint: const Text('Selecione uma categoria'),
                dropdownColor: c.cardElevated,
                borderRadius: AppRadius.fieldAll,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final cat in RecipeCategory.values)
                    DropdownMenuItem(
                      value: cat,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 20, color: c.accent),
                          const SizedBox(width: AppSpacing.sm),
                          Text(cat.label, style: t.bodyMedium),
                        ],
                      ),
                    ),
                ],
                validator: (v) => v == null ? 'Escolha uma categoria' : null,
                onChanged: (v) => setState(() => _category = v),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('Tempo de preparo'),
                        TextFormField(
                          controller: _prep,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Ex: 30',
                            suffixText: 'min',
                          ),
                          validator: _optionalNumber,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('Porções'),
                        TextFormField(
                          controller: _servings,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Ex: 4'),
                          validator: _optionalNumber,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              gap,
              label('Dificuldade'),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final d in Difficulty.values)
                    ChoiceChip(
                      label: Text(d.label),
                      selected: _difficulty == d,
                      showCheckmark: false,
                      labelStyle: t.labelMedium?.copyWith(
                        color: _difficulty == d ? c.onAccent : c.textPrimary,
                      ),
                      onSelected: (_) => setState(() => _difficulty = d),
                    ),
                ],
              ),
              gap,
              label('Ingredientes'),
              for (var i = 0; i < _ingredients.length; i++)
                Padding(
                  key: ObjectKey(_ingredients[i]),
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: TextFormField(
                    controller: _ingredients[i],
                    autofocus: _focusIngredient == i,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ex: 2 xícaras de farinha',
                      suffixIcon: _ingredients.length == 1
                          ? null
                          : IconButton(
                              tooltip: 'Remover',
                              icon: Icon(
                                Icons.remove_circle_rounded,
                                color: c.error,
                              ),
                              onPressed: () => setState(() {
                                _focusIngredient = null;
                                _ingredients.removeAt(i).dispose();
                              }),
                            ),
                    ),
                  ),
                ),
              SecondaryButton(
                label: 'Adicionar ingrediente',
                icon: Icons.add_rounded,
                onPressed: () => setState(() {
                  _ingredients.add(TextEditingController());
                  _focusIngredient = _ingredients.length - 1;
                }),
              ),
              gap,
              label('Modo de preparo'),
              TextFormField(
                controller: _steps,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'Descreva o modo de preparo...\nUm passo por linha.',
                ),
              ),
              gap,
              label('Observações (opcional)'),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Dicas, variações, de onde veio a receita...',
                ),
              ),
            ],
          ),
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
            label: _isEditing ? 'Salvar Alterações' : 'Salvar Receita',
            loading: _saving,
            onPressed: _save,
          ),
        ),
      ),
    );
  }

  Widget _photoPicker(AppColors c, TextTheme t) {
    final Widget? image = _newImage != null
        ? Image.file(File(_newImage!.path), fit: BoxFit.cover)
        : _photoId != null
        ? CloudPhoto(photoId: _photoId!, placeholder: const SizedBox.shrink())
        : null;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _pickImage,
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 36,
                      color: c.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Adicionar foto', style: t.bodyMedium),
                    Text('(opcional)', style: t.bodySmall),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    image,
                    Positioned(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: CircleAvatar(
                        backgroundColor: c.background.withValues(alpha: 0.7),
                        child: Icon(Icons.edit_outlined, color: c.textPrimary),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

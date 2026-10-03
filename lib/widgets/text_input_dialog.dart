import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Caixa de diálogo com um campo de texto. Retorna o texto ou null (cancelar).
///
/// O campo é dono do próprio controller, que só é descartado quando a caixa
/// termina de fechar (descartar antes quebra a animação de saída).
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String? message,
  String initialValue = '',
  String hint = '',
  String confirmLabel = 'Salvar',
  TextInputType? keyboardType,
  TextCapitalization capitalization = TextCapitalization.none,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    message: message,
    initialValue: initialValue,
    hint: hint,
    confirmLabel: confirmLabel,
    keyboardType: keyboardType,
    capitalization: capitalization,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.message,
    required this.initialValue,
    required this.hint,
    required this.confirmLabel,
    required this.keyboardType,
    required this.capitalization,
  });

  final String title;
  final String? message;
  final String initialValue;
  final String hint;
  final String confirmLabel;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.capitalization,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(hintText: widget.hint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

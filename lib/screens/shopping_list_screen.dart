import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_data.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback_widgets.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<UserData>().addToShopping([text]);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserData>();
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final hasBought = user.shopping.any(user.isBought);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          if (hasBought)
            TextButton(
              onPressed: user.clearBought,
              child: const Text('Limpar comprados'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xs,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: 'Adicionar item...',
                  prefixIcon: const Icon(Icons.add_shopping_cart_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: c.accent),
                    onPressed: _add,
                  ),
                ),
              ),
            ),
            Expanded(
              child: user.shopping.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Lista vazia',
                      message:
                          'Adicione itens aqui ou pelos ingredientes de uma receita.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        AppSpacing.xl,
                      ),
                      itemCount: user.shopping.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (_, i) {
                        final item = user.shopping[i];
                        final done = user.isBought(item);
                        return Dismissible(
                          key: ValueKey(item),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => user.removeShopping(item),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: c.error.withValues(alpha: 0.15),
                              borderRadius: AppRadius.cardAll,
                            ),
                            child: Icon(Icons.delete_outline, color: c.error),
                          ),
                          child: Material(
                            color: c.card,
                            borderRadius: AppRadius.cardAll,
                            child: CheckboxListTile(
                              value: done,
                              onChanged: (_) => user.toggleBought(item),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: c.accent,
                              checkColor: c.onAccent,
                              side: BorderSide(color: c.textDisabled),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.cardAll,
                              ),
                              title: Text(
                                item,
                                style: t.bodyMedium?.copyWith(
                                  color: done ? c.textDisabled : c.textPrimary,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

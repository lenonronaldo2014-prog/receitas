import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/buttons.dart';

/// Entrar / criar conta (e-mail e senha ou Google).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _showPassword = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(Future<void> Function(AuthController auth) action) async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await action(context.read<AuthController>());
    } on AuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Algo deu errado. Tente de novo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(
      (auth) => _creating
          ? auth.signUp(_name.text, _email.text, _password.text)
          : auth.signIn(_email.text, _password.text),
    );
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vamos enviar um link para você criar uma senha nova.'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Seu e-mail'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.trim().isEmpty) return;
    await _run((auth) async {
      await auth.resetPassword(email);
      if (mounted) {
        _snack('Link enviado para $email. Confira sua caixa de entrada.');
      }
    });
  }

  String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe seu e-mail';
    if (!t.contains('@') || !t.contains('.')) return 'E-mail inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 96)),
                    const SizedBox(height: AppSpacing.md),
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
                      textAlign: TextAlign.center,
                      style: t.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _creating
                          ? 'Crie sua conta para salvar suas receitas'
                          : 'Entre para ver suas receitas em qualquer celular',
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _creating
                          ? Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'Seu nome',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) =>
                                    (v?.trim().isEmpty ?? true) && _creating
                                    ? 'Informe seu nome'
                                    : null,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      autofillHints: [
                        _creating
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _showPassword
                              ? 'Esconder senha'
                              : 'Mostrar senha',
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a senha';
                        if (_creating && v.length < 6) {
                          return 'Use pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    if (!_creating)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _busy ? null : _forgotPassword,
                          child: const Text('Esqueci minha senha'),
                        ),
                      )
                    else
                      const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: _creating ? 'Criar conta' : 'Entrar',
                      loading: _busy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(child: Divider(color: c.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text('ou', style: t.bodySmall),
                        ),
                        Expanded(child: Divider(color: c.border)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SecondaryButton(
                      label: 'Continuar com o Google',
                      leading: Image.asset(
                        'assets/icon/google_g.png',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: _busy
                          ? null
                          : () => _run((auth) => auth.signInWithGoogle()),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _creating ? 'Já tem conta?' : 'Não tem conta?',
                          style: t.bodyMedium?.copyWith(color: c.textSecondary),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() => _creating = !_creating),
                          child: Text(_creating ? 'Entrar' : 'Criar conta'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

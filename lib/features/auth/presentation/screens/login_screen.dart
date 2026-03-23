import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _senhaController.text,
          );
    } catch (e) {
      setState(() => _erro = 'E-mail ou senha inválidos.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const Key('email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('senha_field'),
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 8),
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('btn_entrar'),
                  onPressed: _carregando ? null : _login,
                  child: _carregando
                      ? const CircularProgressIndicator()
                      : const Text('Entrar'),
                ),
              ),
              TextButton(
                key: const Key('btn_cadastro'),
                onPressed: () => context.push('/cadastro'),
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

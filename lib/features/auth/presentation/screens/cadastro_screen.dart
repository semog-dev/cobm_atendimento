import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await ref.read(authProvider.notifier).cadastrar(
            nome: _nomeController.text.trim(),
            telefone: _telefoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _senhaController.text,
          );
    } catch (e) {
      setState(() => _erro = 'Erro ao cadastrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('nome_field'),
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('telefone_field'),
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),
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
                  key: const Key('btn_cadastrar'),
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const CircularProgressIndicator()
                      : const Text('Cadastrar'),
                ),
              ),
              TextButton(
                key: const Key('btn_login'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Já tem conta? Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

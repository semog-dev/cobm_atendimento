import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';

class RegistrarClienteScreen extends ConsumerStatefulWidget {
  const RegistrarClienteScreen({
    super.key,
    required this.sessaoId,
    required this.mediumEntidade,
  });

  final String sessaoId;
  final MediumEntidade mediumEntidade;

  @override
  ConsumerState<RegistrarClienteScreen> createState() =>
      _RegistrarClienteScreenState();
}

class _RegistrarClienteScreenState
    extends ConsumerState<RegistrarClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await ref.read(filaNotifierProvider.notifier).entrarNaFila(
            sessaoId: widget.sessaoId,
            clienteNome: _nomeController.text.trim(),
            mediumEntidadeId: widget.mediumEntidade.id,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('registrar_cliente_screen'),
      appBar: AppBar(title: const Text('Registrar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fila selecionada',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mediumEntidade.entidadeNome,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        widget.mediumEntidade.mediumNome,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('nome_cliente_field'),
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do cliente',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('btn_registrar_cliente'),
                onPressed: _carregando ? null : _registrar,
                child: _carregando
                    ? const CircularProgressIndicator()
                    : const Text('Adicionar à fila'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

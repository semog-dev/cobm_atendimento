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
      await ref
          .read(filaNotifierProvider.notifier)
          .entrarNaFila(
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
    final colorScheme = Theme.of(context).colorScheme;

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
              // Card da fila com borda lateral colorida
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fila selecionada',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.mediumEntidade.entidadeNome,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                widget.mediumEntidade.mediumNome,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                key: const Key('nome_cliente_field'),
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do cliente',
                  prefixIcon: Icon(Icons.person_outline),
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
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Adicionar à fila'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

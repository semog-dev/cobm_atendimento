import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';

class EntradaFilaScreen extends ConsumerStatefulWidget {
  const EntradaFilaScreen({super.key, required this.sessaoId});

  final String sessaoId;

  @override
  ConsumerState<EntradaFilaScreen> createState() => _EntradaFilaScreenState();
}

class _EntradaFilaScreenState extends ConsumerState<EntradaFilaScreen> {
  MediumEntidade? _selecionado;

  @override
  Widget build(BuildContext context) {
    final mediumEntidadesState = ref.watch(
      mediumEntidadesDaSessaoProvider(widget.sessaoId),
    );

    return Scaffold(
      key: const Key('entrada_fila_screen'),
      appBar: AppBar(title: const Text('Entrar na Fila')),
      body: mediumEntidadesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lista) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final me = lista[index];
                  return ListTile(
                    key: Key('me_tile_${me.id}'),
                    title: Text('${me.mediumNome} — ${me.entidadeNome}'),
                    leading: Radio<MediumEntidade>(
                      value: me,
                      groupValue: _selecionado,
                      onChanged: (value) =>
                          setState(() => _selecionado = value),
                    ),
                    onTap: () => setState(() => _selecionado = me),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                key: const Key('btn_entrar_fila'),
                onPressed: _selecionado == null ? null : _entrarNaFila,
                child: const Text('Entrar na Fila'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _entrarNaFila() async {
    final usuario = ref.read(authProvider);
    if (usuario == null || _selecionado == null) return;

    await ref
        .read(filaNotifierProvider.notifier)
        .entrarNaFila(
          sessaoId: widget.sessaoId,
          clienteId: usuario.id,
          mediumEntidadeId: _selecionado!.id,
        );

    if (mounted) context.go('/cliente/fila');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class FilaDetalheScreen extends ConsumerWidget {
  const FilaDetalheScreen({super.key, required this.mediumEntidade});

  final MediumEntidade mediumEntidade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);
    final fila = ref.watch(filaNotifierProvider);
    final entradas = fila
        .where((e) => e.mediumEntidadeId == mediumEntidade.id)
        .toList()
      ..sort((a, b) => a.posicao.compareTo(b.posicao));
    final aguardando = entradas.where((e) => e.isAguardando).toList()
      ..sort((a, b) => a.posicao.compareTo(b.posicao));

    final sessaoId = sessaoState.value?.id;

    return Scaffold(
      key: const Key('fila_detalhe_screen'),
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mediumEntidade.entidadeNome),
            Text(
              mediumEntidade.mediumNome,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: entradas.isEmpty
          ? const Center(child: Text('Nenhuma entrada nesta fila'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entradas.length,
              itemBuilder: (context, index) =>
                  _EntradaFilaCard(entrada: entradas[index]),
            ),
      floatingActionButton: sessaoId == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  key: const Key('btn_adicionar_cliente'),
                  heroTag: 'adicionar_cliente',
                  onPressed: () => context.push(
                    '/gestor/fila/registrar-cliente',
                    extra: {'sessaoId': sessaoId, 'me': mediumEntidade},
                  ),
                  child: const Icon(Icons.person_add),
                ),
                if (aguardando.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    key: const Key('btn_chamar_proximo'),
                    heroTag: 'chamar_proximo',
                    onPressed: () {
                      ref
                          .read(filaNotifierProvider.notifier)
                          .chamarProximo(aguardando.first.id);
                    },
                    label: const Text('Chamar próximo'),
                    icon: const Icon(Icons.campaign),
                  ),
                ],
              ],
            ),
    );
  }
}

class _EntradaFilaCard extends ConsumerWidget {
  const _EntradaFilaCard({required this.entrada});

  final EntradaFila entrada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      key: Key('entrada_fila_${entrada.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Posição ${entrada.posicao}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 12),
                _StatusBadge(status: entrada.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              entrada.clienteNome,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (entrada.isEmAtendimento) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: Key('btn_atendimento_${entrada.id}'),
                  onPressed: () =>
                      context.push('/gestor/atendimento', extra: entrada),
                  child: const Text('Ver atendimento'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatusFila status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StatusFila.aguardando => ('Aguardando', Colors.orange),
      StatusFila.emAtendimento => ('Em atendimento', Colors.green),
      StatusFila.concluido => ('Concluído', Colors.blue),
      StatusFila.cancelado => ('Cancelado', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

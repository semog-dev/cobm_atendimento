import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class FilaScreen extends ConsumerWidget {
  const FilaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);

    return sessaoState.when(
      loading: () => const Scaffold(
        key: Key('fila_screen'),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        key: const Key('fila_screen'),
        body: Center(child: Text('Erro: $e')),
      ),
      data: (sessao) {
        if (sessao == null) {
          return const Scaffold(
            key: Key('fila_screen'),
            body: Center(child: Text('Nenhuma sessão aberta')),
          );
        }

        final filaState = ref.watch(filaRealtimeProvider(sessao.id));

        return filaState.when(
          loading: () => const Scaffold(
            key: Key('fila_screen'),
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            key: const Key('fila_screen'),
            body: Center(child: Text('Erro ao carregar fila: $e')),
          ),
          data: (fila) {
            final aguardando =
                fila.where((e) => e.isAguardando).toList();

            return Scaffold(
              key: const Key('fila_screen'),
              appBar: AppBar(title: const Text('Fila de Atendimento')),
              body: fila.isEmpty
                  ? const Center(child: Text('Nenhuma entrada na fila'))
                  : ListView.builder(
                      itemCount: fila.length,
                      itemBuilder: (context, index) {
                        final entrada = fila[index];
                        return _EntradaFilaCard(entrada: entrada);
                      },
                    ),
              floatingActionButton: aguardando.isNotEmpty
                  ? FloatingActionButton.extended(
                      key: const Key('btn_chamar_proximo'),
                      onPressed: () {
                        ref
                            .read(filaNotifierProvider.notifier)
                            .chamarProximo(aguardando.first.id);
                      },
                      label: const Text('Chamar próximo'),
                      icon: const Icon(Icons.campaign),
                    )
                  : null,
            );
          },
        );
      },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posição ${entrada.posicao}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: entrada.status),
                ],
              ),
            ),
            if (entrada.isEmAtendimento)
              ElevatedButton(
                key: Key('btn_atendimento_${entrada.id}'),
                onPressed: () =>
                    context.push('/gestor/atendimento', extra: entrada),
                child: const Text('Ver atendimento'),
              ),
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
        color: color.withOpacity(0.15),
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

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: const Key('fila_detalhe_screen'),
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              mediumEntidade.entidadeNome,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            Text(
              mediumEntidade.mediumNome,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: entradas.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma entrada nesta fila',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: entradas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isAtendimento = entrada.isEmAtendimento;

    return Container(
      key: Key('entrada_fila_${entrada.id}'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAtendimento
              ? Colors.green.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isAtendimento ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Número da posição
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAtendimento
                    ? Colors.green.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entrada.posicao}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isAtendimento ? Colors.green : colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrada.clienteNome,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: entrada.status),
                ],
              ),
            ),
            if (isAtendimento)
              TextButton.icon(
                key: Key('btn_atendimento_${entrada.id}'),
                onPressed: () =>
                    context.push('/gestor/atendimento', extra: entrada),
                icon: const Icon(Icons.timer_outlined, size: 18),
                label: const Text('Ver'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

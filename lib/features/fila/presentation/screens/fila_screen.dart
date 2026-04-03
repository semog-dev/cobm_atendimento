import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class FilaScreen extends ConsumerWidget {
  const FilaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);

    ref.listen(sessaoNotifierProvider, (_, next) {
      next.whenData((sessao) {
        if (sessao != null) {
          ref.read(filaNotifierProvider.notifier).assinarSessao(sessao.id);
        }
      });
    });

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

        final fila = ref.watch(filaNotifierProvider);
        final meState = ref.watch(mediumEntidadesDaSessaoProvider(sessao.id));

        return Scaffold(
          key: const Key('fila_screen'),
          appBar: AppBar(title: const Text('Filas de Atendimento')),
          body: meState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (mediumEntidades) {
              if (mediumEntidades.isEmpty) {
                return const Center(
                  child: Text('Nenhuma fila disponível nesta sessão'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mediumEntidades.length,
                itemBuilder: (context, index) {
                  final me = mediumEntidades[index];
                  final entradas =
                      fila.where((e) => e.mediumEntidadeId == me.id).toList();
                  final aguardando =
                      entradas.where((e) => e.isAguardando).length;
                  final emAtendimento =
                      entradas.where((e) => e.isEmAtendimento).length;

                  return Card(
                    key: Key('fila_card_${me.id}'),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push(
                        '/gestor/fila/detalhe',
                        extra: me,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.auto_awesome),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    me.entidadeNome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    me.mediumNome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      if (emAtendimento > 0)
                                        _Badge(
                                          label: 'Em atendimento',
                                          color: Colors.green,
                                        ),
                                      _Badge(
                                        label: '$aguardando aguardando',
                                        color: aguardando > 0
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }
}

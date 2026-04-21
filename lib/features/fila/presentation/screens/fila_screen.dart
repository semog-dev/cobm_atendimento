import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class FilaScreen extends ConsumerWidget {
  const FilaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
          return Scaffold(
            key: const Key('fila_screen'),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma sessão aberta',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
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
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(sessaoNotifierProvider);
                  ref.invalidate(mediumEntidadesDaSessaoProvider(sessao.id));
                },
                child: mediumEntidades.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: const Center(
                              child: Text(
                                'Nenhuma fila disponível nesta sessão',
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: mediumEntidades.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final me = mediumEntidades[index];
                          final entradas = fila
                              .where((e) => e.mediumEntidadeId == me.id)
                              .toList();
                          final aguardando = entradas
                              .where((e) => e.isAguardando)
                              .length;
                          final emAtendimento = entradas
                              .where((e) => e.isEmAtendimento)
                              .length;

                          return InkWell(
                            key: Key('fila_card_${me.id}'),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                context.push('/gestor/fila/detalhe', extra: me),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: emAtendimento > 0
                                      ? Colors.green.withValues(alpha: 0.4)
                                      : colorScheme.outlineVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: emAtendimento > 0 ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.ghost,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          me.entidadeNome,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          me.mediumNome,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
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
                                                  : colorScheme.onSurface
                                                        .withValues(alpha: 0.3),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class SessaoScreen extends ConsumerWidget {
  const SessaoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);
    final historicoState = ref.watch(historicoSessoesProvider);

    return Scaffold(
      key: const Key('sessao_screen'),
      appBar: AppBar(title: const Text('Sessão')),
      body: sessaoState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (sessao) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: sessao == null
                    ? _SessaoFechadaView()
                    : _SessaoAbertaView(sessao: sessao),
              ),
              SliverToBoxAdapter(
                child: historicoState.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (historico) {
                    final encerradas = historico
                        .where((s) => s.isEncerrada)
                        .toList();
                    if (encerradas.isEmpty) return const SizedBox.shrink();

                    return Column(
                      key: const Key('historico_sessoes'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Histórico',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        ...encerradas.map(
                          (s) => _SessaoHistoricoCard(sessao: s),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessaoFechadaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.event_busy, size: 64),
          const SizedBox(height: 16),
          const Text('Nenhuma sessão aberta'),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('btn_abrir_sessao'),
            onPressed: () => context.push('/gestor/sessao/abrir'),
            child: const Text('Abrir Sessão'),
          ),
        ],
      ),
    );
  }
}

class _SessaoAbertaView extends ConsumerWidget {
  const _SessaoAbertaView({required this.sessao});

  final Sessao sessao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediumEntidadesState =
        ref.watch(mediumEntidadesDaSessaoProvider(sessao.id));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        'Sessão aberta',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aberta em: ${_formatarData(sessao.abertaEm)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Médiuns/Entidades disponíveis:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          mediumEntidadesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro ao carregar: $e'),
            data: (lista) => lista.isEmpty
                ? const Text('Nenhum médium/entidade vinculado.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final me = lista[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.auto_awesome, size: 18),
                        title: Text(
                            '${me.mediumNome} — ${me.entidadeNome}'),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('btn_encerrar_sessao'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(sessaoNotifierProvider.notifier)
                  .encerrarSessao(sessao.id);
              ref.invalidate(historicoSessoesProvider);
            },
            child: const Text('Encerrar Sessão'),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SessaoHistoricoCard extends StatelessWidget {
  const _SessaoHistoricoCard({required this.sessao});

  final Sessao sessao;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('sessao_card_${sessao.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_available,
                    color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Aberta em: ${_formatarData(sessao.abertaEm)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (sessao.encerradaEm != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event_busy,
                      color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Encerrada em: ${_formatarData(sessao.encerradaEm!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

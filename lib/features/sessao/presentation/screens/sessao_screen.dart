import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(sessaoNotifierProvider);
              ref.invalidate(historicoSessoesProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              SliverToBoxAdapter(
                child: sessao == null
                    ? _SessaoFechadaView()
                    : _SessaoAbertaView(sessao: sessao),
              ),
              SliverToBoxAdapter(
                child: historicoState.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (historico) {
                    final encerradas =
                        historico.where((s) => s.isEncerrada).toList();
                    if (encerradas.isEmpty) return const SizedBox.shrink();

                    return Column(
                      key: const Key('historico_sessoes'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Text(
                            'HISTÓRICO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: encerradas
                                .map((s) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: _SessaoHistoricoCard(sessao: s),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _SessaoFechadaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.35,
            child: SvgPicture.asset(
              'assets/images/cobm_ponto.svg',
              height: 96,
              colorFilter: ColorFilter.mode(
                colorScheme.onSurface.withValues(alpha: 0.5),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma sessão aberta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            key: const Key('btn_abrir_sessao'),
            onPressed: () => context.push('/gestor/sessao/abrir'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Abrir Sessão'),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card sessão ativa
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sessão em andamento',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Aberta em ${_formatarData(sessao.abertaEm)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'MÉDIUNS E ENTIDADES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 10),

          mediumEntidadesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro ao carregar: $e'),
            data: (lista) => lista.isEmpty
                ? Text(
                    'Nenhum médium/entidade vinculado.',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  )
                : Column(
                    children: lista
                        .map(
                          (me) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.ghost,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${me.entidadeNome} — ${me.mediumNome}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            key: const Key('btn_encerrar_sessao'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref
                .read(sessaoNotifierProvider.notifier)
                .encerrarSessao(sessao.id),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: Key('sessao_card_${sessao.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatarData(sessao.abertaEm),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (sessao.encerradaEm != null)
                  Text(
                    'Encerrada em ${_formatarData(sessao.encerradaEm!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Encerrada',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
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

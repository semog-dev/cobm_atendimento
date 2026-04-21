import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';

class AbrirSessaoScreen extends ConsumerStatefulWidget {
  const AbrirSessaoScreen({super.key});

  @override
  ConsumerState<AbrirSessaoScreen> createState() => _AbrirSessaoScreenState();
}

class _AbrirSessaoScreenState extends ConsumerState<AbrirSessaoScreen> {
  final Set<String> _selecionados = {};

  @override
  Widget build(BuildContext context) {
    final mediumEntidadesState = ref.watch(mediumEntidadesDisponiveisProvider);
    final usuario = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Abrir Sessão')),
      body: mediumEntidadesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lista) => Column(
          children: [
            Expanded(
              child: lista.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 48,
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum médium/entidade disponível.',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final me = lista[index];
                        final selecionado = _selecionados.contains(me.id);

                        return InkWell(
                          key: Key('me_check_${me.id}'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() {
                            if (selecionado) {
                              _selecionados.remove(me.id);
                            } else {
                              _selecionados.add(me.id);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? colorScheme.primary.withValues(alpha: 0.08)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selecionado
                                    ? colorScheme.primary.withValues(alpha: 0.5)
                                    : colorScheme.outlineVariant.withValues(
                                        alpha: 0.5,
                                      ),
                                width: selecionado ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: selecionado
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: selecionado
                                          ? colorScheme.primary
                                          : colorScheme.onSurface.withValues(
                                              alpha: 0.3,
                                            ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: selecionado
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selecionados.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${_selecionados.length} selecionado${_selecionados.length > 1 ? 's' : ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    key: const Key('btn_confirmar_abertura'),
                    onPressed: _selecionados.isEmpty || usuario == null
                        ? null
                        : () async {
                            await ref
                                .read(sessaoNotifierProvider.notifier)
                                .abrirSessao(
                                  gestorId: usuario.id,
                                  mediumEntidadeIds: Set.from(_selecionados),
                                );
                            if (context.mounted) context.pop();
                          },
                    child: const Text('Confirmar Abertura'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

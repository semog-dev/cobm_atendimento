import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';

class ClienteFilaScreen extends ConsumerWidget {
  const ClienteFilaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoState = ref.watch(sessaoNotifierProvider);
    final usuario = ref.watch(authProvider);

    return Scaffold(
      key: const Key('cliente_fila_screen'),
      appBar: AppBar(title: const Text('Minha Posição na Fila')),
      body: sessaoState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (sessao) {
          if (sessao == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nenhuma sessão aberta no momento'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          final filaState = ref.watch(filaRealtimeProvider(sessao.id));

          return filaState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar fila: $e')),
            data: (fila) {
              final minhaEntrada = usuario != null
                  ? fila.where((e) => e.clienteId == usuario.id).firstOrNull
                  : null;

              if (minhaEntrada == null ||
                  minhaEntrada.isConcluido ||
                  minhaEntrada.isCancelado) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Você não está na fila'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go(
                          '/cliente/entrar-fila',
                          extra: sessao.id,
                        ),
                        child: const Text('Entrar na fila'),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (minhaEntrada.isEmAtendimento)
                      _CardEmAtendimento()
                    else
                      _CardAguardando(entrada: minhaEntrada),
                    if (minhaEntrada.isAguardando) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => ref
                            .read(filaNotifierProvider.notifier)
                            .cancelarEntrada(minhaEntrada.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CardAguardando extends StatelessWidget {
  const _CardAguardando({required this.entrada});

  final EntradaFila entrada;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.hourglass_top, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Você está na posição ${entrada.posicao} da fila',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardEmAtendimento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'É a sua vez! Dirija-se ao médium',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

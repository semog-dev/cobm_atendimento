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
    final mediumEntidadesState =
        ref.watch(mediumEntidadesDisponiveisProvider);
    final usuario = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Abrir Sessão')),
      body: mediumEntidadesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lista) => Column(
          children: [
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text('Nenhum médium/entidade disponível.'),
                    )
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final me = lista[index];
                        return CheckboxListTile(
                          key: Key('me_check_${me.id}'),
                          title: Text(
                              '${me.mediumNome} — ${me.entidadeNome}'),
                          value: _selecionados.contains(me.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selecionados.add(me.id);
                              } else {
                                _selecionados.remove(me.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}

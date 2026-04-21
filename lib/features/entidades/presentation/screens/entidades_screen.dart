import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';

class EntidadesScreen extends ConsumerWidget {
  const EntidadesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(entidadesGestorProvider);

    return Scaffold(
      key: const Key('entidades_screen'),
      appBar: AppBar(title: const Text('Entidades')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (entidades) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(entidadesGestorProvider),
          child: entidades.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: Text('Nenhuma entidade cadastrada.'),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: entidades.length,
                  itemBuilder: (context, index) {
                    final entidade = entidades[index];
                    return ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.ghost,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(entidade.nome),
                      subtitle: entidade.descricao.isNotEmpty
                          ? Text(entidade.descricao)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: entidade.ativa,
                            onChanged: (_) => ref
                                .read(entidadesGestorProvider.notifier)
                                .alternarAtiva(
                                  entidade.id,
                                  ativa: entidade.ativa,
                                ),
                          ),
                          IconButton(
                            key: Key('btn_editar_${entidade.id}'),
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => context.push(
                              '/gestor/entidades/${entidade.id}',
                              extra: entidade,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab_nova_entidade'),
        onPressed: () => context.push('/gestor/entidades/nova'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

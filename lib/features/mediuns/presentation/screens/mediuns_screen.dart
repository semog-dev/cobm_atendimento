import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';

class MediunsScreen extends ConsumerWidget {
  const MediunsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mediunsGestorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Médiuns')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (mediuns) => mediuns.isEmpty
            ? const Center(
                key: Key('empty_message'),
                child: Text('Nenhum médium cadastrado'),
              )
            : ListView.builder(
                key: const Key('mediuns_list'),
                itemCount: mediuns.length,
                itemBuilder: (context, index) {
                  return _MediumTile(medium: mediuns[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('btn_adicionar'),
        onPressed: () => context.push('/gestor/mediuns/novo'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MediumTile extends ConsumerWidget {
  const _MediumTile({required this.medium});

  final Medium medium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('medium_item_${medium.id}'),
      title: Text(medium.nome),
      subtitle: Text(medium.ativo ? 'Ativo' : 'Inativo'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            key: Key('switch_ativo_${medium.id}'),
            value: medium.ativo,
            onChanged: (value) => ref
                .read(mediunsGestorProvider.notifier)
                .alternarAtivo(medium.id, ativo: medium.ativo),
          ),
          IconButton(
            key: Key('btn_editar_${medium.id}'),
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/gestor/mediuns/${medium.id}', extra: medium),
          ),
        ],
      ),
    );
  }
}

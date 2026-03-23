import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';

class EntidadeFormScreen extends ConsumerStatefulWidget {
  const EntidadeFormScreen({super.key, this.entidade});

  final Entidade? entidade;

  @override
  ConsumerState<EntidadeFormScreen> createState() => _EntidadeFormScreenState();
}

class _EntidadeFormScreenState extends ConsumerState<EntidadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  bool _carregando = false;
  Set<String> _mediunsSelecionados = {};
  Set<String> _mediunsOriginais = {};
  bool _vinculosCarregados = false;

  bool get _editando => widget.entidade != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.entidade?.nome ?? '');
    _descricaoController =
        TextEditingController(text: widget.entidade?.descricao ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      final notifier = ref.read(entidadesGestorProvider.notifier);
      if (_editando) {
        await notifier.atualizar(
          widget.entidade!.copyWith(
            nome: _nomeController.text.trim(),
            descricao: _descricaoController.text.trim(),
          ),
        );
        await notifier.atualizarVinculos(
          entidadeId: widget.entidade!.id,
          novosIds: _mediunsSelecionados,
          idsAntigos: _mediunsOriginais,
        );
      } else {
        await notifier.criar(
          nome: _nomeController.text.trim(),
          descricao: _descricaoController.text.trim(),
          mediumIds: _mediunsSelecionados,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediunsState = ref.watch(mediunsAtivosProvider);

    // Carrega vínculos existentes uma única vez ao editar
    if (_editando && !_vinculosCarregados) {
      ref
          .watch(mediunsVinculadosProvider(widget.entidade!.id))
          .whenData((vinculados) {
        if (!_vinculosCarregados) {
          final ids = vinculados.map((m) => m.id).toSet();
          setState(() {
            _mediunsSelecionados = ids;
            _mediunsOriginais = Set.from(ids);
            _vinculosCarregados = true;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Entidade' : 'Nova Entidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('nome_field'),
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('descricao_field'),
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Médiuns vinculados',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              mediunsState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Erro ao carregar médiuns: $e'),
                data: (mediuns) => mediuns.isEmpty
                    ? const Text('Nenhum médium ativo cadastrado.')
                    : Column(
                        key: const Key('mediuns_list'),
                        children: mediuns
                            .map((medium) => CheckboxListTile(
                                  key: Key('medium_check_${medium.id}'),
                                  title: Text(medium.nome),
                                  value: _mediunsSelecionados
                                      .contains(medium.id),
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _mediunsSelecionados.add(medium.id);
                                      } else {
                                        _mediunsSelecionados.remove(medium.id);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('btn_salvar'),
                onPressed: _carregando ? null : _salvar,
                child: _carregando
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

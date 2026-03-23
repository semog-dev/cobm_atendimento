import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';

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

  bool get _editando => widget.entidade != null;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.entidade?.nome ?? '');
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
      } else {
        await notifier.criar(
          nome: _nomeController.text.trim(),
          descricao: _descricaoController.text.trim(),
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Entidade' : 'Nova Entidade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('btn_salvar'),
                  onPressed: _carregando ? null : _salvar,
                  child: _carregando
                      ? const CircularProgressIndicator()
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';

class MediumFormScreen extends ConsumerStatefulWidget {
  const MediumFormScreen({super.key, this.medium});

  final Medium? medium;

  @override
  ConsumerState<MediumFormScreen> createState() => _MediumFormScreenState();
}

class _MediumFormScreenState extends ConsumerState<MediumFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _fotoUrlController;
  bool _carregando = false;
  String? _erro;

  bool get _editando => widget.medium != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.medium?.nome ?? '');
    _fotoUrlController = TextEditingController(
      text: widget.medium?.fotoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final notifier = ref.read(mediunsGestorProvider.notifier);
      final fotoUrl = _fotoUrlController.text.trim().isEmpty
          ? null
          : _fotoUrlController.text.trim();

      if (_editando) {
        await notifier.atualizar(
          widget.medium!.copyWith(
            nome: _nomeController.text.trim(),
            fotoUrl: fotoUrl,
          ),
        );
      } else {
        await notifier.criar(
          nome: _nomeController.text.trim(),
          fotoUrl: fotoUrl,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _erro = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar Médium' : 'Novo Médium')),
      body: SingleChildScrollView(
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
                key: const Key('foto_url_field'),
                controller: _fotoUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL da foto (opcional)',
                ),
              ),
              const SizedBox(height: 8),
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
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

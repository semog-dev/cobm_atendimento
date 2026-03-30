import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';

class AtendimentoScreen extends ConsumerStatefulWidget {
  const AtendimentoScreen({super.key, required this.entrada});

  final EntradaFila entrada;

  @override
  ConsumerState<AtendimentoScreen> createState() => _AtendimentoScreenState();
}

class _AtendimentoScreenState extends ConsumerState<AtendimentoScreen> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    final inicio = widget.entrada.chamadoEm ?? widget.entrada.criadoEm;
    _elapsed = DateTime.now().difference(inicio);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(inicio);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('atendimento_screen'),
      appBar: AppBar(title: const Text('Atendimento em curso')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posição ${widget.entrada.posicao}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Médium/Entidade: ${widget.entrada.mediumEntidadeId}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                _formatDuration(_elapsed),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              key: const Key('btn_encerrar_atendimento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                await ref
                    .read(filaNotifierProvider.notifier)
                    .encerrarAtendimento(widget.entrada.id);
                if (context.mounted) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/gestor/fila');
                  }
                }
              },
              child: const Text('Encerrar Atendimento'),
            ),
          ],
        ),
      ),
    );
  }
}

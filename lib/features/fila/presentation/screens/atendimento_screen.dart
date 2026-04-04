import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: const Key('atendimento_screen'),
      appBar: AppBar(title: const Text('Atendimento em curso')),
      body: Stack(
        children: [
          // Ponto riscado como fundo decorativo
          Positioned(
            left: -40,
            top: 60,
            child: Opacity(
              opacity: 0.05,
              child: SvgPicture.asset(
                'assets/images/cobm_ponto.svg',
                width: 280,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card do cliente
                Container(
                  padding: const EdgeInsets.all(20),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.entrada.posicao}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.entrada.clienteNome,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Em atendimento',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer heroico
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tempo de atendimento',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDuration(_elapsed),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w200,
                          color: colorScheme.primary,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  key: const Key('btn_encerrar_atendimento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
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
        ],
      ),
    );
  }
}

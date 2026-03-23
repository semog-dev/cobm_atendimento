import 'package:flutter/material.dart';

class SessaoScreen extends StatelessWidget {
  const SessaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('sessao_screen'),
      body: Center(child: Text('Sessão — em breve')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/login_screen.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/cadastro_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/cadastro',
      name: 'cadastro',
      builder: (context, state) => const CadastroScreen(),
    ),
  ],
);

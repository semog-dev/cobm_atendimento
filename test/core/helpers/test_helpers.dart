import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';

final usuarioFake = Usuario(
  id: 'uuid-123',
  nome: 'João Silva',
  telefone: '11999999999',
  role: Role.cliente,
  createdAt: DateTime(2024, 1, 1),
);

final gestorFake = Usuario(
  id: 'uuid-456',
  nome: 'Maria Gestora',
  telefone: '11988888888',
  role: Role.gestor,
  createdAt: DateTime(2024, 1, 1),
);

final usuarioMapFake = {
  'id': 'uuid-123',
  'nome': 'João Silva',
  'telefone': '11999999999',
  'role': 'cliente',
  'created_at': '2024-01-01T00:00:00.000',
};

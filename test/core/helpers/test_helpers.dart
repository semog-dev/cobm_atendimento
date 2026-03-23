import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';

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

final entidadeFake = Entidade(
  id: 'uuid-ent-001',
  nome: 'Exu Tranca Ruas',
  descricao: 'Guardião das encruzilhadas',
  ativa: true,
  createdAt: DateTime(2024, 1, 1),
);

final entidadeMapFake = {
  'id': 'uuid-ent-001',
  'nome': 'Exu Tranca Ruas',
  'descricao': 'Guardião das encruzilhadas',
  'ativa': true,
  'created_at': '2024-01-01T00:00:00.000',
};

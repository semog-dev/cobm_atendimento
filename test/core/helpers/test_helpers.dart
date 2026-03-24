import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';

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

final mediumFake = Medium(
  id: 'uuid-med-001',
  nome: 'José da Silva',
  fotoUrl: null,
  ativo: true,
  createdAt: DateTime(2024, 1, 1),
);

final mediumMapFake = {
  'id': 'uuid-med-001',
  'nome': 'José da Silva',
  'foto_url': null,
  'ativo': true,
  'created_at': '2024-01-01T00:00:00.000',
};

final sessaoFake = Sessao(
  id: 'uuid-sess-001',
  gestorId: 'uuid-456',
  status: StatusSessao.aberta,
  abertaEm: DateTime(2024, 1, 1, 9, 0),
  encerradaEm: null,
);

final mediumEntidadeFake = MediumEntidade(
  id: 'uuid-me-001',
  mediumId: 'uuid-med-001',
  entidadeId: 'uuid-ent-001',
  mediumNome: 'José da Silva',
  entidadeNome: 'Exu Tranca Ruas',
);

final entradaFilaFake = EntradaFila(
  id: 'uuid-fila-001',
  sessaoId: 'uuid-sess-001',
  clienteId: 'uuid-123',
  mediumEntidadeId: 'uuid-me-001',
  posicao: 1,
  status: StatusFila.aguardando,
  criadoEm: DateTime(2024, 1, 1, 9, 0),
  chamadoEm: null,
  iniciadoEm: null,
  encerradoEm: null,
  duracaoSegundos: null,
);

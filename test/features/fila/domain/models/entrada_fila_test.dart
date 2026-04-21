import 'package:flutter_test/flutter_test.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';

void main() {
  group('EntradaFila', () {
    final entrada = EntradaFila(
      id: 'uuid-fila-001',
      sessaoId: 'uuid-sess-001',
      clienteNome: 'João Silva',
      mediumEntidadeId: 'uuid-me-001',
      posicao: 1,
      status: StatusFila.aguardando,
      criadoEm: DateTime(2024, 1, 1, 9, 0),
      chamadoEm: null,
      iniciadoEm: null,
      encerradoEm: null,
      duracaoSegundos: null,
    );

    test('deve criar entrada na fila com todos os campos', () {
      expect(entrada.id, 'uuid-fila-001');
      expect(entrada.sessaoId, 'uuid-sess-001');
      expect(entrada.clienteNome, 'João Silva');
      expect(entrada.mediumEntidadeId, 'uuid-me-001');
      expect(entrada.posicao, 1);
      expect(entrada.status, StatusFila.aguardando);
      expect(entrada.criadoEm, DateTime(2024, 1, 1, 9, 0));
      expect(entrada.chamadoEm, isNull);
      expect(entrada.duracaoSegundos, isNull);
    });

    test('deve retornar true para isAguardando quando status é aguardando', () {
      expect(entrada.isAguardando, isTrue);
      expect(entrada.isEmAtendimento, isFalse);
      expect(entrada.isConcluido, isFalse);
      expect(entrada.isCancelado, isFalse);
    });

    test(
      'deve retornar true para isEmAtendimento quando status é em_atendimento',
      () {
        final emAtendimento = entrada.copyWith(
          status: StatusFila.emAtendimento,
        );
        expect(emAtendimento.isEmAtendimento, isTrue);
        expect(emAtendimento.isAguardando, isFalse);
      },
    );

    test('deve retornar true para isConcluido quando status é concluido', () {
      final concluido = entrada.copyWith(
        status: StatusFila.concluido,
        encerradoEm: DateTime(2024, 1, 1, 10, 0),
        duracaoSegundos: 3600,
      );
      expect(concluido.isConcluido, isTrue);
      expect(concluido.duracaoSegundos, 3600);
    });

    test('deve retornar true para isCancelado quando status é cancelado', () {
      final cancelado = entrada.copyWith(status: StatusFila.cancelado);
      expect(cancelado.isCancelado, isTrue);
    });

    test('deve ser igual quando todos os campos são iguais', () {
      final outra = EntradaFila(
        id: 'uuid-fila-001',
        sessaoId: 'uuid-sess-001',
        clienteNome: 'João Silva',
        mediumEntidadeId: 'uuid-me-001',
        posicao: 1,
        status: StatusFila.aguardando,
        criadoEm: DateTime(2024, 1, 1, 9, 0),
        chamadoEm: null,
        iniciadoEm: null,
        encerradoEm: null,
        duracaoSegundos: null,
      );
      expect(entrada, equals(outra));
    });

    test('deve criar cópia com campo alterado via copyWith', () {
      final chamada = entrada.copyWith(
        status: StatusFila.emAtendimento,
        chamadoEm: DateTime(2024, 1, 1, 9, 30),
      );
      expect(chamada.status, StatusFila.emAtendimento);
      expect(chamada.chamadoEm, DateTime(2024, 1, 1, 9, 30));
      expect(chamada.id, entrada.id);
    });

    test('deve serializar para map corretamente', () {
      final map = entrada.toMap();
      expect(map['id'], 'uuid-fila-001');
      expect(map['sessao_id'], 'uuid-sess-001');
      expect(map['cliente_nome'], 'João Silva');
      expect(map['medium_entidade_id'], 'uuid-me-001');
      expect(map['posicao'], 1);
      expect(map['status'], 'aguardando');
      expect(map['chamado_em'], isNull);
    });

    test('deve desserializar de map corretamente', () {
      final map = {
        'id': 'uuid-fila-001',
        'sessao_id': 'uuid-sess-001',
        'cliente_nome': 'João Silva',
        'medium_entidade_id': 'uuid-me-001',
        'posicao': 1,
        'status': 'aguardando',
        'criado_em': '2024-01-01T09:00:00.000',
        'chamado_em': null,
        'iniciado_em': null,
        'encerrado_em': null,
        'duracao_segundos': null,
      };
      final fromMap = EntradaFila.fromMap(map);
      expect(fromMap.id, 'uuid-fila-001');
      expect(fromMap.clienteNome, 'João Silva');
      expect(fromMap.status, StatusFila.aguardando);
      expect(fromMap.chamadoEm, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';

void main() {
  group('Sessao', () {
    final sessao = Sessao(
      id: 'uuid-sess-001',
      gestorId: 'uuid-456',
      status: StatusSessao.aberta,
      abertaEm: DateTime(2024, 1, 1, 9, 0),
      encerradaEm: null,
    );

    test('deve criar sessão com todos os campos', () {
      expect(sessao.id, 'uuid-sess-001');
      expect(sessao.gestorId, 'uuid-456');
      expect(sessao.status, StatusSessao.aberta);
      expect(sessao.abertaEm, DateTime(2024, 1, 1, 9, 0));
      expect(sessao.encerradaEm, isNull);
    });

    test('deve retornar true para isAberta quando status é aberta', () {
      expect(sessao.isAberta, isTrue);
      expect(sessao.isEncerrada, isFalse);
    });

    test('deve retornar true para isEncerrada quando status é encerrada', () {
      final encerrada = sessao.copyWith(
        status: StatusSessao.encerrada,
        encerradaEm: DateTime(2024, 1, 1, 12, 0),
      );
      expect(encerrada.isEncerrada, isTrue);
      expect(encerrada.isAberta, isFalse);
    });

    test('deve ser igual quando todos os campos são iguais', () {
      final outra = Sessao(
        id: 'uuid-sess-001',
        gestorId: 'uuid-456',
        status: StatusSessao.aberta,
        abertaEm: DateTime(2024, 1, 1, 9, 0),
        encerradaEm: null,
      );
      expect(sessao, equals(outra));
    });

    test('deve criar cópia com campo alterado via copyWith', () {
      final encerrada = sessao.copyWith(
        status: StatusSessao.encerrada,
        encerradaEm: DateTime(2024, 1, 1, 12, 0),
      );
      expect(encerrada.status, StatusSessao.encerrada);
      expect(encerrada.encerradaEm, DateTime(2024, 1, 1, 12, 0));
      expect(encerrada.id, sessao.id);
    });

    test('deve serializar para map corretamente', () {
      final map = sessao.toMap();
      expect(map['id'], 'uuid-sess-001');
      expect(map['gestor_id'], 'uuid-456');
      expect(map['status'], 'aberta');
      expect(map['encerrada_em'], isNull);
    });

    test('deve desserializar de map corretamente', () {
      final map = {
        'id': 'uuid-sess-001',
        'gestor_id': 'uuid-456',
        'status': 'aberta',
        'aberta_em': '2024-01-01T09:00:00.000',
        'encerrada_em': null,
      };
      final fromMap = Sessao.fromMap(map);
      expect(fromMap.id, 'uuid-sess-001');
      expect(fromMap.status, StatusSessao.aberta);
      expect(fromMap.encerradaEm, isNull);
    });

    test('deve desserializar sessão encerrada de map corretamente', () {
      final map = {
        'id': 'uuid-sess-001',
        'gestor_id': 'uuid-456',
        'status': 'encerrada',
        'aberta_em': '2024-01-01T09:00:00.000',
        'encerrada_em': '2024-01-01T12:00:00.000',
      };
      final fromMap = Sessao.fromMap(map);
      expect(fromMap.status, StatusSessao.encerrada);
      expect(fromMap.encerradaEm, isNotNull);
    });
  });
}

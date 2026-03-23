import 'package:flutter_test/flutter_test.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';

void main() {
  group('Medium', () {
    final medium = Medium(
      id: 'uuid-med-001',
      nome: 'José da Silva',
      fotoUrl: 'https://exemplo.com/jose.jpg',
      ativo: true,
      createdAt: DateTime(2024, 1, 1),
    );

    test('deve criar médium com todos os campos', () {
      expect(medium.id, 'uuid-med-001');
      expect(medium.nome, 'José da Silva');
      expect(medium.fotoUrl, 'https://exemplo.com/jose.jpg');
      expect(medium.ativo, isTrue);
      expect(medium.createdAt, DateTime(2024, 1, 1));
    });

    test('deve criar médium sem foto', () {
      final semFoto = Medium(
        id: 'uuid-med-002',
        nome: 'Ana Paula',
        fotoUrl: null,
        ativo: true,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(semFoto.fotoUrl, isNull);
    });

    test('deve ser igual quando todos os campos são iguais', () {
      final outro = Medium(
        id: 'uuid-med-001',
        nome: 'José da Silva',
        fotoUrl: 'https://exemplo.com/jose.jpg',
        ativo: true,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(medium, equals(outro));
    });

    test('deve criar cópia com campo alterado via copyWith', () {
      final atualizado = medium.copyWith(ativo: false);
      expect(atualizado.ativo, isFalse);
      expect(atualizado.id, medium.id);
      expect(atualizado.nome, medium.nome);
    });

    test('deve remover foto via copyWith', () {
      final semFoto = medium.copyWith(fotoUrl: null);
      expect(semFoto.fotoUrl, isNull);
      expect(semFoto.nome, medium.nome);
    });

    test('deve serializar para map corretamente', () {
      final map = medium.toMap();
      expect(map['id'], 'uuid-med-001');
      expect(map['nome'], 'José da Silva');
      expect(map['foto_url'], 'https://exemplo.com/jose.jpg');
      expect(map['ativo'], isTrue);
    });

    test('deve desserializar de map corretamente', () {
      final map = {
        'id': 'uuid-med-001',
        'nome': 'José da Silva',
        'foto_url': 'https://exemplo.com/jose.jpg',
        'ativo': true,
        'created_at': '2024-01-01T00:00:00.000',
      };
      final fromMap = Medium.fromMap(map);
      expect(fromMap.id, 'uuid-med-001');
      expect(fromMap.fotoUrl, 'https://exemplo.com/jose.jpg');
      expect(fromMap.ativo, isTrue);
    });

    test('deve desserializar de map sem foto corretamente', () {
      final map = {
        'id': 'uuid-med-002',
        'nome': 'Ana Paula',
        'foto_url': null,
        'ativo': true,
        'created_at': '2024-01-01T00:00:00.000',
      };
      final fromMap = Medium.fromMap(map);
      expect(fromMap.fotoUrl, isNull);
    });
  });
}

class MediumEntidade {
  const MediumEntidade({
    required this.id,
    required this.mediumId,
    required this.entidadeId,
    required this.mediumNome,
    required this.entidadeNome,
  });

  final String id;
  final String mediumId;
  final String entidadeId;
  final String mediumNome;
  final String entidadeNome;

  factory MediumEntidade.fromMap(Map<String, dynamic> map) {
    return MediumEntidade(
      id: map['id'] as String,
      mediumId: map['medium_id'] as String,
      entidadeId: map['entidade_id'] as String,
      mediumNome: (map['mediuns'] as Map<String, dynamic>)['nome'] as String,
      entidadeNome:
          (map['entidades'] as Map<String, dynamic>)['nome'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MediumEntidade && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

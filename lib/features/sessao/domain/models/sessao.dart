enum StatusSessao { aberta, encerrada }

class Sessao {
  const Sessao({
    required this.id,
    required this.gestorId,
    required this.status,
    required this.abertaEm,
    required this.encerradaEm,
  });

  final String id;
  final String gestorId;
  final StatusSessao status;
  final DateTime abertaEm;
  final DateTime? encerradaEm;

  bool get isAberta => status == StatusSessao.aberta;
  bool get isEncerrada => status == StatusSessao.encerrada;

  static const _unset = Object();

  Sessao copyWith({
    String? id,
    String? gestorId,
    StatusSessao? status,
    DateTime? abertaEm,
    Object? encerradaEm = _unset,
  }) {
    return Sessao(
      id: id ?? this.id,
      gestorId: gestorId ?? this.gestorId,
      status: status ?? this.status,
      abertaEm: abertaEm ?? this.abertaEm,
      encerradaEm: identical(encerradaEm, _unset)
          ? this.encerradaEm
          : encerradaEm as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gestor_id': gestorId,
      'status': status.name,
      'aberta_em': abertaEm.toIso8601String(),
      'encerrada_em': encerradaEm?.toIso8601String(),
    };
  }

  factory Sessao.fromMap(Map<String, dynamic> map) {
    return Sessao(
      id: map['id'] as String,
      gestorId: map['gestor_id'] as String,
      status: StatusSessao.values.byName(map['status'] as String),
      abertaEm: DateTime.parse(map['aberta_em'] as String),
      encerradaEm: map['encerrada_em'] != null
          ? DateTime.parse(map['encerrada_em'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sessao &&
          id == other.id &&
          gestorId == other.gestorId &&
          status == other.status &&
          abertaEm == other.abertaEm &&
          encerradaEm == other.encerradaEm;

  @override
  int get hashCode => Object.hash(id, gestorId, status, abertaEm, encerradaEm);
}

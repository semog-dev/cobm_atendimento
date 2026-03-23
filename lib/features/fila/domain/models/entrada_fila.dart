enum StatusFila {
  aguardando,
  emAtendimento,
  concluido,
  cancelado;

  String toJson() => switch (this) {
        StatusFila.aguardando => 'aguardando',
        StatusFila.emAtendimento => 'em_atendimento',
        StatusFila.concluido => 'concluido',
        StatusFila.cancelado => 'cancelado',
      };

  static StatusFila fromJson(String value) => switch (value) {
        'aguardando' => StatusFila.aguardando,
        'em_atendimento' => StatusFila.emAtendimento,
        'concluido' => StatusFila.concluido,
        'cancelado' => StatusFila.cancelado,
        _ => throw ArgumentError('StatusFila inválido: $value'),
      };
}

class EntradaFila {
  const EntradaFila({
    required this.id,
    required this.sessaoId,
    required this.clienteId,
    required this.mediumEntidadeId,
    required this.posicao,
    required this.status,
    required this.criadoEm,
    required this.chamadoEm,
    required this.iniciadoEm,
    required this.encerradoEm,
    required this.duracaoSegundos,
  });

  final String id;
  final String sessaoId;
  final String clienteId;
  final String mediumEntidadeId;
  final int posicao;
  final StatusFila status;
  final DateTime criadoEm;
  final DateTime? chamadoEm;
  final DateTime? iniciadoEm;
  final DateTime? encerradoEm;
  final int? duracaoSegundos;

  bool get isAguardando => status == StatusFila.aguardando;
  bool get isEmAtendimento => status == StatusFila.emAtendimento;
  bool get isConcluido => status == StatusFila.concluido;
  bool get isCancelado => status == StatusFila.cancelado;

  static const _unset = Object();

  EntradaFila copyWith({
    String? id,
    String? sessaoId,
    String? clienteId,
    String? mediumEntidadeId,
    int? posicao,
    StatusFila? status,
    DateTime? criadoEm,
    Object? chamadoEm = _unset,
    Object? iniciadoEm = _unset,
    Object? encerradoEm = _unset,
    Object? duracaoSegundos = _unset,
  }) {
    return EntradaFila(
      id: id ?? this.id,
      sessaoId: sessaoId ?? this.sessaoId,
      clienteId: clienteId ?? this.clienteId,
      mediumEntidadeId: mediumEntidadeId ?? this.mediumEntidadeId,
      posicao: posicao ?? this.posicao,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      chamadoEm: identical(chamadoEm, _unset) ? this.chamadoEm : chamadoEm as DateTime?,
      iniciadoEm: identical(iniciadoEm, _unset) ? this.iniciadoEm : iniciadoEm as DateTime?,
      encerradoEm: identical(encerradoEm, _unset) ? this.encerradoEm : encerradoEm as DateTime?,
      duracaoSegundos: identical(duracaoSegundos, _unset) ? this.duracaoSegundos : duracaoSegundos as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessao_id': sessaoId,
      'cliente_id': clienteId,
      'medium_entidade_id': mediumEntidadeId,
      'posicao': posicao,
      'status': status.toJson(),
      'criado_em': criadoEm.toIso8601String(),
      'chamado_em': chamadoEm?.toIso8601String(),
      'iniciado_em': iniciadoEm?.toIso8601String(),
      'encerrado_em': encerradoEm?.toIso8601String(),
      'duracao_segundos': duracaoSegundos,
    };
  }

  factory EntradaFila.fromMap(Map<String, dynamic> map) {
    return EntradaFila(
      id: map['id'] as String,
      sessaoId: map['sessao_id'] as String,
      clienteId: map['cliente_id'] as String,
      mediumEntidadeId: map['medium_entidade_id'] as String,
      posicao: map['posicao'] as int,
      status: StatusFila.fromJson(map['status'] as String),
      criadoEm: DateTime.parse(map['criado_em'] as String),
      chamadoEm: map['chamado_em'] != null ? DateTime.parse(map['chamado_em'] as String) : null,
      iniciadoEm: map['iniciado_em'] != null ? DateTime.parse(map['iniciado_em'] as String) : null,
      encerradoEm: map['encerrado_em'] != null ? DateTime.parse(map['encerrado_em'] as String) : null,
      duracaoSegundos: map['duracao_segundos'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntradaFila &&
          id == other.id &&
          sessaoId == other.sessaoId &&
          clienteId == other.clienteId &&
          mediumEntidadeId == other.mediumEntidadeId &&
          posicao == other.posicao &&
          status == other.status &&
          criadoEm == other.criadoEm &&
          chamadoEm == other.chamadoEm &&
          iniciadoEm == other.iniciadoEm &&
          encerradoEm == other.encerradoEm &&
          duracaoSegundos == other.duracaoSegundos;

  @override
  int get hashCode => Object.hash(
        id, sessaoId, clienteId, mediumEntidadeId, posicao,
        status, criadoEm, chamadoEm, iniciadoEm, encerradoEm, duracaoSegundos,
      );
}

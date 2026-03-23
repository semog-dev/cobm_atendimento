import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final mediunsRepositoryProvider = Provider<MediunsRepository>((ref) {
  return MediunsRepository(client: supabase);
});

final mediunsProvider = FutureProvider<List<Medium>>((ref) {
  return ref.read(mediunsRepositoryProvider).listar();
});

final mediunsAtivosProvider = FutureProvider<List<Medium>>((ref) {
  return ref.read(mediunsRepositoryProvider).listarAtivos();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/horarios/data/datasources/horarios_local_datasource.dart';
import '../../features/horarios/data/datasources/horarios_remote_datasource.dart';
import '../../features/horarios/data/repositories/horarios_repository_impl.dart';
import '../../features/horarios/domain/repositories/horarios_repository.dart';
import '../../features/horarios/domain/usecases/obtener_horarios_semana.dart';
import 'core_providers.dart';

/// Conecta las piezas del módulo de ejemplo (HU-01-10). Copie este archivo para uno nuevo.
final horariosRepositoryProvider = Provider<HorariosRepository>((ref) {
  final config = ref.watch(apiConfigProvider);
  return HorariosRepositoryImpl(
    HorariosRemoteDatasource(
      HorariosDeServicioApi(ref.watch(clienteApiProvider)),
      config.comercioId,
    ),
    HorariosLocalDatasource(ref.watch(appDatabaseProvider)),
    vigilante: ref.watch(vigilanteSincronizacionProvider),
  );
});

final obtenerHorariosSemanaProvider = Provider<ObtenerHorariosSemana>(
  (ref) => ObtenerHorariosSemana(ref.watch(horariosRepositoryProvider)),
);

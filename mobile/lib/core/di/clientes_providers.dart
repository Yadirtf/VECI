import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/clientes/data/datasources/clientes_local_datasource.dart';
import '../../features/clientes/data/datasources/clientes_remote_datasource.dart';
import '../../features/clientes/data/repositories/clientes_repository_impl.dart';
import '../../features/clientes/domain/repositories/clientes_repository.dart';
import 'core_providers.dart';
import 'sesion_providers.dart';

/// Conecta los clientes de la caja (EP-04) con el negocio activo, la red y la base local.
final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  final api = ref.watch(clienteApiProvider);
  final comercioId = ref.watch(comercioActivoProvider) ?? '';
  return ClientesRepositoryImpl(
    ClientesRemoteDatasource(ClientesApi(api), RegistroDelClienteApi(api), comercioId),
    ClientesLocalDatasource(ref.watch(appDatabaseProvider)),
    comercioId,
    reloj: ref.watch(relojProvider),
    vigilante: ref.watch(vigilanteSincronizacionProvider),
  );
});

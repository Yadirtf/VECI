import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/sesion/domain/repositories/sesion_repository.dart';
import '../../features/tiqueteras/data/datasources/copia_mis_tiqueteras.dart';
import '../../features/tiqueteras/data/datasources/ventas_local_datasource.dart';
import '../../features/tiqueteras/data/datasources/ventas_remote_datasource.dart';
import '../../features/tiqueteras/data/repositories/mis_tiqueteras_repository_impl.dart';
import '../../features/tiqueteras/data/repositories/ventas_repository_impl.dart';
import '../../features/tiqueteras/domain/reglas/uuid_v7.dart';
import '../../features/tiqueteras/domain/repositories/ventas_repository.dart';
import '../database/app_database.dart';
import 'core_providers.dart';
import 'sesion_providers.dart';

VentasRemoteDatasource _remoto(Ref ref, String comercioId) {
  final api = ref.watch(clienteApiProvider);
  return VentasRemoteDatasource(VentasApi(api), TiqueterasApi(api), comercioId);
}

/// Conecta las ventas de la caja (EP-05) con el negocio activo, la red y la cola local.
final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  final comercioId = ref.watch(comercioActivoProvider) ?? '';
  return VentasRepositoryImpl(
    _remoto(ref, comercioId),
    VentasLocalDatasource(ref.watch(appDatabaseProvider)),
    comercioId,
    reloj: ref.watch(relojProvider),
    vigilante: ref.watch(vigilanteSincronizacionProvider),
  );
});

/// El saldo de la persona en sus negocios, con la copia cifrada del celular.
final misTiqueterasRepositoryProvider = Provider<MisTiqueterasRepository>(
  (ref) => MisTiqueterasRepositoryImpl(
    _remoto(ref, ''),
    CopiaMisTiqueteras(CajonDeSaldosSeguro(ref.watch(almacenSeguroProvider))),
  ),
);

/// Id de cada venta: UUID v7 hecho en el celular (las pruebas lo fijan).
final nuevoIdDeVentaProvider = Provider<String Function()>((ref) {
  final azar = Random.secure();
  final reloj = ref.watch(relojProvider);
  return () => uuidV7(reloj(), azar);
});

/// Cuenta la cola de ventas del celular para avisar antes de cerrar la sesión (EP-02).
class VentasEnCola implements EventosPendientes {
  VentasEnCola(this._db);

  final AppDatabase Function() _db;

  @override
  Future<int> contar() => VentasLocalDatasource(_db()).contarEnEspera();
}

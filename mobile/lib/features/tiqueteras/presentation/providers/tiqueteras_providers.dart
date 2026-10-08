import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/tiqueteras_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../domain/entities/catalogo.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/entities/venta.dart';

/// El catálogo de venta: primero el guardado (al instante, aun sin señal) y luego el
/// confirmado por el servidor. Al abrirlo también se envían las ventas en espera.
final catalogoDeVentaProvider = StreamProvider.autoDispose<CatalogoDeVenta>((ref) async* {
  final repositorio = ref.watch(ventasRepositoryProvider);
  final guardado = await repositorio.catalogoGuardado();
  if (guardado != null) yield guardado;
  yield await repositorio.actualizarCatalogo();
  if (await repositorio.enviarPendientes() > 0) ref.invalidate(ventasPorEnviarProvider);
});

/// Saldo, tiqueteras e historia de un cliente del negocio activo (necesita señal).
final cuentaDelClienteProvider = FutureProvider.autoDispose.family<EstadoDeCuenta, String>(
  (ref, clienteId) => ref.watch(ventasRepositoryProvider).cuenta(clienteId),
);

/// Ventas del celular que aún no llegan al servidor, o que el servidor rechazó.
final ventasPorEnviarProvider = FutureProvider.autoDispose<List<VentaPorEnviar>>(
  (ref) => ref.watch(ventasRepositoryProvider).porEnviar(),
);

/// El saldo de la persona en sus negocios, y si se está viendo la copia sin señal.
typedef MisSaldos = ({List<SaldoEnNegocio> negocios, bool sinSenal});

final misTiqueterasProvider = StreamProvider.autoDispose<MisSaldos>((ref) async* {
  final repositorio = ref.watch(misTiqueterasRepositoryProvider);
  final copia = await repositorio.guardadas();
  if (copia != null) yield (negocios: copia, sinSenal: false);
  try {
    yield (negocios: await repositorio.traer(), sinSenal: false);
  } on Fallo catch (fallo) {
    if (copia == null) rethrow;
    yield (negocios: copia, sinSenal: fallo is SinConexion);
  }
});

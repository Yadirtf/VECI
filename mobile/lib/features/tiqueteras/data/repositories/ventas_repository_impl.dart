import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/observabilidad/vigilante_sincronizacion.dart';
import '../../domain/entities/catalogo.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/ventas_local_datasource.dart';
import '../datasources/ventas_remote_datasource.dart';
import '../models/tiqueteras_model.dart';

/// Ventas del negocio activo. Cada venta entra primero a la cola del celular y sale
/// cuando el servidor la confirma: sin señal, la caja sigue vendiendo (ADR-0004).
class VentasRepositoryImpl implements VentasRepository {
  VentasRepositoryImpl(
    this._remoto,
    this._local,
    this._comercioId, {
    DateTime Function()? reloj,
    this._vigilante,
  }) : _reloj = reloj ?? DateTime.now;

  final VentasRemoteDatasource _remoto;
  final VentasLocalDatasource _local;
  final String _comercioId;
  final DateTime Function() _reloj;
  final VigilanteSincronizacion? _vigilante;

  @override
  Future<CatalogoDeVenta?> catalogoGuardado({bool sinSenal = false}) async {
    final guardado = await _local.catalogo(_comercioId);
    final respuesta = CatalogoDeVentaResponse.fromJson(guardado?.contenido);
    if (guardado == null || respuesta == null) return null;
    return TiqueterasModel.catalogo(
      respuesta,
      alDiaEn: guardado.alDiaEn,
    ).conSenal(sinSenal: sinSenal);
  }

  @override
  Future<CatalogoDeVenta> actualizarCatalogo() async {
    try {
      final guardado = await _local.catalogo(_comercioId);
      final respuesta = await _remoto.bajarCatalogo(etag: guardado?.etag);
      _vigilante?.registrarExito();
      final contenido = respuesta.contenido;
      if (contenido == null) {
        await _local.confirmarCatalogo(_comercioId, _reloj());
      } else {
        await _local.guardarCatalogo(_comercioId, contenido, etag: respuesta.etag, ahora: _reloj());
      }
      return (await catalogoGuardado()) ?? (throw const ServidorNoDisponible(0));
    } on SinConexion {
      return (await catalogoGuardado(sinSenal: true)) ?? (throw const SinConexion());
    } on ServidorNoDisponible catch (fallo) {
      _vigilante?.registrarFallo(fallo);
      return (await catalogoGuardado(sinSenal: true)) ?? (throw fallo);
    }
  }

  @override
  Future<EstadoDeCuenta> cuenta(String clienteId) async =>
      TiqueterasModel.cuenta(await _remoto.cuenta(clienteId));

  @override
  Future<ResultadoVenta> vender(VentaEnCaja venta) async {
    await _local.encolar(_comercioId, venta);
    try {
      final hecha = await _remoto.vender(venta, sinConexion: false);
      await _local.quitar(venta.ventaId);
      _vigilante?.registrarExito();
      return VentaEnviada(TiqueterasModel.deLaVenta(hecha));
    } on PeticionRechazada {
      // En línea manda la pizarra: si la rechazó, la cajera lo corrige y vuelve a cobrar.
      await _local.quitar(venta.ventaId);
      rethrow;
    } on SinConexion {
      return const VentaGuardada();
    } on ServidorNoDisponible catch (fallo) {
      _vigilante?.registrarFallo(fallo);
      return const VentaGuardada();
    }
  }

  @override
  Future<int> enviarPendientes() async {
    var enviadas = 0;
    for (final venta in await _local.enEspera(_comercioId)) {
      try {
        await _local.contarIntento(venta.ventaId);
        await _remoto.vender(venta, sinConexion: true);
        await _local.quitar(venta.ventaId);
        enviadas++;
      } on PeticionRechazada catch (rechazo) {
        await _local.rechazar(venta.ventaId, rechazo.mensaje);
      } on Fallo {
        // Sin señal o servidor caído: se intenta en la próxima vuelta.
        break;
      }
    }
    if (enviadas > 0) _vigilante?.registrarExito();
    return enviadas;
  }

  @override
  Future<List<VentaPorEnviar>> porEnviar() => _local.todas(_comercioId);

  @override
  Future<void> descartar(String ventaId) => _local.quitar(ventaId);
}

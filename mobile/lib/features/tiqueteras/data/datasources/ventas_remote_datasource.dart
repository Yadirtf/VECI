import 'dart:convert';
import 'dart:io';

import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/venta.dart';

/// Lo que respondió el servidor por el catálogo: el JSON nuevo con su ETag, o
/// [sinCambios] si el del celular sigue al día (304).
class RespuestaCatalogo {
  const RespuestaCatalogo({this.contenido, this.etag});

  final Map<String, Object?>? contenido;
  final String? etag;

  bool get sinCambios => contenido == null;
}

/// Ventas y saldos desde el API (cliente generado desde OpenAPI) para el negocio activo.
class VentasRemoteDatasource {
  VentasRemoteDatasource(this._ventas, this._tiqueteras, this._comercioId);

  final VentasApi _ventas;
  final TiqueterasApi _tiqueteras;
  final String _comercioId;

  static const _espera = Duration(seconds: 10);

  /// Con [etag] el servidor responde 304 si el catálogo no cambió. El cliente generado
  /// no expone If-None-Match, así que se arma la petición.
  Future<RespuestaCatalogo> bajarCatalogo({String? etag}) => _conRed(() async {
    final respuesta = await _ventas.apiClient
        .invokeAPI(
          '/ventas/catalogo',
          'GET',
          [],
          null,
          {'x-veci-comercio': _comercioId, 'If-None-Match': ?etag},
          {},
          null,
        )
        .timeout(_espera);
    if (respuesta.statusCode == HttpStatus.notModified) return RespuestaCatalogo(etag: etag);
    if (respuesta.statusCode >= HttpStatus.badRequest) {
      throw ApiException(respuesta.statusCode, utf8.decode(respuesta.bodyBytes));
    }
    final contenido = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (contenido is! Map<String, Object?>) throw const ServidorNoDisponible(0);
    return RespuestaCatalogo(contenido: contenido, etag: respuesta.headers['etag']);
  });

  Future<EstadoDeCuentaResponse> cuenta(String clienteId) => _conRed(() async {
    final cuenta = await _tiqueteras
        .consultarSaldoDelCliente(_comercioId, clienteId)
        .timeout(_espera);
    return _noNulo(cuenta);
  });

  /// [sinConexion]: la venta se hizo sin señal y llega después; el servidor respeta su
  /// hora y su precio.
  Future<VentaResponse> vender(VentaEnCaja v, {required bool sinConexion}) => _conRed(() async {
    final pedido = VentaRequest(
      ventaId: v.ventaId,
      clienteId: v.clienteId,
      tipoId: v.tipo.tipoId,
      precio: v.tipo.precio,
      pago: PagoRequest(medio: v.pago.medio, canal: v.pago.canal, referencia: v.pago.referencia),
      sinConexion: sinConexion,
      ocurridaEn: sinConexion ? v.ocurridaEn : null,
    );
    return _noNulo(await _ventas.venderTiquetera(_comercioId, pedido).timeout(_espera));
  });

  Future<List<MisTiqueterasResponse>> misTiqueteras() => _conRed(() async {
    return await _tiqueteras.consultarMisTiqueteras().timeout(_espera) ?? const [];
  });

  static T _noNulo<T>(T? valor) => valor ?? (throw const ServidorNoDisponible(0));

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}

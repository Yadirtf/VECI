import 'dart:async';

import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/sesion.dart';
import '../../domain/repositories/sesion_repository.dart';
import '../datasources/dispositivo_local.dart';

const _espera = Duration(seconds: 10);

/// Sesión contra la API con el cliente generado (SesionesApi y MiCuentaApi).
class SesionRepositoryImpl implements SesionRepository {
  /// [_cuentaCon] arma el API de Mi cuenta con un token dado (elegir negocio, salir).
  SesionRepositoryImpl(
    this._sesiones,
    this._cuentaCon,
    this._dispositivo, {
    DateTime Function()? ahora,
  }) : _ahora = ahora ?? DateTime.now;

  final SesionesApi _sesiones;
  final MiCuentaApi Function(String token) _cuentaCon;
  final DispositivoLocal _dispositivo;
  final DateTime Function() _ahora;

  @override
  Future<ResultadoIngreso> entrarConPin(String celular, String pin) => _llamar(() async {
    final pedido = IngresoConPinRequest(
      celular: celular,
      pin: pin,
      dispositivo: await _dispositivo.describir(),
    );
    final r = await _sesiones.entrarConPin(pedido).timeout(_espera);
    if (r == null) throw const ServidorNoDisponible(0);
    final sesion = r.sesion;
    if (sesion != null) return IngresoConSesion(_aSesion(sesion));
    return IngresoConCambioDePin(tokenCambio: r.tokenCambio ?? '', nombre: r.nombre);
  });

  @override
  Future<SesionAbierta> crearPinNuevo(String tokenCambio, String pinNuevo) => _llamar(() async {
    final pedido = PinNuevoRequest(
      tokenCambio: tokenCambio,
      pinNuevo: pinNuevo,
      dispositivo: await _dispositivo.describir(),
    );
    return _aSesion(await _exigir(_sesiones.crearPinNuevo(pedido)));
  });

  @override
  Future<SesionAbierta?> renovar(String tokenRenovacion) async {
    try {
      final pedido = RenovarSesionRequest(tokenRenovacion: tokenRenovacion);
      return _aSesion(await _exigir(_sesiones.renovarSesion(pedido)));
    } on Object catch (error) {
      final fallo = traducirError(error);
      if (fallo is PeticionRechazada && fallo.codigo == 401) return null;
      throw fallo;
    }
  }

  @override
  Future<void> elegirComercio(String tokenAcceso, String comercioId) => _llamar(() async {
    final pedido = ComercioActivoRequest(comercioId: comercioId);
    await _cuentaCon(tokenAcceso).elegirComercio(pedido).timeout(_espera);
  });

  @override
  Future<void> salir(String tokenAcceso) =>
      _llamar(() => SesionesApi(_cuentaCon(tokenAcceso).apiClient).salir().timeout(_espera));

  Future<T> _exigir<T>(Future<T?> llamada) async =>
      await llamada.timeout(_espera) ?? (throw const ServidorNoDisponible(0));

  Future<T> _llamar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }

  SesionAbierta _aSesion(SesionResponse r) => SesionAbierta(
    tokenAcceso: r.tokenAcceso,
    tokenRenovacion: r.tokenRenovacion,
    venceEn: _ahora().add(Duration(seconds: r.segundosAcceso.toInt())),
    nombre: r.usuario.nombre,
    espacios: [
      for (final e in r.espacios)
        Espacio(
          comercioId: e.comercioId,
          nombre: e.nombre,
          roles: e.roles,
          invitacionPendiente: e.invitacionPendiente,
        ),
    ],
  );
}

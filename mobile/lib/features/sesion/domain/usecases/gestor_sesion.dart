import 'dart:async';

import '../entities/estado_sesion.dart';
import '../entities/sesion.dart';
import '../reglas/reglas_ingreso.dart';
import '../repositories/sesion_repository.dart';

/// Margen para renovar antes de que el token venza en plena venta.
const _margen = Duration(seconds: 30);

/// Dueño de la sesión en el celular: la abre, la mantiene y avisa cada cambio.
///
/// El token de acceso vive en memoria; el de renovación, cifrado en el celular, así la
/// sesión de la caja sigue abierta aunque se cierre la app (HU-02-06). Si varias
/// peticiones encuentran el token vencido, se renueva una sola vez.
class GestorSesion {
  GestorSesion(this._repositorio, this._almacen, this._pendientes, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final SesionRepository _repositorio;
  final AlmacenSesion _almacen;
  final EventosPendientes _pendientes;
  final DateTime Function() _ahora;
  final _cambios = StreamController<EstadoSesion>.broadcast();
  EstadoSesion _estado = const SesionIniciando();
  Future<String?>? _renovando;

  EstadoSesion get estado => _estado;

  Stream<EstadoSesion> get cambios => _cambios.stream;

  /// Al abrir la app: con una sesión guardada entra de una, aun sin internet, y la
  /// renueva cuando haya señal.
  Future<void> iniciar() async {
    final guardada = await _almacen.leerSesion();
    if (guardada == null) return _cambiar(const SinSesion());
    final comercio = comercioInicial(guardada.espacios, await _almacen.leerComercio());
    _cambiar(SesionActiva(sesion: guardada, comercioId: comercio));
    await renovar().catchError((Object _) => null);
  }

  Future<void> entrarConPin(String celular, String pin) async {
    switch (await _repositorio.entrarConPin(celular, pin)) {
      case IngresoConSesion(:final sesion):
        await _abrir(sesion);
      case IngresoConCambioDePin(:final tokenCambio, :final nombre):
        _cambiar(CambioDePin(tokenCambio: tokenCambio, nombre: nombre));
    }
  }

  Future<void> crearPinNuevo(String pinNuevo) async {
    final actual = _estado;
    if (actual is! CambioDePin) return;
    await _abrir(await _repositorio.crearPinNuevo(actual.tokenCambio, pinNuevo));
  }

  /// Con la sesión que devuelve el registro del cliente (HU-04-01): entra de una vez.
  Future<void> entrarConSesionNueva(SesionAbierta sesion) => _abrir(sesion);

  /// Elige el negocio: el servidor registra el celular y acepta la invitación pendiente.
  Future<void> elegirComercio(String comercioId) async {
    final token = await tokenVigente();
    final actual = _estado;
    if (token == null || actual is! SesionActiva) return;
    await _repositorio.elegirComercio(token, comercioId);
    await _almacen.guardarComercio(comercioId);
    _cambiar(SesionActiva(sesion: actual.sesion, comercioId: comercioId));
  }

  /// Tras registrar un negocio: renueva la sesión para traerlo en la lista y lo deja activo.
  Future<void> estrenarNegocio(String comercioId) async {
    await renovar();
    await elegirComercio(comercioId);
  }

  Future<void> cambiarDeNegocio() async {
    final actual = _estado;
    if (actual is! SesionActiva) return;
    await _almacen.guardarComercio(null);
    _cambiar(SesionActiva(sesion: actual.sesion, comercioId: null));
  }

  /// Token listo para usar; lo renueva antes si está por vencer. null = hay que entrar.
  Future<String?> tokenVigente() async {
    final actual = _estado;
    if (actual is! SesionActiva) return null;
    final quedan = actual.sesion.venceEn.difference(_ahora());
    return quedan > _margen ? actual.sesion.tokenAcceso : renovar();
  }

  Future<String?> renovar() => _renovando ??= _renovarUnaVez().whenComplete(() {
    _renovando = null;
  });

  Future<void> salir() async {
    final actual = _estado;
    if (actual is SesionActiva) {
      await _repositorio.salir(actual.sesion.tokenAcceso).catchError((Object _) {});
    }
    await _olvidar();
    _cambiar(const SinSesion());
  }

  Future<void> cerrar() => _cambios.close();

  /// Sin señal lanza el fallo y deja la sesión como está: la caja sigue trabajando.
  Future<String?> _renovarUnaVez() async {
    final guardada = await _almacen.leerSesion();
    final sesion = guardada == null ? null : await _repositorio.renovar(guardada.tokenRenovacion);
    if (sesion == null) {
      await _cerradaDesdeOtroLado(teniaSesion: guardada != null);
      return null;
    }
    await _abrir(sesion);
    return sesion.tokenAcceso;
  }

  Future<void> _cerradaDesdeOtroLado({required bool teniaSesion}) async {
    await _olvidar();
    final aviso = teniaSesion ? avisoDeSesionCerrada(await _pendientes.contar()) : null;
    _cambiar(SinSesion(aviso: aviso));
  }

  Future<void> _abrir(SesionAbierta sesion) async {
    await _almacen.guardarSesion(sesion);
    final actual = _estado;
    final anterior = actual is SesionActiva ? actual.comercioId : await _almacen.leerComercio();
    final comercio = comercioInicial(sesion.espacios, anterior);
    _cambiar(SesionActiva(sesion: sesion, comercioId: comercio));
  }

  Future<void> _olvidar() async {
    await _almacen.guardarSesion(null);
    await _almacen.guardarComercio(null);
  }

  void _cambiar(EstadoSesion nuevo) {
    _estado = nuevo;
    if (!_cambios.isClosed) _cambios.add(nuevo);
  }
}

import '../../features/sesion/domain/entities/estado_sesion.dart';
import 'rutas.dart';

/// A dónde debe ir la persona según su sesión; null = puede quedarse donde está.
String? redirigir(EstadoSesion estado, String ubicacion) {
  final destino = switch (estado) {
    SesionIniciando() => Rutas.cargando,
    SinSesion() => Rutas.sinSesion.contains(ubicacion) ? null : Rutas.entrar,
    CambioDePin() => Rutas.pinNuevo,
    // Cualquiera con sesión puede pedir el registro de su negocio (ADR-0019).
    SesionActiva() when Rutas.deLaCuenta.contains(ubicacion) => null,
    SesionActiva(soloCliente: true) => _delCliente(estado, ubicacion),
    SesionActiva(comercioId: null) => Rutas.negocio,
    SesionActiva() => Rutas.deIngreso.contains(ubicacion) ? Rutas.inicio : null,
  };
  return destino == ubicacion ? null : destino;
}

/// Quien solo es cliente no elige negocio ni ve la caja: su inicio es Mi QR mientras no
/// sea cliente de ningún negocio y, después, Tus negocios (HU-04-02, HU-04-03).
String? _delCliente(SesionActiva estado, String ubicacion) {
  // Recién registrado se queda en la bienvenida.
  const permitidas = [Rutas.registro, Rutas.politica];
  if (Rutas.esDelCliente(ubicacion) || permitidas.contains(ubicacion)) return null;
  return estado.sesion.espacios.isEmpty ? Rutas.miQr : Rutas.tusNegocios;
}

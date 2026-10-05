import '../../features/sesion/domain/entities/estado_sesion.dart';
import 'rutas.dart';

/// A dónde debe ir la persona según su sesión; null = puede quedarse donde está.
String? redirigir(EstadoSesion estado, String ubicacion) {
  final destino = switch (estado) {
    SesionIniciando() => Rutas.cargando,
    SinSesion() => Rutas.sinSesion.contains(ubicacion) ? null : Rutas.entrar,
    CambioDePin() => Rutas.pinNuevo,
    SesionActiva(soloCliente: true) => _delCliente(estado, ubicacion),
    // Sin negocio puede elegir uno o registrar el suyo (HU-03-01).
    SesionActiva(comercioId: null) when ubicacion == Rutas.registrarNegocio => null,
    SesionActiva(comercioId: null) => Rutas.negocio,
    SesionActiva() => Rutas.deIngreso.contains(ubicacion) ? Rutas.inicio : null,
  };
  return destino == ubicacion ? null : destino;
}

/// Quien solo es cliente no elige negocio ni ve la caja: su inicio es Mi QR mientras no
/// sea cliente de ningún negocio y, después, Tus negocios (HU-04-02, HU-04-03).
String? _delCliente(SesionActiva estado, String ubicacion) {
  // Recién registrado se queda en la bienvenida; también puede registrar su negocio.
  const permitidas = [Rutas.registro, Rutas.politica, Rutas.registrarNegocio];
  if (Rutas.esDelCliente(ubicacion) || permitidas.contains(ubicacion)) return null;
  return estado.sesion.espacios.isEmpty ? Rutas.miQr : Rutas.tusNegocios;
}

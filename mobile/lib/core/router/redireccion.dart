import '../../features/sesion/domain/entities/estado_sesion.dart';
import 'rutas.dart';

/// A dónde debe ir la persona según su sesión; null = puede quedarse donde está.
String? redirigir(EstadoSesion estado, String ubicacion) {
  final destino = switch (estado) {
    SesionIniciando() => Rutas.cargando,
    SinSesion() => Rutas.entrar,
    CambioDePin() => Rutas.pinNuevo,
    // Sin negocio puede elegir uno o registrar el suyo (HU-03-01).
    SesionActiva(comercioId: null) when ubicacion == Rutas.registrarNegocio => null,
    SesionActiva(comercioId: null) => Rutas.negocio,
    SesionActiva() => Rutas.deIngreso.contains(ubicacion) ? Rutas.inicio : null,
  };
  return destino == ubicacion ? null : destino;
}

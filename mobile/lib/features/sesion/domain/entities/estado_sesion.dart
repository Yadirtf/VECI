import 'sesion.dart';

/// En qué punto está la persona: la app muestra una pantalla distinta para cada uno.
sealed class EstadoSesion {
  const EstadoSesion();
}

final class SesionIniciando extends EstadoSesion {
  const SesionIniciando();
}

/// Debe entrar con celular y PIN. [aviso] explica por qué se cerró, si fue desde otro lado.
final class SinSesion extends EstadoSesion {
  const SinSesion({this.aviso});

  final String? aviso;
}

final class CambioDePin extends EstadoSesion {
  const CambioDePin({required this.tokenCambio, required this.nombre});

  final String tokenCambio;
  final String nombre;
}

final class SesionActiva extends EstadoSesion {
  const SesionActiva({required this.sesion, required this.comercioId});

  final SesionAbierta sesion;

  /// null mientras no haya elegido con cuál negocio trabaja.
  final String? comercioId;

  Espacio? get negocio {
    for (final espacio in sesion.espacios) {
      if (espacio.comercioId == comercioId) return espacio;
    }
    return null;
  }
}

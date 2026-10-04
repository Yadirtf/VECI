/// Fallos comunes que la presentación traduce a mensajes en tono VECI.
sealed class Fallo implements Exception {
  const Fallo();
}

/// No hay internet o el servidor no respondió a tiempo.
final class SinConexion extends Fallo {
  const SinConexion();
}

/// El servidor respondió con un error (5xx) o una respuesta inesperada.
final class ServidorNoDisponible extends Fallo {
  const ServidorNoDisponible(this.codigo);

  final int codigo;
}

/// El servidor rechazó la petición: sin sesión, sin acceso o datos inválidos (4xx).
final class PeticionRechazada extends Fallo {
  const PeticionRechazada(this.codigo, this.mensaje, {this.motivo});

  /// Código HTTP (401, 403, 409...).
  final int codigo;

  /// Mensaje en tono VECI que manda la API; se puede mostrar tal cual.
  final String mensaje;

  /// Código de la API para el programa (CREDENCIALES_INCORRECTAS, SESION_CERRADA...).
  final String? motivo;
}

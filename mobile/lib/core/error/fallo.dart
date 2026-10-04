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
  const PeticionRechazada(this.codigo, this.mensaje);

  final int codigo;
  final String mensaje;
}

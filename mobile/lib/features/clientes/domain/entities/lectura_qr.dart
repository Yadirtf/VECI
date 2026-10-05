import 'ficha_cliente.dart';

/// Persona encontrada por su QR o su documento, para confirmar antes de afiliar.
class PersonaEncontrada {
  const PersonaEncontrada({
    required this.personaId,
    required this.nombre,
    required this.documento,
    this.clienteId,
  });

  final String personaId;

  /// "Luz Marina C.".
  final String nombre;

  /// "****5678".
  final String documento;

  /// Si ya es cliente de este negocio, su id.
  final String? clienteId;
}

/// Lo que la caja sabe después de leer un QR (POST /clientes/qr).
sealed class LecturaQr {
  const LecturaQr();
}

/// Persona de VECI que aún no es cliente: se confirma y se afilia.
final class PorAfiliar extends LecturaQr {
  const PorAfiliar(this.persona);

  final PersonaEncontrada persona;
}

/// Ya es cliente de este negocio: se abre su ficha.
final class YaEsCliente extends LecturaQr {
  const YaEsCliente(this.ficha);

  final FichaCliente ficha;
}

/// El cliente cambió su QR; el que mostró ya no sirve.
final class QrCambiado extends LecturaQr {
  const QrCambiado();
}

/// Es el QR de este cliente en otro negocio.
final class QrDeOtroNegocio extends LecturaQr {
  const QrDeOtroNegocio();
}

/// No es un QR de VECI.
final class QrAjeno extends LecturaQr {
  const QrAjeno();
}

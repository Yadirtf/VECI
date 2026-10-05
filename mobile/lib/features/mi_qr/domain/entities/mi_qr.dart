/// Mi QR personal (HU-04-02): solo un token firmado, sin datos. [version] sube cada
/// vez que la persona lo cambia; el anterior deja de servir.
class MiQr {
  const MiQr({required this.token, required this.version, required this.emitidoEn});

  final String token;
  final int version;
  final DateTime emitidoEn;
}

/// Mi QR en un negocio donde ya soy cliente.
class QrEnNegocio {
  const QrEnNegocio({required this.token, required this.version});

  final String token;
  final int version;
}

/// Negocio donde la persona es cliente (HU-04-03).
class NegocioDondeSoyCliente {
  const NegocioDondeSoyCliente({
    required this.comercioId,
    required this.nombre,
    required this.tipoNegocio,
    required this.afiliadoEn,
    this.qr,
  });

  final String comercioId;
  final String nombre;
  final String tipoNegocio;
  final DateTime afiliadoEn;

  /// null mientras el negocio no tenga QR para esta persona.
  final QrEnNegocio? qr;
}

/// Lo que se muestra y si es la copia del celular porque no hubo señal.
class VistaGuardada<T> {
  const VistaGuardada(this.valor, {this.sinSenal = false});

  final T valor;
  final bool sinSenal;
}

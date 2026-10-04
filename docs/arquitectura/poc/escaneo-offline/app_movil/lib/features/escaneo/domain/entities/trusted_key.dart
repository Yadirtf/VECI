/// Clave pública de un comercio guardada en el celular.
class TrustedKey {
  const TrustedKey({required this.keyId, required this.publicKey, this.retiredAt});

  final String keyId;
  final List<int> publicKey;

  /// Una clave retirada sigue verificando los QR que firmó (ADR-0005).
  final DateTime? retiredAt;
}

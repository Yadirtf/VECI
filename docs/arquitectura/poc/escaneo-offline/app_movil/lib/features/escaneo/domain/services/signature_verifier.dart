/// Verifica una firma Ed25519 con la clave pública del comercio.
abstract interface class SignatureVerifier {
  Future<bool> verify({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  });
}

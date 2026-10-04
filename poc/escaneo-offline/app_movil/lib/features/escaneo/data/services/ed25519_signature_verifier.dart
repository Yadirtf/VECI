import 'package:cryptography/cryptography.dart';

import '../../domain/services/signature_verifier.dart';

/// Verificación Ed25519 con el paquete `cryptography` (Dart puro, sin red).
class Ed25519SignatureVerifier implements SignatureVerifier {
  Ed25519SignatureVerifier() : _algorithm = Ed25519();

  final Ed25519 _algorithm;

  @override
  Future<bool> verify({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  }) {
    if (signature.length != 64 || publicKey.length != 32) return Future.value(false);
    final key = SimplePublicKey(publicKey, type: KeyPairType.ed25519);
    return _algorithm.verify(message, signature: Signature(signature, publicKey: key));
  }
}

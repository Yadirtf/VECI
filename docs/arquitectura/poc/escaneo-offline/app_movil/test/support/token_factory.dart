import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Firma tokens con el mismo formato que el servidor (qr-token.codec.ts).
class TokenFactory {
  TokenFactory._(this._keyPair, this.publicKey);

  static Future<TokenFactory> create() async {
    final keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    return TokenFactory._(keyPair, publicKey.bytes);
  }

  final SimpleKeyPair _keyPair;
  final List<int> publicKey;

  Future<String> sign({
    required String tenantId,
    String keyId = 'k1',
    String affiliationId = '01920000-0000-7000-8000-0000000000aa',
    String qrCodeId = '01920000-0000-7000-8000-0000000000bb',
    int version = 1,
  }) async {
    final json = jsonEncode({
      'k': keyId,
      't': tenantId,
      'a': affiliationId,
      'q': qrCodeId,
      'v': version,
    });
    final signedPart = 'V1.${base64Url.encode(utf8.encode(json)).replaceAll('=', '')}';
    final signature = await Ed25519().sign(ascii.encode(signedPart), keyPair: _keyPair);
    return '$signedPart.${base64Url.encode(signature.bytes).replaceAll('=', '')}';
  }
}

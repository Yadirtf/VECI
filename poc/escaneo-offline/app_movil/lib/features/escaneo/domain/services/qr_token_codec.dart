import 'dart:convert';

import '../entities/qr_payload.dart';
import '../entities/signed_qr_token.dart';

/// Lee el token del QR (versión 1):
///
///     V1.<base64url(JSON)>.<base64url(firma Ed25519)>
///
/// JSON con llaves cortas: k (clave), t (comercio), a (afiliación),
/// q (id del QR), v (versión). El servidor lo arma en qr-token.codec.ts.
class QrTokenCodec {
  const QrTokenCodec();

  static const prefix = 'V1';

  /// Devuelve null si el texto no es un token de VECI bien formado.
  SignedQrToken? parse(String raw) {
    final parts = raw.trim().split('.');
    if (parts.length != 3 || parts[0] != prefix) return null;
    try {
      final json = jsonDecode(utf8.decode(_decode(parts[1])));
      if (json is! Map<String, dynamic>) return null;
      return SignedQrToken(
        signedPart: '${parts[0]}.${parts[1]}',
        signature: _decode(parts[2]),
        payload: _payload(json),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  QrPayload _payload(Map<String, dynamic> json) => QrPayload(
    keyId: json['k'] as String,
    tenantId: json['t'] as String,
    affiliationId: json['a'] as String,
    qrCodeId: json['q'] as String,
    version: json['v'] as int,
  );

  List<int> _decode(String part) => base64Url.decode(base64Url.normalize(part));
}

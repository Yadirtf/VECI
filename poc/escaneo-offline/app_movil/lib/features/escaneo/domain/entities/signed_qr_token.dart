import 'qr_payload.dart';

/// Token leído del QR, separado en la parte firmada y la firma.
class SignedQrToken {
  const SignedQrToken({required this.signedPart, required this.signature, required this.payload});

  /// Texto `V1.<base64url(JSON)>` cuyos bytes ASCII cubre la firma.
  final String signedPart;
  final List<int> signature;
  final QrPayload payload;
}

import 'dart:convert';

import '../entities/qr_payload.dart';
import '../entities/scan_rejection.dart';
import '../repositories/offline_trust_repository.dart';
import '../services/qr_token_codec.dart';
import '../services/signature_verifier.dart';

/// QR válido para este comercio, o el motivo por el que no lo es.
class QrValidation {
  const QrValidation.valid(QrPayload this.payload) : rejection = null;
  const QrValidation.rejected(ScanRejection this.rejection) : payload = null;

  final QrPayload? payload;
  final ScanRejection? rejection;
}

/// Valida un QR sin internet: formato, comercio, revocación y firma Ed25519.
class ValidarQr {
  const ValidarQr({
    required this._trust,
    required this._verifier,
    this._codec = const QrTokenCodec(),
  });

  final OfflineTrustRepository _trust;
  final SignatureVerifier _verifier;
  final QrTokenCodec _codec;

  Future<QrValidation> call(String raw) async {
    final token = _codec.parse(raw);
    if (token == null) return const QrValidation.rejected(ScanRejection.formatoInvalido);
    final tenantId = await _trust.currentTenantId();
    if (tenantId == null) return const QrValidation.rejected(ScanRejection.sinDatosOffline);
    final qr = token.payload;
    if (qr.tenantId != tenantId) return const QrValidation.rejected(ScanRejection.otroComercio);
    final key = await _trust.findKey(tenantId: tenantId, keyId: qr.keyId);
    if (key == null) return const QrValidation.rejected(ScanRejection.claveDesconocida);
    final authentic = await _verifier.verify(
      message: ascii.encode(token.signedPart),
      signature: token.signature,
      publicKey: key.publicKey,
    );
    if (!authentic) return const QrValidation.rejected(ScanRejection.firmaInvalida);
    if (await _trust.isRevoked(qr.qrCodeId)) {
      return const QrValidation.rejected(ScanRejection.qrRevocado);
    }
    return QrValidation.valid(qr);
  }
}

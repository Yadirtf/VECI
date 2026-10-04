/// Contenido firmado del QR del cliente en un comercio
/// (customers.affiliation_qr_codes, ADR-0005). Sin saldo ni datos personales.
class QrPayload {
  const QrPayload({
    required this.keyId,
    required this.tenantId,
    required this.affiliationId,
    required this.qrCodeId,
    required this.version,
  });

  final String keyId;
  final String tenantId;
  final String affiliationId;
  final String qrCodeId;
  final int version;
}

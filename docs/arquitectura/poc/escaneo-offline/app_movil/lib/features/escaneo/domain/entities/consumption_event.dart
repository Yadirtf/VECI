/// Consumo registrado en el celular (será ledger.events + consumptions.consumptions).
class ConsumptionEvent {
  const ConsumptionEvent({
    required this.id,
    required this.occurredAt,
    required this.tenantId,
    required this.affiliationId,
    required this.affiliationQrCodeId,
    required this.qrVersion,
    this.unitsRequested = 1,
  });

  /// UUID v7 generado aquí: el servidor lo usa como llave de idempotencia.
  final String id;

  /// Hora real del consumo, aunque se sincronice días después (RF-OFF-06).
  final DateTime occurredAt;
  final String tenantId;
  final String affiliationId;
  final String affiliationQrCodeId;
  final int qrVersion;
  final int unitsRequested;
}

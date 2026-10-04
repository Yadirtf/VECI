/// Respuesta del servidor para un evento (HU-07-03).
class DeliveryResult {
  const DeliveryResult({
    required this.eventId,
    required this.statusCode,
    this.rejectionReasonCode,
    this.replayed = false,
  });

  final String eventId;

  /// APPLIED o REJECTED (sync.inbound_event_statuses).
  final String statusCode;
  final String? rejectionReasonCode;

  /// El servidor ya lo tenía: este envío era un reintento.
  final bool replayed;
}

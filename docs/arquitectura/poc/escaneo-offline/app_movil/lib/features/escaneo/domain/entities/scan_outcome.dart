import 'qr_payload.dart';
import 'scan_rejection.dart';

/// Resultado de escanear un QR en la caja.
sealed class ScanOutcome {
  const ScanOutcome();
}

/// El QR es válido y el consumo quedó guardado en la bandeja de salida.
class ScanAccepted extends ScanOutcome {
  const ScanAccepted({required this.eventId, required this.occurredAt, required this.qr});

  final String eventId;
  final DateTime occurredAt;
  final QrPayload qr;
}

class ScanRejected extends ScanOutcome {
  const ScanRejected(this.reason);

  final ScanRejection reason;
}

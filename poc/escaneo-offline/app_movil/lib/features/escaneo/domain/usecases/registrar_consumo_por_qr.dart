import '../../../../core/domain/clock.dart';
import '../../../../core/domain/id_generator.dart';
import '../entities/consumption_event.dart';
import '../entities/scan_outcome.dart';
import '../repositories/consumption_outbox.dart';
import 'validar_qr.dart';

/// Escaneo en la caja: valida el QR y, si sirve, guarda el consumo en la
/// bandeja de salida con su id y su hora real. Funciona igual sin internet.
class RegistrarConsumoPorQr {
  const RegistrarConsumoPorQr({
    required this._validar,
    required this._outbox,
    required this._ids,
    required this._clock,
  });

  final ValidarQr _validar;
  final ConsumptionOutbox _outbox;
  final IdGenerator _ids;
  final Clock _clock;

  Future<ScanOutcome> call(String raw) async {
    final occurredAt = _clock.now();
    final validation = await _validar(raw);
    final qr = validation.payload;
    if (qr == null) return ScanRejected(validation.rejection!);
    final event = ConsumptionEvent(
      id: _ids.next(),
      occurredAt: occurredAt,
      tenantId: qr.tenantId,
      affiliationId: qr.affiliationId,
      affiliationQrCodeId: qr.qrCodeId,
      qrVersion: qr.version,
    );
    await _outbox.register(event);
    return ScanAccepted(eventId: event.id, occurredAt: occurredAt, qr: qr);
  }
}

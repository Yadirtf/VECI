import '../../../../core/domain/clock.dart';
import '../../../../core/domain/id_generator.dart';
import '../entities/consumption_event.dart';
import '../repositories/consumption_outbox.dart';
import '../repositories/offline_trust_repository.dart';

/// Prueba de carga de la HU-00-04: simula [count] consumos hechos sin
/// internet durante [span] (por defecto 7 días, RNF-CON-01).
class GenerarConsumosDePrueba {
  const GenerarConsumosDePrueba({
    required this._outbox,
    required this._trust,
    required this._ids,
    required this._clock,
  });

  final ConsumptionOutbox _outbox;
  final OfflineTrustRepository _trust;
  final IdGenerator _ids;
  final Clock _clock;

  /// Devuelve cuántos generó; 0 si faltan los datos offline.
  Future<int> call({int count = 1000, Duration span = const Duration(days: 7)}) async {
    final tenantId = await _trust.currentTenantId();
    if (tenantId == null || count <= 0) return 0;
    final end = _clock.now();
    final step = span ~/ count;
    final events = List.generate(count, (i) {
      return ConsumptionEvent(
        id: _ids.next(),
        occurredAt: end.subtract(span).add(step * i),
        tenantId: tenantId,
        affiliationId: _ids.next(),
        affiliationQrCodeId: _ids.next(),
        qrVersion: 1,
      );
    });
    await _outbox.registerAll(events);
    return count;
  }
}

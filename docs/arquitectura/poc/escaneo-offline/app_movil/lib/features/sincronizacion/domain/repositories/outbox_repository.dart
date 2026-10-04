import '../entities/delivery_result.dart';
import '../entities/outbox_counts.dart';
import '../entities/outbox_item.dart';

abstract interface class OutboxRepository {
  /// Siguiente lote en orden de hora real, o null si no hay pendientes.
  /// Si un lote quedó sin respuesta, lo devuelve de nuevo con el mismo id.
  Future<OutboxBatch?> claimNextBatch(int size);

  Future<void> registerAttempt(String batchId);

  Future<void> applyResults(List<DeliveryResult> results);

  Stream<OutboxCounts> watchCounts();

  Future<void> clear();
}

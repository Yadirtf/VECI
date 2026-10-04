import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables/outbox_events_table.dart';

part 'outbox_dao.g.dart';

/// Código local de un evento que aún no tiene respuesta del servidor.
const outboxPendingCode = 'PENDING';

/// Resultado del servidor para un evento enviado.
class OutboxDelivery {
  const OutboxDelivery(this.eventId, this.statusCode, this.rejectionReasonCode);

  final String eventId;
  final String statusCode;
  final String? rejectionReasonCode;
}

/// Acceso a la bandeja de salida. Lo usan escaneo (escribe) y
/// sincronización (lee y marca entregas).
@DriftAccessor(tables: [OutboxEvents])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.attachedDatabase);

  Future<void> enqueue(OutboxEventsCompanion event) => into(outboxEvents).insert(event);

  Future<void> enqueueAll(List<OutboxEventsCompanion> events) =>
      batch((b) => b.insertAll(outboxEvents, events));

  /// Devuelve el lote pendiente a enviar. Si un envío anterior quedó sin
  /// respuesta, devuelve ese mismo lote (mismo id y mismos eventos).
  Future<List<OutboxEvent>> claimNextBatch(int size, String newBatchId) {
    return transaction(() async {
      final unanswered = await _pending(onlyAssigned: true, limit: size);
      if (unanswered.isNotEmpty) return _sameBatch(unanswered);
      final next = await _pending(onlyAssigned: false, limit: size);
      if (next.isEmpty) return next;
      await (update(outboxEvents)..where((e) => e.id.isIn(next.map((e) => e.id)))).write(
        OutboxEventsCompanion(batchId: Value(newBatchId)),
      );
      return [for (final e in next) e.copyWith(batchId: Value(newBatchId))];
    });
  }

  Future<void> registerAttempt(String batchId) => customUpdate(
    'UPDATE outbox_events SET attempts = attempts + 1 WHERE batch_id = ?',
    variables: [Variable.withString(batchId)],
    updates: {outboxEvents},
  );

  Future<void> applyDeliveries(List<OutboxDelivery> deliveries, DateTime at) {
    return batch((b) {
      for (final d in deliveries) {
        b.update(
          outboxEvents,
          OutboxEventsCompanion(
            statusCode: Value(d.statusCode),
            rejectionReasonCode: Value(d.rejectionReasonCode),
            deliveredAt: Value(at),
          ),
          where: (e) => e.id.equals(d.eventId),
        );
      }
    });
  }

  /// Cantidad de eventos por código de estado, para la pantalla y las pruebas.
  Stream<Map<String, int>> watchCountsByStatus() {
    final count = outboxEvents.id.count();
    final query = selectOnly(outboxEvents)
      ..addColumns([outboxEvents.statusCode, count])
      ..groupBy([outboxEvents.statusCode]);
    return query.watch().map(
      (rows) => {for (final r in rows) r.read(outboxEvents.statusCode)!: r.read(count)!},
    );
  }

  Future<int> clearAll() => delete(outboxEvents).go();

  Future<List<OutboxEvent>> _pending({required bool onlyAssigned, required int limit}) {
    final query = select(outboxEvents)
      ..where((e) => e.statusCode.equals(outboxPendingCode))
      ..where((e) => onlyAssigned ? e.batchId.isNotNull() : e.batchId.isNull())
      ..orderBy([
        (e) => OrderingTerm(expression: e.occurredAt),
        (e) => OrderingTerm(expression: e.id),
      ])
      ..limit(limit);
    return query.get();
  }

  /// Si quedaron varios lotes sin respuesta, se toma solo el más antiguo.
  List<OutboxEvent> _sameBatch(List<OutboxEvent> rows) {
    final batchId = rows.first.batchId;
    return rows.where((e) => e.batchId == batchId).toList();
  }
}

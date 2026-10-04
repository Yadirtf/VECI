import 'package:drift/drift.dart';

/// Bandeja de salida: cada venta o consumo hecho en el celular, con su id
/// UUID v7 y su hora real, hasta que el servidor confirma que lo recibió.
@TableIndex(name: 'outbox_pending_ix', columns: {#statusCode, #occurredAt})
class OutboxEvents extends Table {
  /// UUID v7 generado en el celular; será sync.inbound_events.id en el servidor.
  TextColumn get id => text()();

  /// Código de sync.inbound_event_kinds (CONSUMPTION, SALE...).
  TextColumn get kindCode => text()();

  /// Hora real en que ocurrió, en UTC.
  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get payloadJson => text()();

  /// PENDING mientras no hay respuesta; luego el código que devolvió el
  /// servidor (APPLIED, REJECTED), igual que sync.inbound_event_statuses.
  TextColumn get statusCode => text()();

  TextColumn get rejectionReasonCode => text().nullable()();

  /// Lote al que se asignó. Si el envío falla, se reenvía el mismo lote.
  TextColumn get batchId => text().nullable()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get deliveredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

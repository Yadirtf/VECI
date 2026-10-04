/// Evento de la bandeja de salida listo para viajar al servidor.
class OutboxItem {
  const OutboxItem({
    required this.id,
    required this.kindCode,
    required this.occurredAt,
    required this.payload,
  });

  final String id;
  final String kindCode;
  final DateTime occurredAt;
  final Map<String, Object?> payload;
}

/// Lote con id propio. Si no hay respuesta, se reenvía igual (mismo id y eventos).
class OutboxBatch {
  const OutboxBatch({required this.batchId, required this.items});

  final String batchId;
  final List<OutboxItem> items;
}

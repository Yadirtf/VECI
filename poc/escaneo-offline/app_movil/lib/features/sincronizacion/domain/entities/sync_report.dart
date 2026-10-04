/// Resumen de una sincronización, para la pantalla y el informe de la HU-00-04.
class SyncReport {
  const SyncReport({
    required this.batchesSent,
    required this.eventsConfirmed,
    required this.replayedByServer,
    required this.rejectedByServer,
    required this.failedAttempts,
    required this.elapsed,
    required this.completed,
    this.lastError,
  });

  final int batchesSent;
  final int eventsConfirmed;

  /// Eventos que el servidor ya tenía (llegaron en un intento sin respuesta).
  final int replayedByServer;
  final int rejectedByServer;

  /// Envíos que no recibieron respuesta (corte de red o servidor caído).
  final int failedAttempts;
  final Duration elapsed;

  /// false si quedaron eventos pendientes porque la red no volvió.
  final bool completed;
  final String? lastError;
}

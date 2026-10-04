import '../entities/consumption_event.dart';

/// Guarda el consumo en la bandeja de salida local; nunca llama a la red.
abstract interface class ConsumptionOutbox {
  Future<void> register(ConsumptionEvent event);

  /// Inserta muchos consumos en una sola transacción (prueba de carga).
  Future<void> registerAll(List<ConsumptionEvent> events);
}

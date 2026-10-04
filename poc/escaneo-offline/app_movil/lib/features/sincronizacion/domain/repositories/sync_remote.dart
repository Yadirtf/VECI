import '../entities/delivery_result.dart';
import '../entities/offline_data.dart';
import '../entities/outbox_item.dart';

/// Opciones de la prueba de concepto para forzar cortes de red.
class SendOptions {
  const SendOptions({required this.deviceId, required this.tenantId, this.simulatedCutRate = 0});

  final String deviceId;
  final String tenantId;

  /// Fracción de lotes cuya respuesta el servidor corta a propósito.
  final double simulatedCutRate;
}

/// Servidor de VECI. Lanza NetworkFailure si no hay respuesta.
abstract interface class SyncRemote {
  Future<List<DeliveryResult>> sendBatch(OutboxBatch batch, SendOptions options);

  Future<OfflineData> fetchOfflineData();

  Future<Map<String, num>> fetchServerStats();

  Future<void> resetServer();
}

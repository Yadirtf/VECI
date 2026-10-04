import '../entities/offline_data.dart';

/// Identidad del celular y datos offline guardados.
abstract interface class LocalSyncState {
  /// Id del dispositivo (identity.devices). Se crea la primera vez.
  Future<String> deviceId();

  Future<String?> tenantId();

  /// Reemplaza claves y revocados del comercio en una sola transacción.
  Future<void> saveOfflineData(OfflineData data, DateTime pulledAt);
}

import '../entities/trusted_key.dart';

/// Lo que la caja necesita para confiar en un QR sin internet.
abstract interface class OfflineTrustRepository {
  /// Comercio del cajero, o null si nunca bajó los datos offline.
  Future<String?> currentTenantId();

  Future<TrustedKey?> findKey({required String tenantId, required String keyId});

  Future<bool> isRevoked(String qrCodeId);
}

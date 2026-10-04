import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/local_settings_dao.dart';
import '../../../../core/database/setting_keys.dart';
import '../../domain/entities/trusted_key.dart';
import '../../domain/repositories/offline_trust_repository.dart';

/// Lee de SQLite las claves y revocaciones que bajaron con internet.
class OfflineTrustRepositoryImpl implements OfflineTrustRepository {
  OfflineTrustRepositoryImpl(this._db) : _settings = LocalSettingsDao(_db);

  final AppDatabase _db;
  final LocalSettingsDao _settings;

  @override
  Future<String?> currentTenantId() => _settings.read(SettingKeys.tenantId);

  @override
  Future<TrustedKey?> findKey({required String tenantId, required String keyId}) async {
    final query = _db.select(_db.signingKeys)
      ..where((k) => k.tenantId.equals(tenantId) & k.keyId.equals(keyId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return TrustedKey(keyId: row.keyId, publicKey: row.publicKey, retiredAt: row.retiredAt);
  }

  @override
  Future<bool> isRevoked(String qrCodeId) async {
    final query = _db.select(_db.revokedQrCodes)..where((r) => r.qrCodeId.equals(qrCodeId));
    return await query.getSingleOrNull() != null;
  }
}

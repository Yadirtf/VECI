import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/local_settings_dao.dart';
import '../../../../core/database/setting_keys.dart';
import '../../../../core/domain/id_generator.dart';
import '../../domain/entities/offline_data.dart';
import '../../domain/repositories/local_sync_state.dart';

class LocalSyncStateImpl implements LocalSyncState {
  LocalSyncStateImpl({required AppDatabase db, required this._ids})
    : _db = db,
      _settings = LocalSettingsDao(db);

  final AppDatabase _db;
  final IdGenerator _ids;
  final LocalSettingsDao _settings;

  @override
  Future<String> deviceId() async {
    final existing = await _settings.read(SettingKeys.deviceId);
    if (existing != null) return existing;
    final created = _ids.next();
    await _settings.write(SettingKeys.deviceId, created);
    return created;
  }

  @override
  Future<String?> tenantId() => _settings.read(SettingKeys.tenantId);

  @override
  Future<void> saveOfflineData(OfflineData data, DateTime pulledAt) {
    return _db.transaction(() async {
      await (_db.delete(_db.signingKeys)..where((k) => k.tenantId.equals(data.tenantId))).go();
      await (_db.delete(_db.revokedQrCodes)..where((r) => r.tenantId.equals(data.tenantId))).go();
      await _db.batch((b) {
        b.insertAll(_db.signingKeys, [for (final k in data.keys) _keyRow(data.tenantId, k)]);
        b.insertAll(_db.revokedQrCodes, [
          for (final id in data.revokedQrCodeIds)
            RevokedQrCodesCompanion.insert(qrCodeId: id, tenantId: data.tenantId),
        ]);
      });
      await _settings.write(SettingKeys.tenantId, data.tenantId);
      await _settings.write(SettingKeys.offlineDataPulledAt, pulledAt.toUtc().toIso8601String());
    });
  }

  SigningKeysCompanion _keyRow(String tenantId, OfflineKey key) => SigningKeysCompanion.insert(
    tenantId: tenantId,
    keyId: key.keyId,
    algorithm: key.algorithm,
    publicKey: Uint8List.fromList(key.publicKey),
    retiredAt: Value(key.retiredAt),
  );
}

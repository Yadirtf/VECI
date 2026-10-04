import 'package:veci_poc_escaneo/core/domain/clock.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/trusted_key.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/repositories/offline_trust_repository.dart';

class FixedClock implements Clock {
  FixedClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

class FakeTrust implements OfflineTrustRepository {
  FakeTrust({this.tenantId, Map<String, List<int>>? keys, Set<String>? revoked})
    : keys = keys ?? {},
      revoked = revoked ?? {};

  String? tenantId;
  final Map<String, List<int>> keys;
  final Set<String> revoked;

  @override
  Future<String?> currentTenantId() async => tenantId;

  @override
  Future<TrustedKey?> findKey({required String tenantId, required String keyId}) async {
    final key = keys[keyId];
    return key == null ? null : TrustedKey(keyId: keyId, publicKey: key);
  }

  @override
  Future<bool> isRevoked(String qrCodeId) async => revoked.contains(qrCodeId);
}

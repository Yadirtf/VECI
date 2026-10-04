/// Lo que el celular baja con internet para validar QR sin él.
class OfflineData {
  const OfflineData({required this.tenantId, required this.keys, required this.revokedQrCodeIds});

  final String tenantId;
  final List<OfflineKey> keys;
  final List<String> revokedQrCodeIds;
}

class OfflineKey {
  const OfflineKey({
    required this.keyId,
    required this.algorithm,
    required this.publicKey,
    this.retiredAt,
  });

  final String keyId;
  final String algorithm;
  final List<int> publicKey;
  final DateTime? retiredAt;
}

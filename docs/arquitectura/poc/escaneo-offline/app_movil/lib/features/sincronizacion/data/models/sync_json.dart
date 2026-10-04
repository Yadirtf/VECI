import 'dart:convert';

import '../../domain/entities/delivery_result.dart';
import '../../domain/entities/offline_data.dart';
import '../../domain/entities/outbox_item.dart';
import '../../domain/repositories/sync_remote.dart';

/// Contrato JSON con POST /poc/sync/batches (snake_case, como el modelo de datos).
Map<String, Object?> batchToJson(OutboxBatch batch, SendOptions options) => {
  'batch_id': batch.batchId,
  'device_id': options.deviceId,
  'tenant_id': options.tenantId,
  'events': [
    for (final e in batch.items)
      {
        'id': e.id,
        'kind': e.kindCode,
        'occurred_at': e.occurredAt.toUtc().toIso8601String(),
        'payload': e.payload,
      },
  ],
};

List<DeliveryResult> resultsFromJson(String body) {
  final json = jsonDecode(body) as Map<String, dynamic>;
  return [
    for (final r in (json['results'] as List).cast<Map<String, dynamic>>())
      DeliveryResult(
        eventId: r['id'] as String,
        statusCode: r['status'] as String,
        rejectionReasonCode: r['rejectionReason'] as String?,
        replayed: r['replayed'] as bool? ?? false,
      ),
  ];
}

OfflineData offlineDataFromJson(String body) {
  final json = jsonDecode(body) as Map<String, dynamic>;
  return OfflineData(
    tenantId: json['tenantId'] as String,
    keys: [
      for (final k in (json['signingKeys'] as List).cast<Map<String, dynamic>>())
        OfflineKey(
          keyId: k['keyId'] as String,
          algorithm: k['algorithm'] as String,
          publicKey: base64.decode(k['publicKeyBase64'] as String),
          retiredAt: k['retiredAt'] == null ? null : DateTime.parse(k['retiredAt'] as String),
        ),
    ],
    revokedQrCodeIds: (json['revokedQrCodeIds'] as List).cast<String>(),
  );
}

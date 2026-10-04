import 'dart:convert';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/id_generator.dart';
import '../../../../core/sync/outbox_dao.dart';
import '../../domain/entities/delivery_result.dart';
import '../../domain/entities/outbox_counts.dart';
import '../../domain/entities/outbox_item.dart';
import '../../domain/repositories/outbox_repository.dart';

class OutboxRepositoryImpl implements OutboxRepository {
  const OutboxRepositoryImpl({required this._dao, required this._ids});

  final OutboxDao _dao;
  final IdGenerator _ids;

  @override
  Future<OutboxBatch?> claimNextBatch(int size) async {
    final rows = await _dao.claimNextBatch(size, _ids.next());
    if (rows.isEmpty) return null;
    return OutboxBatch(batchId: rows.first.batchId!, items: rows.map(_toItem).toList());
  }

  @override
  Future<void> registerAttempt(String batchId) => _dao.registerAttempt(batchId);

  @override
  Future<void> applyResults(List<DeliveryResult> results) => _dao.applyDeliveries([
    for (final r in results) OutboxDelivery(r.eventId, r.statusCode, r.rejectionReasonCode),
  ], DateTime.now().toUtc());

  @override
  Stream<OutboxCounts> watchCounts() => _dao.watchCountsByStatus().map(
    (byCode) => OutboxCounts(
      pending: byCode[outboxPendingCode] ?? 0,
      applied: byCode['APPLIED'] ?? 0,
      rejected: byCode['REJECTED'] ?? 0,
    ),
  );

  @override
  Future<void> clear() => _dao.clearAll();

  OutboxItem _toItem(OutboxEvent row) => OutboxItem(
    id: row.id,
    kindCode: row.kindCode,
    occurredAt: row.occurredAt,
    payload: (jsonDecode(row.payloadJson) as Map<String, dynamic>),
  );
}

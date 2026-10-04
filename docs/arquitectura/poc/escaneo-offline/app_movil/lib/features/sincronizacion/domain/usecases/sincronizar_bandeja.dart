import '../../../../core/error/network_failure.dart';
import '../entities/delivery_result.dart';
import '../entities/outbox_item.dart';
import '../entities/sync_report.dart';
import '../repositories/local_sync_state.dart';
import '../repositories/outbox_repository.dart';
import '../repositories/sync_remote.dart';
import 'sync_tally.dart';

/// Espera entre reintentos; las pruebas inyectan una que no espera.
typedef Backoff = Future<void> Function(int attempt);

Future<void> exponentialBackoff(int attempt) =>
    Future.delayed(Duration(milliseconds: 200 * (1 << attempt.clamp(0, 5))));

class SincronizarBandejaParams {
  const SincronizarBandejaParams({
    this.batchSize = 100,
    this.maxAttemptsPerBatch = 6,
    this.simulatedCutRate = 0,
  });

  final int batchSize;
  final int maxAttemptsPerBatch;
  final double simulatedCutRate;
}

/// Envía la bandeja de salida en lotes, en orden de hora real. Un lote sin
/// respuesta se reenvía igual; el servidor reconoce los ids y no duplica.
class SincronizarBandeja {
  const SincronizarBandeja({
    required this._outbox,
    required this._remote,
    required this._local,
    this._backoff = exponentialBackoff,
  });

  final OutboxRepository _outbox;
  final SyncRemote _remote;
  final LocalSyncState _local;
  final Backoff _backoff;

  Future<SyncReport> call([
    SincronizarBandejaParams params = const SincronizarBandejaParams(),
  ]) async {
    final tally = SyncTally()..start();
    final tenantId = await _local.tenantId();
    if (tenantId == null) return tally.finish(completed: false, error: 'Faltan los datos offline');
    final options = SendOptions(
      deviceId: await _local.deviceId(),
      tenantId: tenantId,
      simulatedCutRate: params.simulatedCutRate,
    );
    while (true) {
      final batch = await _outbox.claimNextBatch(params.batchSize);
      if (batch == null) return tally.finish(completed: true);
      final results = await _sendWithRetries(batch, options, params, tally);
      if (results == null) return tally.finish(completed: false);
      await _outbox.applyResults(results);
      tally.confirmed(results);
    }
  }

  Future<List<DeliveryResult>?> _sendWithRetries(
    OutboxBatch batch,
    SendOptions options,
    SincronizarBandejaParams params,
    SyncTally tally,
  ) async {
    for (var attempt = 0; attempt < params.maxAttemptsPerBatch; attempt++) {
      await _outbox.registerAttempt(batch.batchId);
      try {
        final results = await _remote.sendBatch(batch, options);
        tally.batchSent();
        return results;
      } on NetworkFailure catch (failure) {
        tally.failed(failure.message);
        await _backoff(attempt);
      }
    }
    return null;
  }
}

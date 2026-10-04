import '../entities/delivery_result.dart';
import '../entities/sync_report.dart';

/// Contadores de una sincronización en curso.
class SyncTally {
  final _watch = Stopwatch();
  int _batches = 0;
  int _confirmed = 0;
  int _replayed = 0;
  int _rejected = 0;
  int _failed = 0;
  String? _lastError;

  void start() => _watch.start();

  void batchSent() => _batches++;

  void failed(String message) {
    _failed++;
    _lastError = message;
  }

  void confirmed(List<DeliveryResult> results) {
    _confirmed += results.length;
    _replayed += results.where((r) => r.replayed).length;
    _rejected += results.where((r) => r.statusCode == 'REJECTED').length;
  }

  SyncReport finish({required bool completed, String? error}) {
    _watch.stop();
    return SyncReport(
      batchesSent: _batches,
      eventsConfirmed: _confirmed,
      replayedByServer: _replayed,
      rejectedByServer: _rejected,
      failedAttempts: _failed,
      elapsed: _watch.elapsed,
      completed: completed,
      lastError: error ?? _lastError,
    );
  }
}

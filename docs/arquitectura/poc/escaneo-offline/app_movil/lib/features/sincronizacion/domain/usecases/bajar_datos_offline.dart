import '../../../../core/domain/clock.dart';
import '../entities/offline_data.dart';
import '../repositories/local_sync_state.dart';
import '../repositories/sync_remote.dart';

/// Con internet: baja claves públicas y QR revocados para trabajar sin él.
class BajarDatosOffline {
  const BajarDatosOffline({required this._remote, required this._local, required this._clock});

  final SyncRemote _remote;
  final LocalSyncState _local;
  final Clock _clock;

  Future<OfflineData> call() async {
    final data = await _remote.fetchOfflineData();
    await _local.saveOfflineData(data, _clock.now());
    return data;
  }
}

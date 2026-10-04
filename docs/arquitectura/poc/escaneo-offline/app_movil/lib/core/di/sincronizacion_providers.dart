import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sincronizacion/data/datasources/http_sync_remote.dart';
import '../../features/sincronizacion/data/repositories/local_sync_state_impl.dart';
import '../../features/sincronizacion/data/repositories/outbox_repository_impl.dart';
import '../../features/sincronizacion/domain/entities/outbox_counts.dart';
import '../../features/sincronizacion/domain/repositories/local_sync_state.dart';
import '../../features/sincronizacion/domain/repositories/outbox_repository.dart';
import '../../features/sincronizacion/domain/repositories/sync_remote.dart';
import '../../features/sincronizacion/domain/usecases/bajar_datos_offline.dart';
import '../../features/sincronizacion/domain/usecases/sincronizar_bandeja.dart';
import 'core_providers.dart';

final syncRemoteProvider = Provider<SyncRemote>(
  (ref) => HttpSyncRemote(ref.watch(apiConfigProvider)),
);

final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) =>
      OutboxRepositoryImpl(dao: ref.watch(outboxDaoProvider), ids: ref.watch(idGeneratorProvider)),
);

final localSyncStateProvider = Provider<LocalSyncState>(
  (ref) =>
      LocalSyncStateImpl(db: ref.watch(appDatabaseProvider), ids: ref.watch(idGeneratorProvider)),
);

final bajarDatosOfflineProvider = Provider<BajarDatosOffline>(
  (ref) => BajarDatosOffline(
    remote: ref.watch(syncRemoteProvider),
    local: ref.watch(localSyncStateProvider),
    clock: ref.watch(clockProvider),
  ),
);

final sincronizarBandejaProvider = Provider<SincronizarBandeja>(
  (ref) => SincronizarBandeja(
    outbox: ref.watch(outboxRepositoryProvider),
    remote: ref.watch(syncRemoteProvider),
    local: ref.watch(localSyncStateProvider),
  ),
);

final outboxCountsProvider = StreamProvider<OutboxCounts>(
  (ref) => ref.watch(outboxRepositoryProvider).watchCounts(),
);

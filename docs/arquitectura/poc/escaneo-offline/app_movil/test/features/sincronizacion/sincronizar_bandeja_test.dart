import 'package:flutter_test/flutter_test.dart';
import 'package:veci_poc_escaneo/core/database/app_database.dart';
import 'package:veci_poc_escaneo/core/ids/uuid_v7_generator.dart';
import 'package:veci_poc_escaneo/core/sync/outbox_dao.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/repositories/consumption_outbox_impl.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/generar_consumos_de_prueba.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/data/repositories/local_sync_state_impl.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/data/repositories/outbox_repository_impl.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/entities/offline_data.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/entities/outbox_counts.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/usecases/sincronizar_bandeja.dart';

import '../../support/fake_server.dart';
import '../../support/fakes.dart';
import '../../support/test_database.dart';

const tenant = '01920000-0000-7000-8000-000000000001';

void main() {
  late AppDatabase db;
  late OutboxRepositoryImpl outbox;
  late LocalSyncStateImpl local;

  setUp(() async {
    db = memoryDatabase();
    final ids = UuidV7Generator();
    outbox = OutboxRepositoryImpl(dao: OutboxDao(db), ids: ids);
    local = LocalSyncStateImpl(db: db, ids: ids);
    await local.saveOfflineData(
      const OfflineData(tenantId: tenant, keys: [], revokedQrCodeIds: []),
      DateTime.now(),
    );
    final generar = GenerarConsumosDePrueba(
      outbox: ConsumptionOutboxImpl(OutboxDao(db)),
      trust: FakeTrust(tenantId: tenant),
      ids: ids,
      clock: FixedClock(DateTime.utc(2026, 10, 4, 12)),
    );
    expect(await generar(count: 1000), 1000);
  });

  tearDown(() => db.close());

  SincronizarBandeja sincronizar(FakeIdempotentServer server) =>
      SincronizarBandeja(outbox: outbox, remote: server, local: local, backoff: (_) async {});

  test('guarda 1.000 eventos offline con id y hora real', () async {
    final counts = await outbox.watchCounts().first;
    expect(counts.pending, 1000);
  });

  test('envía 1.000 eventos sin cortes: 10 lotes, sin duplicados', () async {
    final server = FakeIdempotentServer();
    final report = await sincronizar(server)();
    expect(report.completed, isTrue);
    expect(report.batchesSent, 10);
    expect(server.stored.length, 1000);
    expect(server.deliveries, 1000);
    expect((await outbox.watchCounts().first).applied, 1000);
  });

  test(
    'con 30 % de respuestas cortadas, el servidor termina con 1.000 únicos y en orden',
    () async {
      final server = FakeIdempotentServer(cutRate: 0.3);
      final report = await sincronizar(server)(
        const SincronizarBandejaParams(maxAttemptsPerBatch: 50),
      );
      expect(report.completed, isTrue);
      expect(server.cuts, greaterThan(0));
      expect(server.replays, server.cuts * 100);
      expect(server.stored.length, 1000);
      expect(server.appliedOrder, orderedEquals([...server.appliedOrder]..sort()));
      final counts = await outbox.watchCounts().first;
      expect(counts, isA<OutboxCounts>().having((c) => c.applied, 'applied', 1000));
    },
  );

  test('si la red no vuelve, nada se pierde y el siguiente intento termina el trabajo', () async {
    final caido = FakeIdempotentServer(cutRate: 1);
    final first = await sincronizar(caido)(const SincronizarBandejaParams(maxAttemptsPerBatch: 3));
    expect(first.completed, isFalse);
    expect((await outbox.watchCounts().first).pending, 1000);

    final server = FakeIdempotentServer()..stored.addAll(caido.stored);
    final second = await sincronizar(server)();
    expect(second.completed, isTrue);
    expect(second.replayedByServer, 100, reason: 'el primer lote ya había llegado');
    expect(server.stored.length, 1000);
  });
}

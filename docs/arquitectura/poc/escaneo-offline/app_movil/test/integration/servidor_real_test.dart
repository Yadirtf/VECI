// Prueba de punta a punta contra el servidor de prueba (servidor-prueba/).
// Se salta si no se define VECI_API:
//   VECI_API=http://localhost:3000 flutter test test/integration
@Tags(['servidor'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:veci_poc_escaneo/core/database/app_database.dart';
import 'package:veci_poc_escaneo/core/ids/system_clock.dart';
import 'package:veci_poc_escaneo/core/ids/uuid_v7_generator.dart';
import 'package:veci_poc_escaneo/core/network/api_config.dart';
import 'package:veci_poc_escaneo/core/sync/outbox_dao.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/repositories/consumption_outbox_impl.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/repositories/offline_trust_repository_impl.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/services/ed25519_signature_verifier.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_rejection.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/generar_consumos_de_prueba.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/validar_qr.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/data/datasources/http_sync_remote.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/data/repositories/local_sync_state_impl.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/data/repositories/outbox_repository_impl.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/usecases/bajar_datos_offline.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/usecases/sincronizar_bandeja.dart';

import '../support/test_database.dart';

const expectedRejection = {
  'VALIDO': null,
  'REVOCADO': ScanRejection.qrRevocado,
  'OTRO_COMERCIO': ScanRejection.otroComercio,
  'FIRMA_INVALIDA': ScanRejection.firmaInvalida,
};

void main() {
  final baseUrl = Platform.environment['VECI_API'];
  final skip = baseUrl == null ? 'Define VECI_API para correr contra el servidor' : null;
  late AppDatabase db;
  late HttpSyncRemote remote;
  late LocalSyncStateImpl local;
  final ids = UuidV7Generator();

  setUp(() async {
    db = memoryDatabase();
    remote = HttpSyncRemote(ApiConfig(baseUrl: baseUrl ?? ''));
    local = LocalSyncStateImpl(db: db, ids: ids);
    await remote.resetServer();
    await BajarDatosOffline(remote: remote, local: local, clock: const SystemClock())();
  });

  tearDown(() => db.close());

  test('cada QR de la hoja de prueba se valida offline como se espera', () async {
    final validar = ValidarQr(
      trust: OfflineTrustRepositoryImpl(db),
      verifier: Ed25519SignatureVerifier(),
    );
    final sheet =
        jsonDecode((await http.get(Uri.parse('$baseUrl/poc/qr-de-prueba.json'))).body) as List;
    for (final qr in sheet.cast<Map<String, dynamic>>()) {
      final result = await validar(qr['token'] as String);
      expect(result.rejection, expectedRejection[qr['expected']], reason: qr['label'] as String);
    }
  }, skip: skip);

  test(
    '1.000 eventos offline llegan sin duplicados aunque se corte el 30 % de las respuestas',
    () async {
      final dao = OutboxDao(db);
      await GenerarConsumosDePrueba(
        outbox: ConsumptionOutboxImpl(dao),
        trust: OfflineTrustRepositoryImpl(db),
        ids: ids,
        clock: const SystemClock(),
      )();
      final sync = SincronizarBandeja(
        outbox: OutboxRepositoryImpl(dao: dao, ids: ids),
        remote: remote,
        local: local,
        backoff: (_) async {},
      );
      final report = await sync(
        const SincronizarBandejaParams(simulatedCutRate: 0.3, maxAttemptsPerBatch: 50),
      );
      final stats = await remote.fetchServerStats();
      // ignore: avoid_print
      print(
        'informe: ${report.batchesSent} lotes, ${report.failedAttempts} cortes, '
        '${report.elapsed.inMilliseconds} ms · servidor: $stats',
      );
      expect(report.completed, isTrue);
      expect(stats['eventosUnicos'], 1000);
      expect(stats['eventosAplicados'], 1000);
      expect(stats['reenviosDetectados'], stats['cortesSimulados']! * 100);
      expect(stats['eventosFueraDeOrden'], 0);
    },
    skip: skip,
  );
}

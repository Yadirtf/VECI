// Mide validar + guardar sin cámara, en la máquina donde corre la prueba.
// No sustituye la medición en un Android de 2 GB (ver docs del POC), pero
// muestra cuánto del presupuesto de 3 segundos usa nuestro código.
import 'package:flutter_test/flutter_test.dart';
import 'package:veci_poc_escaneo/core/ids/uuid_v7_generator.dart';
import 'package:veci_poc_escaneo/core/sync/outbox_dao.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/repositories/consumption_outbox_impl.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/services/ed25519_signature_verifier.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_outcome.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/registrar_consumo_por_qr.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/validar_qr.dart';
import 'package:veci_poc_escaneo/core/ids/system_clock.dart';

import '../support/fakes.dart';
import '../support/test_database.dart';
import '../support/token_factory.dart';

const tenant = '01920000-0000-7000-8000-000000000001';
const scans = 300;

void main() {
  test('validar y guardar $scans QR: p95 muy por debajo de 3 s', () async {
    final db = memoryDatabase();
    final tokens = await TokenFactory.create();
    final registrar = RegistrarConsumoPorQr(
      validar: ValidarQr(
        trust: FakeTrust(tenantId: tenant, keys: {'k1': tokens.publicKey}),
        verifier: Ed25519SignatureVerifier(),
      ),
      outbox: ConsumptionOutboxImpl(OutboxDao(db)),
      ids: UuidV7Generator(),
      clock: const SystemClock(),
    );
    final token = await tokens.sign(tenantId: tenant);
    final times = <int>[];
    for (var i = 0; i < scans; i++) {
      final watch = Stopwatch()..start();
      expect(await registrar(token), isA<ScanAccepted>());
      times.add(watch.elapsedMicroseconds);
    }
    times.sort();
    final p50 = times[scans ~/ 2] / 1000;
    final p95 = times[(scans * 0.95).floor()] / 1000;
    // ignore: avoid_print
    print(
      'validar+guardar: p50 ${p50.toStringAsFixed(1)} ms, p95 ${p95.toStringAsFixed(1)} ms, '
      'máx ${(times.last / 1000).toStringAsFixed(1)} ms',
    );
    expect(p95, lessThan(300));
    await db.close();
  });
}

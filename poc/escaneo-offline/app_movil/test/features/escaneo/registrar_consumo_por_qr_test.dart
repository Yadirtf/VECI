import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:veci_poc_escaneo/core/database/app_database.dart';
import 'package:veci_poc_escaneo/core/ids/uuid_v7_generator.dart';
import 'package:veci_poc_escaneo/core/sync/outbox_dao.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/repositories/consumption_outbox_impl.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/services/ed25519_signature_verifier.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_outcome.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/registrar_consumo_por_qr.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/validar_qr.dart';

import '../../support/fakes.dart';
import '../../support/test_database.dart';
import '../../support/token_factory.dart';

const tenant = '01920000-0000-7000-8000-000000000001';

void main() {
  late AppDatabase db;
  late TokenFactory tokens;
  late RegistrarConsumoPorQr registrar;
  final occurredAt = DateTime.utc(2026, 10, 4, 12, 30, 15, 123);

  setUp(() async {
    db = memoryDatabase();
    tokens = await TokenFactory.create();
    final trust = FakeTrust(tenantId: tenant, keys: {'k1': tokens.publicKey});
    registrar = RegistrarConsumoPorQr(
      validar: ValidarQr(trust: trust, verifier: Ed25519SignatureVerifier()),
      outbox: ConsumptionOutboxImpl(OutboxDao(db)),
      ids: UuidV7Generator(),
      clock: FixedClock(occurredAt),
    );
  });

  tearDown(() => db.close());

  test(
    'un QR válido deja el consumo en la bandeja con id v7, hora real y payload del modelo',
    () async {
      final outcome = await registrar(await tokens.sign(tenantId: tenant, qrCodeId: 'qr-1'));
      expect(outcome, isA<ScanAccepted>());
      final row = await db.select(db.outboxEvents).getSingle();
      expect(row.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7')));
      expect(row.statusCode, outboxPendingCode);
      expect(row.occurredAt.toUtc(), occurredAt, reason: 'conserva milisegundos');
      final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      expect(payload, containsPair('affiliation_qr_code_id', 'qr-1'));
      expect(payload, containsPair('capture_method', 'QR_SCAN'));
      expect(payload['business_date'], isNotNull);
    },
  );

  test('un QR rechazado no deja nada en la bandeja', () async {
    final outcome = await registrar(await tokens.sign(tenantId: 'otro'));
    expect(outcome, isA<ScanRejected>());
    expect(await db.select(db.outboxEvents).get(), isEmpty);
  });
}

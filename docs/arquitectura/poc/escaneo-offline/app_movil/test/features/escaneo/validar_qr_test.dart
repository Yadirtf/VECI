import 'package:flutter_test/flutter_test.dart';
import 'package:veci_poc_escaneo/features/escaneo/data/services/ed25519_signature_verifier.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_rejection.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/usecases/validar_qr.dart';

import '../../support/fakes.dart';
import '../../support/token_factory.dart';

const tenant = '01920000-0000-7000-8000-000000000001';
const otherTenant = '01920000-0000-7000-8000-000000000002';

void main() {
  late TokenFactory tokens;
  late FakeTrust trust;
  late ValidarQr validar;

  setUp(() async {
    tokens = await TokenFactory.create();
    trust = FakeTrust(tenantId: tenant, keys: {'k1': tokens.publicKey});
    validar = ValidarQr(trust: trust, verifier: Ed25519SignatureVerifier());
  });

  Future<ScanRejection?> rejectionOf(String raw) async => (await validar(raw)).rejection;

  test('acepta un QR firmado por el comercio', () async {
    final result = await validar(await tokens.sign(tenantId: tenant));
    expect(result.payload?.tenantId, tenant);
    expect(result.rejection, isNull);
  });

  test('rechaza un QR con la firma alterada', () async {
    final token = await tokens.sign(tenantId: tenant);
    final cut = token.lastIndexOf('.') + 1;
    final forged = token.replaceRange(cut, cut + 1, token[cut] == 'A' ? 'B' : 'A');
    expect(await rejectionOf(forged), ScanRejection.firmaInvalida);
  });

  test('rechaza un QR cuyo contenido cambió', () async {
    final token = await tokens.sign(tenantId: tenant);
    final other = await tokens.sign(tenantId: tenant, affiliationId: 'otra');
    final mixed =
        '${other.substring(0, other.lastIndexOf('.'))}${token.substring(token.lastIndexOf('.'))}';
    expect(await rejectionOf(mixed), ScanRejection.firmaInvalida);
  });

  test('rechaza QR de otro comercio', () async {
    expect(await rejectionOf(await tokens.sign(tenantId: otherTenant)), ScanRejection.otroComercio);
  });

  test('rechaza QR revocado', () async {
    trust.revoked.add('revocado');
    final token = await tokens.sign(tenantId: tenant, qrCodeId: 'revocado');
    expect(await rejectionOf(token), ScanRejection.qrRevocado);
  });

  test('rechaza claves que el celular no conoce', () async {
    expect(
      await rejectionOf(await tokens.sign(tenantId: tenant, keyId: 'k9')),
      ScanRejection.claveDesconocida,
    );
  });

  test('rechaza textos que no son de VECI', () async {
    for (final raw in ['', 'hola', 'V1.x.y', 'V2.a.b', 'https://ejemplo.com']) {
      expect(await rejectionOf(raw), ScanRejection.formatoInvalido, reason: raw);
    }
  });

  test('pide bajar los datos si el celular nunca sincronizó', () async {
    trust.tenantId = null;
    expect(await rejectionOf(await tokens.sign(tenantId: tenant)), ScanRejection.sinDatosOffline);
  });
}

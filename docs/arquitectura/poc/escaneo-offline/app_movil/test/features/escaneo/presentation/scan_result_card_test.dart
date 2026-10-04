import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/qr_payload.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_outcome.dart';
import 'package:veci_poc_escaneo/features/escaneo/domain/entities/scan_rejection.dart';
import 'package:veci_poc_escaneo/features/escaneo/presentation/widgets/scan_result_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('un consumo aceptado se celebra y avisa que se enviará luego', (tester) async {
    var next = 0;
    await tester.pumpWidget(
      wrap(
        ScanResultCard(
          outcome: ScanAccepted(
            eventId: '01920000-0000-7000-8000-000000000123',
            occurredAt: DateTime(2026, 10, 4),
            qr: const QrPayload(
              keyId: 'k',
              tenantId: 't',
              affiliationId: 'a',
              qrCodeId: 'q',
              version: 1,
            ),
          ),
          onNext: () => next++,
        ),
      ),
    );
    expect(find.text('¡Listo, buen provecho!'), findsOneWidget);
    expect(find.textContaining('Se enviará cuando haya internet'), findsOneWidget);
    await tester.tap(find.text('Escanear otro'));
    expect(next, 1);
  });

  testWidgets('un QR rechazado explica el motivo con palabras sencillas', (tester) async {
    await tester.pumpWidget(
      wrap(ScanResultCard(outcome: const ScanRejected(ScanRejection.otroComercio), onNext: () {})),
    );
    expect(find.text('Este QR no sirve aquí'), findsOneWidget);
    expect(find.text(ScanRejection.otroComercio.message), findsOneWidget);
  });
}

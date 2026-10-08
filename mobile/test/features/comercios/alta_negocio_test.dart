import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/di/comercios_providers.dart';
import 'package:veci/features/comercios/domain/entities/alta.dart';
import 'package:veci/features/comercios/domain/reglas/reglas_alta.dart';
import 'package:veci/features/comercios/presentation/pages/alta_negocio_page.dart';

import 'comercios_dobles.dart';

void main() {
  group('reglas del alta', () {
    test('calcula el dígito de verificación del NIT como la DIAN', () {
      expect(digitoVerificacion('800197268'), 4);
      expect(digitoVerificacion('900123456'), 8);
      expect(documentoCompleto(const BorradorAlta(documento: '800.197.268')), '8001972684');
    });

    test('dice qué falta en cada pregunta', () {
      expect(
        problemaEnPaso(PasoAlta.nombre, const BorradorAlta(nombre: 'La')),
        contains('3 letras'),
      );
      expect(
        problemaEnPaso(PasoAlta.contacto, const BorradorAlta(celular: '210 000 0000')),
        contains('empieza por 3'),
      );
      expect(
        problemaEnPaso(PasoAlta.contacto, const BorradorAlta(celular: '310 000 0000')),
        isNull,
      );
      expect(problemaEnPaso(PasoAlta.lugar, const BorradorAlta()), contains('municipio'));
      expect(problemaEnPaso(PasoAlta.lugar, const BorradorAlta(municipioId: 86001)), isNull);
    });

    test('la inicial del sello salta las palabras genéricas', () {
      expect(inicialDe('Panadería Santa Ana'), 'S');
      expect(inicialDe('La Vecina'), 'V');
    });
  });

  testWidgets('pide el registro pregunta por pregunta y queda en revisión', (tester) async {
    final comercios = ComerciosFalsos();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [comerciosRepositoryProvider.overrideWithValue(comercios)],
        child: const MaterialApp(home: AltaNegocioPage()),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tocar(String texto) async {
      await tester.ensureVisible(find.text(texto));
      await tester.tap(find.text(texto));
      await tester.pumpAndSettle();
    }

    Future<void> seguir() async {
      await tester.ensureVisible(find.text('Seguir'));
      await tester.tap(find.text('Seguir'));
      await tester.pumpAndSettle();
    }

    await tester.enterText(find.byType(TextFormField), 'Panadería Santa Ana');
    await seguir();
    await tester.tap(find.text('Panadería'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nace con Pan de la mañana'), findsOneWidget);
    await seguir();
    await tester.enterText(find.byType(TextFormField), '800197268');
    await tester.pumpAndSettle();
    expect(find.textContaining('dígito de verificación es 4'), findsOneWidget);
    await seguir();
    await tester.enterText(find.byType(TextFormField), '3105551234');
    await seguir();
    await seguir();
    expect(find.textContaining('el municipio donde queda'), findsOneWidget);
    await tocar('Mocoa');
    await seguir();
    expect(find.text('NIT 800197268-4'), findsOneWidget);
    await tocar('Enviar solicitud a VECI');

    expect(comercios.solicitado?.nombre, 'Panadería Santa Ana');
    expect(comercios.solicitado?.municipioId, 86001);
    expect(find.text('Recibimos tu solicitud para Panadería Santa Ana'), findsOneWidget);
  });
}

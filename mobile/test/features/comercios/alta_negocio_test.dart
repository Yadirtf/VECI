import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/di/comercios_providers.dart';
import 'package:veci/core/di/sesion_providers.dart';
import 'package:veci/features/comercios/domain/entities/alta.dart';
import 'package:veci/features/comercios/domain/repositories/comercios_repository.dart';
import 'package:veci/features/comercios/domain/reglas/reglas_alta.dart';
import 'package:veci/features/comercios/presentation/pages/alta_negocio_page.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';

import '../sesion/sesion_dobles.dart';

class _ComerciosFalsos implements ComerciosRepository {
  BorradorAlta? registrado;

  @override
  Future<List<TipoDeNegocio>> tipos() async => const [
    TipoDeNegocio(codigo: 'BAKERY', nombre: 'Panadería', servicios: ['Pan de la mañana']),
  ];

  @override
  Future<String> registrar(BorradorAlta borrador) async {
    registrado = borrador;
    return 'nuevo';
  }
}

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
    });

    test('la inicial del sello salta las palabras genéricas', () {
      expect(inicialDe('Panadería Santa Ana'), 'S');
      expect(inicialDe('La Vecina'), 'V');
    });
  });

  testWidgets('registra el negocio pregunta por pregunta y lo deja activo', (tester) async {
    final comercios = _ComerciosFalsos();
    final repositorio = RepositorioFalso()..renovada = sesionDePrueba('t2');
    final gestor = GestorSesion(repositorio, AlmacenFalso(), PendientesFalsos(0));
    await gestor.entrarConPin('3100000101', '246813');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          comerciosRepositoryProvider.overrideWithValue(comercios),
          gestorSesionProvider.overrideWithValue(gestor),
        ],
        child: const MaterialApp(home: AltaNegocioPage()),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> seguir() async {
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
    expect(find.text('NIT 800197268-4'), findsOneWidget);
    await tester.tap(find.text('Abrir mi negocio en VECI'));
    await tester.pumpAndSettle();

    expect(comercios.registrado?.nombre, 'Panadería Santa Ana');
    expect(repositorio.elegidos, contains('nuevo'));
  });
}

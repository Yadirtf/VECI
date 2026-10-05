import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/inicio/presentation/pages/inicio_page.dart';

Widget _inicio({required bool enLaCaja, String? rutaCaja}) => MaterialApp(
  home: InicioPage(
    nombre: 'Jhon Pérez',
    negocio: 'Restaurante La Vecina',
    enLaCaja: enLaCaja,
    variosNegocios: false,
    alCambiarNegocio: () async {},
    alSalir: () async {},
    rutaCaja: rutaCaja,
  ),
);

void main() {
  testWidgets('en la caja, lo principal es atender a quien sigue', (tester) async {
    await tester.pumpWidget(_inicio(enLaCaja: true, rutaCaja: '/caja'));
    expect(find.text('Atender a quien sigue'), findsOneWidget);
    expect(find.text('Ver horarios'), findsOneWidget);
    expect(find.text('Ver mi QR'), findsNothing);
  });

  testWidgets('como cliente de ese negocio, lo principal es su QR', (tester) async {
    await tester.pumpWidget(_inicio(enLaCaja: false, rutaCaja: '/caja'));
    expect(find.text('Ver mi QR'), findsOneWidget);
    expect(find.text('Atender a quien sigue'), findsNothing);
  });
}

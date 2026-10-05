import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/theme/veci_tema.dart';
import 'package:veci/core/theme/veci_tokens.dart';
import 'package:veci/core/ui/veci_boton.dart';
import 'package:veci/core/ui/veci_aviso.dart';
import 'package:veci/core/ui/veci_pin.dart';
import 'package:veci/core/ui/veci_saldo.dart';
import 'package:veci/core/ui/veci_sello.dart';

Widget _envolver(Widget hijo) => MaterialApp(
  theme: VeciTema.claro(),
  home: Scaffold(body: Center(child: hijo)),
);

void main() {
  testWidgets('el botón mide al menos 56 px de alto y responde al toque', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_envolver(VeciBoton(texto: 'Vender', alTocar: () => tocado = true)));

    await tester.tap(find.text('Vender'));

    expect(tocado, isTrue);
    expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(VeciToque.boton));
  });

  testWidgets('el botón grande mide 72 px', (tester) async {
    await tester.pumpWidget(_envolver(VeciBoton(texto: 'Cobrar', grande: true, alTocar: () {})));

    expect(tester.getSize(find.byType(FilledButton)).height, VeciToque.botonGrande);
  });

  testWidgets('el saldo usa singular o plural', (tester) async {
    await tester.pumpWidget(
      _envolver(const VeciSaldo(unidades: 1, singular: 'almuerzo', plural: 'almuerzos')),
    );
    expect(find.text('almuerzo'), findsOneWidget);

    await tester.pumpWidget(
      _envolver(const VeciSaldo(unidades: 12, singular: 'almuerzo', plural: 'almuerzos')),
    );
    expect(find.text('almuerzos'), findsOneWidget);
    expect(find.bySemanticsLabel('Saldo: 12 almuerzos'), findsOneWidget);
  });

  testWidgets('el botón baja al presionarlo, como una tecla', (tester) async {
    await tester.pumpWidget(_envolver(VeciBoton(texto: 'Vender', alTocar: () {})));
    final arriba = tester.getTopLeft(find.byType(FilledButton)).dy;

    final gesto = await tester.startGesture(tester.getCenter(find.text('Vender')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(FilledButton)).dy, greaterThan(arriba));

    await gesto.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(FilledButton)).dy, arriba);
  });

  testWidgets('el botón de peligro tiene esquinas cortadas', (tester) async {
    await tester.pumpWidget(
      _envolver(VeciBoton(texto: 'Anular venta', peligro: true, alTocar: () {})),
    );
    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.style!.shape!.resolve({}), isA<BeveledRectangleBorder>());
  });

  testWidgets('el saldo con total dice cuántas quedan de cuántas', (tester) async {
    await tester.pumpWidget(
      _envolver(const VeciSaldo(unidades: 8, singular: 'almuerzo', plural: 'almuerzos', total: 20)),
    );
    expect(find.bySemanticsLabel('Saldo: 8 almuerzos de 20'), findsOneWidget);
  });

  testWidgets('el aviso sigue mostrando el mensaje completo', (tester) async {
    await tester.pumpWidget(
      _envolver(const VeciAviso(tono: TonoAviso.error, mensaje: 'Este QR es de otro negocio.')),
    );
    expect(find.text('Este QR es de otro negocio.'), findsOneWidget);
  });

  testWidgets('el PIN no muestra los números y solo acepta 6 cifras', (tester) async {
    final pin = TextEditingController();
    await tester.pumpWidget(_envolver(VeciPin(etiqueta: 'PIN', controlador: pin)));

    await tester.enterText(find.widgetWithText(TextField, 'PIN'), '12a34567');

    expect(pin.text, '123456');
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
  });

  testWidgets('el sello se lee completo y su ángulo es estable', (tester) async {
    await tester.pumpWidget(
      _envolver(
        const VeciSello(
          arriba: '¡Listo, veci!',
          cifra: '12',
          abajo: 'almuerzos',
          semilla: 'c-1',
          vibrar: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('¡Listo, veci! 12 almuerzos'), findsOneWidget);
    expect(VeciSello.anguloPara('c-1'), VeciSello.anguloPara('c-1'));
    for (final semilla in ['a', 'consumo-77', 'xyz-123']) {
      expect(VeciSello.anguloPara(semilla), inInclusiveRange(-8, 8));
    }
  });
}

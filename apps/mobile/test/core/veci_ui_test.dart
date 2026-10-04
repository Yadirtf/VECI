import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/theme/veci_tema.dart';
import 'package:veci/core/theme/veci_tokens.dart';
import 'package:veci/core/ui/veci_boton.dart';
import 'package:veci/core/ui/veci_saldo.dart';

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
}

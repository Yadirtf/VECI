import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_de_prueba.dart';
import 'clientes_dobles.dart';

void main() {
  testWidgets('al abrir revisa la copia y dice desde cuándo está al día', (tester) async {
    final repositorio = RepositorioClientesFalso();
    await abrirCaja(tester, repositorio);

    expect(repositorio.actualizaciones, 1);
    expect(find.text('Copia al día a las 10:42 a. m.'), findsOneWidget);
    expect(find.textContaining('Escribe 3 letras'), findsOneWidget);
  });

  testWidgets('busca mientras escribe y abre la ficha', (tester) async {
    await abrirCaja(tester, RepositorioClientesFalso());

    await tester.enterText(find.byType(TextField), 'marí');
    await tester.pump();
    expect(find.text('Luz Marina Castro'), findsOneWidget);
    expect(find.text('Doc. ****5678 · Cel. ••• 8888'), findsOneWidget);

    await tester.tap(find.text('Luz Marina Castro'));
    await tester.pumpAndSettle();
    expect(find.text('Ficha del cliente'), findsOneWidget);
  });

  testWidgets('sin resultados ofrece registrar con lo escrito puesto', (tester) async {
    await abrirCaja(tester, RepositorioClientesFalso());

    await tester.enterText(find.byType(TextField), '310 555 1234');
    await tester.pump();
    expect(find.textContaining('No encontramos'), findsOneWidget);

    await tester.tap(find.text('Registrar a 310 555 1234'));
    await tester.pumpAndSettle();
    expect(find.text('Registrar cliente'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Número de documento'), '1085345678');
    await tester.tap(find.text('Revisar documento'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(TextField, 'Celular'));
    expect(find.widgetWithText(TextField, '3105551234'), findsOneWidget);
  });
}

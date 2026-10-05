import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/clientes/domain/entities/registro_asistido.dart';
import 'package:veci/features/clientes/presentation/rutas_clientes.dart';

import 'app_de_prueba.dart';
import 'clientes_dobles.dart';

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

Future<void> _revisarDocumento(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextField, 'Número de documento'), '1.085.345.678');
  await _tocar(tester, 'Revisar documento');
}

void main() {
  testWidgets('persona nueva: datos, política leída y PIN para dictar', (tester) async {
    final repositorio = RepositorioClientesFalso();
    await abrirCaja(tester, repositorio, ruta: RutasClientes.registrarCon('Luz Marina'));

    await _revisarDocumento(tester);
    expect(find.text('Léele esto en voz alta'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Luz Marina'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Celular'), '310 555 1234');
    await _tocar(tester, 'Sí aceptó · Registrar');

    final datos = repositorio.registros.single;
    expect(datos.numeroDocumento, '1085345678');
    expect(datos.celular, '3105551234');
    expect(datos.politicaVersionId, 'pol-1');
    expect(find.text('482 915'), findsOneWidget);
    expect(find.text('Sirve 7 días. Con su celular y este PIN activa su app.'), findsOneWidget);
    expect(repositorio.actualizaciones, 0, reason: 'la ranura no estaba abierta');
  });

  testWidgets('celular de otra cuenta: se reenvía como celular compartido', (tester) async {
    final repositorio = RepositorioClientesFalso()
      ..respuestasRegistro.add(
        const PeticionRechazada(
          409,
          'Ese celular ya es de otra cuenta VECI.',
          motivo: 'CELULAR_EN_USO',
        ),
      )
      ..respuestasRegistro.add(RegistroHecho(ficha: fichaDePrueba(), vinculado: false));
    await abrirCaja(tester, repositorio, ruta: RutasClientes.registrarCon('Luz'));

    await _revisarDocumento(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Celular'), '3100000101');
    await _tocar(tester, 'Sí aceptó · Registrar');
    expect(find.text('Ese celular ya es de otra cuenta VECI.'), findsOneWidget);

    await _tocar(tester, 'Es el celular compartido de la familia');

    expect(repositorio.registros.map((d) => d.celularCompartido), [false, true]);
    expect(find.text('¡Listo, veci! Quedó registrado en tu negocio.'), findsOneWidget);
  });

  testWidgets('si el documento ya está en VECI solo se afilia', (tester) async {
    final repositorio = RepositorioClientesFalso()..revision = personaDePrueba;
    await abrirCaja(tester, repositorio, ruta: RutasClientes.registrar);

    await _revisarDocumento(tester);
    expect(find.text('Luz Marina C.'), findsOneWidget);
    await _tocar(tester, 'Afiliar a esta persona');

    final datos = repositorio.registros.single;
    expect(datos.nombres, isNull);
    expect(datos.celular, isNull);
  });

  testWidgets('el documento se revisa con el patrón de su tipo', (tester) async {
    await abrirCaja(tester, RepositorioClientesFalso(), ruta: RutasClientes.registrar);

    await tester.enterText(find.widgetWithText(TextField, 'Número de documento'), '12');
    await _tocar(tester, 'Revisar documento');

    expect(find.textContaining('Revisa el número'), findsOneWidget);
  });

  testWidgets('ficha pendiente: da el PIN de bienvenida para dictar', (tester) async {
    await abrirCaja(tester, RepositorioClientesFalso(), ruta: RutasClientes.fichaDe('c1'));

    expect(find.text('Luz Marina Castro'), findsOneWidget);
    expect(find.text('Aún no activa su app'), findsOneWidget);
    expect(find.text('Cliente desde'), findsOneWidget);
    expect(find.text('3 de octubre de 2026'), findsOneWidget);

    await _tocar(tester, 'Dar PIN de bienvenida');

    expect(find.text('482 915'), findsOneWidget);
    expect(find.text('Dar PIN de bienvenida'), findsNothing);
  });
}

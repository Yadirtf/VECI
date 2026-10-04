import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/di/sesion_providers.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/sesion/domain/entities/estado_sesion.dart';
import 'package:veci/features/sesion/domain/entities/sesion.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';
import 'package:veci/features/sesion/presentation/pages/entrar_page.dart';
import 'package:veci/features/sesion/presentation/pages/pin_nuevo_page.dart';

import 'sesion_dobles.dart';

class _RepositorioQueRechaza extends RepositorioFalso {
  @override
  Future<ResultadoIngreso> entrarConPin(String celular, String pin) async =>
      throw const PeticionRechazada(401, 'El celular o el PIN no coinciden.');
}

Widget _app(GestorSesion gestor, Widget pagina) => ProviderScope(
  overrides: [gestorSesionProvider.overrideWithValue(gestor)],
  child: MaterialApp(home: pagina),
);

void main() {
  testWidgets('explica qué falta sin llamar al servidor', (tester) async {
    final gestor = GestorSesion(RepositorioFalso(), AlmacenFalso(), PendientesFalsos());
    await tester.pumpWidget(_app(gestor, const EntrarPage()));
    await tester.enterText(find.widgetWithText(TextField, 'Celular'), '12');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.textContaining('empieza por 3'), findsOneWidget);
  });

  testWidgets('muestra el mensaje del servidor si no coinciden', (tester) async {
    final gestor = GestorSesion(_RepositorioQueRechaza(), AlmacenFalso(), PendientesFalsos());
    await tester.pumpWidget(_app(gestor, const EntrarPage()));
    await tester.enterText(find.widgetWithText(TextField, 'Celular'), '3100000102');
    await tester.enterText(find.widgetWithText(TextField, 'PIN'), '909192');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('El celular o el PIN no coinciden.'), findsOneWidget);
  });

  testWidgets('entra y deja la sesión activa', (tester) async {
    final gestor = GestorSesion(RepositorioFalso(), AlmacenFalso(), PendientesFalsos());
    await tester.pumpWidget(_app(gestor, const EntrarPage()));
    await tester.enterText(find.widgetWithText(TextField, 'Celular'), '310 000 0102');
    await tester.enterText(find.widgetWithText(TextField, 'PIN'), '246813');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(gestor.estado, isA<SesionActiva>());
  });

  testWidgets('muestra el aviso si la sesión se cerró desde el panel', (tester) async {
    final almacen = AlmacenFalso()..sesion = sesionDePrueba('viejo');
    final gestor = GestorSesion(RepositorioFalso()..renovada = null, almacen, PendientesFalsos(2));
    await gestor.iniciar();
    await tester.pumpWidget(_app(gestor, const EntrarPage()));
    expect(find.textContaining('2 registros guardados'), findsOneWidget);
  });

  testWidgets('el PIN nuevo se escribe dos veces igual', (tester) async {
    final repositorio = RepositorioFalso()
      ..ingreso = const IngresoConCambioDePin(tokenCambio: 'tc', nombre: 'Ana');
    final gestor = GestorSesion(repositorio, AlmacenFalso(), PendientesFalsos());
    await gestor.entrarConPin('3124567890', '482915');
    await tester.pumpWidget(_app(gestor, const PinNuevoPage()));
    expect(find.text('Hola, Ana'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'PIN nuevo'), '730284');
    await tester.enterText(find.widgetWithText(TextField, 'Escríbelo otra vez'), '730285');
    await tester.tap(find.text('Guardar mi PIN'));
    await tester.pump();
    expect(find.text('Los dos PIN no coinciden.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Escríbelo otra vez'), '730284');
    await tester.tap(find.text('Guardar mi PIN'));
    await tester.pumpAndSettle();
    expect(gestor.estado, isA<SesionActiva>());
  });
}

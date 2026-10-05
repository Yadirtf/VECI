import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:veci/core/di/registro_providers.dart';
import 'package:veci/core/di/sesion_providers.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/registro/presentation/pages/politica_page.dart';
import 'package:veci/features/registro/presentation/pages/registro_page.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';
import 'package:veci/features/sesion/presentation/pages/entrar_page.dart';

import '../sesion/sesion_dobles.dart';
import 'registro_dobles.dart';

Widget _app(RegistroFalso registro) {
  final router = GoRouter(
    initialLocation: Rutas.registro,
    routes: [
      GoRoute(path: Rutas.registro, builder: (_, _) => const RegistroPage()),
      GoRoute(path: Rutas.politica, builder: (_, _) => const PoliticaPage()),
      GoRoute(
        path: Rutas.entrar,
        builder: (_, estado) => EntrarPage(celular: estado.uri.queryParameters['celular']),
      ),
      GoRoute(path: Rutas.miQr, builder: (_, _) => const Text('Pantalla Mi QR')),
    ],
  );
  return ProviderScope(
    overrides: [
      registroRepositoryProvider.overrideWithValue(registro),
      gestorSesionProvider.overrideWithValue(
        GestorSesion(RepositorioFalso(), AlmacenFalso(), PendientesFalsos()),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

/// Contesta las preguntas hasta el PIN.
Future<void> _llegarAlPin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField), '315 777 8888');
  await _tocar(tester, 'Seguir');
  await tester.enterText(find.byType(TextFormField).first, 'Luz Marina');
  await _tocar(tester, 'Seguir');
  await tester.enterText(find.byType(TextFormField), '1124500777');
  await _tocar(tester, 'Seguir');
  await _tocar(tester, 'Acepto y creo mi cuenta');
  await tester.enterText(find.byType(TextField).at(0), '190573');
  await tester.enterText(find.byType(TextField).at(1), '190573');
  await tester.pump();
}

void main() {
  setUp(() {
    final vista = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    vista
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.4;
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset());

  testWidgets('explica qué falta antes de seguir', (tester) async {
    await tester.pumpWidget(_app(RegistroFalso()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '12');
    await _tocar(tester, 'Seguir');
    expect(find.textContaining('empieza por 3'), findsOneWidget);
    expect(find.text('¿Cuál es tu celular?'), findsOneWidget);
  });

  testWidgets('crea la cuenta pregunta por pregunta y da la bienvenida', (tester) async {
    final registro = RegistroFalso();
    await tester.pumpWidget(_app(registro));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '315 777 8888');
    await _tocar(tester, 'Seguir');
    await tester.enterText(find.byType(TextFormField).first, 'Luz Marina');
    await _tocar(tester, 'Seguir');
    await tester.enterText(find.byType(TextFormField), '1124500777');
    await _tocar(tester, 'Seguir');

    expect(find.text('Lo que anotamos'), findsOneWidget);
    expect(find.text('Lo que nunca hacemos'), findsOneWidget);
    expect(find.textContaining('Vender tus datos'), findsOneWidget);
    await _tocar(tester, 'Leer la política completa');
    expect(find.text('En palabras de vecino'), findsOneWidget);
    expect(find.text('VECI los guarda y responde por ellos.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _tocar(tester, 'Acepto y creo mi cuenta');
    await tester.enterText(find.byType(TextField).at(0), '190573');
    await tester.enterText(find.byType(TextField).at(1), '190573');
    await _tocar(tester, 'Crear mi cuenta');

    expect(registro.enviado?.nombres, 'Luz Marina');
    expect(registro.enviado?.tipoDocumento, 'CC');
    expect(registro.politicaAceptada, 'pol-1');
    expect(find.text('¡Listo, Luz!'), findsOneWidget);
    expect(find.textContaining('Muéstralo en tu negocio y quedas anotado'), findsOneWidget);
    await _tocar(tester, 'Ver mi QR');
    expect(find.text('Pantalla Mi QR'), findsOneWidget);
  });

  testWidgets('si ya está en VECI, ofrece entrar con el celular puesto', (tester) async {
    final registro = RegistroFalso()
      ..fallo = const PeticionRechazada(
        409,
        'Ese celular/documento ya está en VECI. Si es tuyo, entra con tu celular y tu PIN.',
        motivo: 'YA_TIENE_CUENTA',
      );
    await tester.pumpWidget(_app(registro));
    await tester.pumpAndSettle();
    await _llegarAlPin(tester);
    await _tocar(tester, 'Crear mi cuenta');

    expect(find.textContaining('ya está en VECI'), findsOneWidget);
    await _tocar(tester, 'Entrar con mi celular');
    final celular = tester.widget<TextField>(find.widgetWithText(TextField, 'Celular'));
    expect(celular.controller?.text, '3157778888');
  });

  testWidgets('sin internet no pierde lo escrito', (tester) async {
    final registro = RegistroFalso()..fallo = const SinConexion();
    await tester.pumpWidget(_app(registro));
    await tester.pumpAndSettle();
    await _llegarAlPin(tester);
    await _tocar(tester, 'Crear mi cuenta');
    expect(find.textContaining('necesitas internet'), findsOneWidget);
    expect(find.text('Crear mi cuenta'), findsOneWidget);
  });
}

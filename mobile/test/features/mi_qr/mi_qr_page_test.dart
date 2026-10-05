import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:veci/core/di/core_providers.dart';
import 'package:veci/core/di/mi_qr_providers.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/mi_qr/data/datasources/copia_mi_qr.dart';
import 'package:veci/features/mi_qr/data/repositories/mi_qr_repository_impl.dart';
import 'package:veci/features/mi_qr/presentation/pages/mi_qr_page.dart';
import 'package:veci/features/mi_qr/presentation/pages/qr_en_negocio_page.dart';
import 'package:veci/features/mi_qr/presentation/pages/tus_negocios_page.dart';

import 'mi_qr_dobles.dart';

late ApiMiQrFalsa _api;
late MiQrRepositoryImpl _repositorio;

Widget _app({String inicio = Rutas.miQr}) {
  final router = GoRouter(
    initialLocation: inicio,
    routes: [
      GoRoute(path: Rutas.miQr, builder: (_, _) => const MiQrPage()),
      GoRoute(path: Rutas.tusNegocios, builder: (_, _) => const TusNegociosPage()),
      GoRoute(
        path: Rutas.qrEnNegocio,
        builder: (_, estado) => QrEnNegocioPage(comercioId: estado.pathParameters['comercioId']!),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      miQrRepositoryProvider.overrideWithValue(_repositorio),
      nombreDeLaPersonaProvider.overrideWithValue('Luz Marina Chindoy'),
      soloClienteProvider.overrideWithValue(true),
      relojProvider.overrideWithValue(() => DateTime(2026, 10, 5)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _api = ApiMiQrFalsa();
    _repositorio = MiQrRepositoryImpl(_api, CopiaMiQr(CajonEnMemoria()));
    final vista = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    vista
      ..physicalSize = const Size(1080, 3600)
      ..devicePixelRatio = 2.4;
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset());

  testWidgets('muestra el carnet con el nombre, el número y que sirve sin internet', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Luz Marina Chindoy'), findsOneWidget);
    expect(find.text('N.º 1'), findsOneWidget);
    expect(find.text('Sirve sin internet'), findsOneWidget);
    expect(find.text('Muéstralo en tu negocio y quedas anotado.'), findsOneWidget);
    expect(find.text('Tus negocios'), findsNothing);
  });

  testWidgets('cambiar el QR explica y confirma en el mismo lugar', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tocar(tester, 'Cambiar mi QR');
    expect(find.textContaining('El QR anterior deja de servir'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('N.º 1'), findsOneWidget);

    await _tocar(tester, 'Sí, cambiar mi QR');
    expect(find.text('N.º 2'), findsOneWidget);
    expect(find.text('¡Listo! Este es tu QR nuevo.'), findsOneWidget);
    expect((await _repositorio.qrGuardado())?.version, 2);
  });

  testWidgets('"No, dejarlo así" no cambia nada', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tocar(tester, 'Cambiar mi QR');
    await _tocar(tester, 'No, dejarlo así');
    expect(find.text('Cambiar mi QR'), findsOneWidget);
    expect(_api.version, 1);
  });

  testWidgets('sin internet muestra el QR guardado y no deja cambiarlo', (tester) async {
    await _repositorio.traerQr();
    _api.sinSenal = true;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('N.º 1'), findsOneWidget);
    expect(find.textContaining('este es tu QR guardado'), findsOneWidget);

    await _tocar(tester, 'Cambiar mi QR');
    await _tocar(tester, 'Sí, cambiar mi QR');
    expect(find.textContaining('Para cambiar tu QR necesitas internet'), findsOneWidget);
    expect(find.text('N.º 1'), findsOneWidget);
  });

  testWidgets('con negocios, Mi QR lleva a Tus negocios', (tester) async {
    _api.negocios = [negocioDePrueba()];
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Muéstralo en tu negocio y quedas anotado.'), findsNothing);
    await _tocar(tester, 'Tus negocios');
    expect(find.text('Restaurante La Vecina'), findsOneWidget);
  });

  testWidgets('Tus negocios: cada uno abre su QR y dice qué ve el negocio', (tester) async {
    _api.negocios = [negocioDePrueba()];
    await tester.pumpWidget(_app(inicio: Rutas.tusNegocios));
    await tester.pumpAndSettle();
    expect(find.text('Cliente desde el 3 de octubre'), findsOneWidget);
    expect(find.text('Qué ve cada negocio de mí'), findsOneWidget);
    expect(find.textContaining('Ningún negocio sabe en qué otros estás'), findsOneWidget);

    await _tocar(tester, 'Restaurante La Vecina');
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Muéstralo en la caja de Restaurante La Vecina.'), findsOneWidget);
  });

  testWidgets('Tus negocios vacío invita a mostrar el QR', (tester) async {
    await tester.pumpWidget(_app(inicio: Rutas.tusNegocios));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aún no eres cliente de ningún negocio'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:veci/core/di/comercios_providers.dart';
import 'package:veci/core/di/sesion_providers.dart';
import 'package:veci/features/comercios/domain/entities/solicitud.dart';
import 'package:veci/features/comercios/presentation/pages/ajustes_page.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';

import '../sesion/sesion_dobles.dart';
import 'comercios_dobles.dart';

SolicitudDeNegocio _solicitud(EstadoSolicitud estado, {String? nota, String? comercioId}) =>
    SolicitudDeNegocio(
      id: 's1',
      nombre: 'Panadería Sol',
      estado: estado,
      radicadaEn: DateTime(2026, 10, 8),
      nota: nota,
      comercioId: comercioId,
    );

void main() {
  late RepositorioFalso sesiones;
  late GestorSesion gestor;

  Future<void> abrir(WidgetTester tester, List<SolicitudDeNegocio> solicitudes) async {
    sesiones = RepositorioFalso();
    gestor = GestorSesion(sesiones, AlmacenFalso(), PendientesFalsos(0));
    await gestor.entrarConPin('3100000101', '246813');
    final router = GoRouter(
      initialLocation: '/ajustes',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Inicio del negocio')),
        GoRoute(path: '/ajustes', builder: (_, _) => const AjustesPage()),
        GoRoute(path: '/negocio/nuevo', builder: (_, _) => const Text('Preguntas del alta')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          comerciosRepositoryProvider.overrideWithValue(ComerciosFalsos(solicitudes: solicitudes)),
          gestorSesionProvider.overrideWithValue(gestor),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin solicitudes ofrece pedir el registro del negocio', (tester) async {
    await abrir(tester, const []);
    await tester.tap(find.text('Solicitar el registro de mi negocio'));
    await tester.pumpAndSettle();
    expect(find.text('Preguntas del alta'), findsOneWidget);
  });

  testWidgets('en revisión no deja pedir otra mientras tanto', (tester) async {
    await abrir(tester, [_solicitud(EstadoSolicitud.enRevision)]);
    expect(find.textContaining('Panadería Sol está en revisión'), findsOneWidget);
    expect(find.text('Solicitar el registro de mi negocio'), findsNothing);
  });

  testWidgets('rechazada muestra el motivo y deja enviar una nueva', (tester) async {
    await abrir(tester, [
      _solicitud(EstadoSolicitud.rechazada, nota: 'El NIT no coincide con el RUT.'),
    ]);
    expect(find.textContaining('El NIT no coincide con el RUT.'), findsOneWidget);
    expect(find.text('Enviar una nueva solicitud'), findsOneWidget);
  });

  testWidgets('aprobada trae el negocio a la sesión y entra a él', (tester) async {
    await abrir(tester, [_solicitud(EstadoSolicitud.aprobada, comercioId: 'c1')]);
    await tester.tap(find.text('Entrar a mi negocio'));
    await tester.pumpAndSettle();
    expect(sesiones.renovaciones, 1);
    expect(sesiones.elegidos, contains('c1'));
    expect(find.text('Inicio del negocio'), findsOneWidget);
  });
}

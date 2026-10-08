import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:veci/core/di/core_providers.dart';
import 'package:veci/core/di/tiqueteras_providers.dart';
import 'package:veci/features/tiqueteras/presentation/rutas_tiqueteras.dart';

import 'tiqueteras_dobles.dart';

/// Las rutas reales de tiqueteras con repositorios falsos.
Future<GoRouter> abrirTiqueteras(
  WidgetTester tester,
  String ruta, {
  VentasFalsas? ventas,
  MisTiqueterasFalsas? mias,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/inicio-prueba',
    routes: [
      GoRoute(
        path: '/inicio-prueba',
        builder: (_, _) => const Scaffold(body: Text('Inicio')),
      ),
      ...rutasDeTiqueteras(),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ventasRepositoryProvider.overrideWithValue(ventas ?? VentasFalsas()),
        misTiqueterasRepositoryProvider.overrideWithValue(mias ?? MisTiqueterasFalsas()),
        nuevoIdDeVentaProvider.overrideWithValue(() => 'venta-1'),
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 8, 12)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  unawaited(router.push(ruta));
  await tester.pumpAndSettle();
  return router;
}

Future<void> tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto).last);
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

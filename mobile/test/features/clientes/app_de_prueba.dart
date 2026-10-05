import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:veci/core/di/clientes_providers.dart';
import 'package:veci/core/di/core_providers.dart';
import 'package:veci/features/clientes/presentation/rutas_clientes.dart';

import 'clientes_dobles.dart';

/// La caja de clientes con sus rutas reales y un repositorio falso.
Future<GoRouter> abrirCaja(
  WidgetTester tester,
  RepositorioClientesFalso repositorio, {
  String ruta = RutasClientes.caja,
  List<RouteBase> otras = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Inicio')),
      ),
      ...rutasDeClientes(),
      ...otras,
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientesRepositoryProvider.overrideWithValue(repositorio),
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 5, 12)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  if (ruta != '/') {
    unawaited(router.push(ruta));
  }
  await tester.pumpAndSettle();
  return router;
}

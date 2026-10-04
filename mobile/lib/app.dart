import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/di/sesion_providers.dart';
import 'core/observabilidad/sentry_veci.dart';
import 'core/router/app_router.dart';
import 'core/theme/veci_tema.dart';
import 'features/sesion/domain/entities/estado_sesion.dart';

class VeciApp extends ConsumerStatefulWidget {
  const VeciApp({super.key});

  @override
  ConsumerState<VeciApp> createState() => _VeciAppState();
}

class _VeciAppState extends ConsumerState<VeciApp> {
  late final GoRouter _router;
  StreamSubscription<EstadoSesion>? _etiquetas;

  @override
  void initState() {
    super.initState();
    final gestor = ref.read(gestorSesionProvider);
    _router = crearRouter(gestor);
    _etiquetas = gestor.cambios.listen((estado) {
      final comercio = estado is SesionActiva ? estado.comercioId : null;
      unawaited(SentryVeci.etiquetarComercio(comercio));
    });
    unawaited(gestor.iniciar());
  }

  @override
  void dispose() {
    unawaited(_etiquetas?.cancel());
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'VECI',
    theme: VeciTema.claro(),
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
  );
}

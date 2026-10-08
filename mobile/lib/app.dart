import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/di/mi_qr_providers.dart';
import 'core/di/sesion_providers.dart';
import 'core/di/tiqueteras_providers.dart';
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

  /// Cada tanto la caja envía las ventas hechas sin señal (ADR-0004).
  Timer? _envio;
  static const _cadaCuanto = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    final gestor = ref.read(gestorSesionProvider);
    _router = crearRouter(gestor);
    _etiquetas = gestor.cambios.listen((estado) {
      final comercio = estado is SesionActiva ? estado.comercioId : null;
      unawaited(SentryVeci.etiquetarComercio(comercio));
      // El QR de una persona no se queda en el celular cuando sale (EP-04).
      if (estado is SinSesion) {
        unawaited(ref.read(miQrRepositoryProvider).olvidar());
        unawaited(ref.read(misTiqueterasRepositoryProvider).olvidar());
      }
    });
    _envio = Timer.periodic(_cadaCuanto, (_) => unawaited(_enviarVentas()));
    unawaited(gestor.iniciar());
  }

  Future<void> _enviarVentas() async {
    final estado = ref.read(estadoSesionProvider);
    if (estado is! SesionActiva || estado.comercioId == null) return;
    try {
      await ref.read(ventasRepositoryProvider).enviarPendientes();
    } on Object {
      // Se reintenta en la siguiente vuelta.
    }
  }

  @override
  void dispose() {
    _envio?.cancel();
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

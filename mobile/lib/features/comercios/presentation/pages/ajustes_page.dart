import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../domain/entities/solicitud.dart';
import '../providers/alta_providers.dart';

/// Ajustes de la cuenta. Aquí la persona pide registrar su negocio y ve en qué va la
/// solicitud: VECI la revisa y, al aprobarla, queda como dueña (ADR-0019).
class AjustesPage extends ConsumerWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final solicitudes = ref.watch(misSolicitudesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misSolicitudesProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(VeciEspacio.l),
          children: [
            Text('Mi negocio en VECI', style: textos.titleLarge),
            const SizedBox(height: VeciEspacio.m),
            ...switch (solicitudes) {
              AsyncData(:final value) => _MiSolicitud(ultima: value.firstOrNull).piezas(context),
              AsyncError() => const [
                VeciAviso(
                  tono: TonoAviso.error,
                  mensaje:
                      'Para ver tu solicitud necesitas internet. Desliza hacia abajo '
                      'para intentar otra vez.',
                ),
              ],
              _ => const [Center(child: CircularProgressIndicator())],
            },
          ],
        ),
      ),
    );
  }
}

/// Lo que se ve según la última solicitud: ninguna, en revisión, rechazada o aprobada.
class _MiSolicitud {
  const _MiSolicitud({required this.ultima});

  final SolicitudDeNegocio? ultima;

  List<Widget> piezas(BuildContext context) {
    final ultima = this.ultima;
    void solicitar() => unawaited(context.push(Rutas.registrarNegocio));
    return switch (ultima?.estado) {
      null => [
        const Text(
          '¿Tienes un restaurante, una cafetería o una tienda? Pide que lo registremos y '
          'VECI lo revisa antes de abrirlo. Por ahora atendemos negocios en Mocoa.',
        ),
        const SizedBox(height: VeciEspacio.l),
        VeciBoton(texto: 'Solicitar el registro de mi negocio', grande: true, alTocar: solicitar),
      ],
      EstadoSolicitud.enRevision => [
        VeciAviso(
          tono: TonoAviso.aviso,
          mensaje:
              'Tu solicitud para ${ultima!.nombre} está en revisión. Cuando VECI la '
              'apruebe, aquí mismo entras a tu negocio.',
        ),
      ],
      EstadoSolicitud.rechazada => [
        VeciAviso(
          tono: TonoAviso.error,
          mensaje: 'No aprobamos la solicitud para ${ultima!.nombre}. ${ultima.nota ?? ''}'.trim(),
        ),
        const SizedBox(height: VeciEspacio.l),
        VeciBoton(texto: 'Enviar una nueva solicitud', grande: true, alTocar: solicitar),
      ],
      EstadoSolicitud.aprobada => [
        VeciAviso(tono: TonoAviso.exito, mensaje: '${ultima!.nombre} ya está en VECI.'),
        const SizedBox(height: VeciEspacio.l),
        _EntrarAlNegocio(comercioId: ultima.comercioId),
        TextButton(onPressed: solicitar, child: const Text('Solicitar otro negocio')),
      ],
    };
  }
}

/// Trae el negocio aprobado a la sesión y lo deja activo.
class _EntrarAlNegocio extends ConsumerWidget {
  const _EntrarAlNegocio({required this.comercioId});

  final String? comercioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comercioId = this.comercioId;
    return VeciBoton(
      texto: 'Entrar a mi negocio',
      icono: Icons.storefront,
      grande: true,
      alTocar: comercioId == null ? null : () => unawaited(_entrar(context, ref, comercioId)),
    );
  }

  Future<void> _entrar(BuildContext context, WidgetRef ref, String comercioId) async {
    await ref.read(gestorSesionProvider).estrenarNegocio(comercioId);
    if (context.mounted) context.go(Rutas.inicio);
  }
}

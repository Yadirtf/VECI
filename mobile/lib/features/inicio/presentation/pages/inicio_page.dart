import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';

/// Inicio con el negocio activo. Los modos Cajero y Cliente completos llegan en las
/// siguientes épicas; aquí ya se sabe quién es y con qué negocio trabaja.
class InicioPage extends StatelessWidget {
  const InicioPage({
    super.key,
    required this.nombre,
    required this.negocio,
    required this.enLaCaja,
    required this.variosNegocios,
    required this.alCambiarNegocio,
    required this.alSalir,
  });

  final String nombre;
  final String negocio;
  final bool enLaCaja;
  final bool variosNegocios;
  final Future<void> Function() alCambiarNegocio;
  final Future<void> Function() alSalir;

  List<Widget> _acciones() => [
    if (variosNegocios)
      IconButton(
        tooltip: 'Cambiar de negocio',
        icon: const Icon(Icons.swap_horiz),
        onPressed: () => unawaited(alCambiarNegocio()),
      ),
    TextButton(onPressed: () => unawaited(alSalir()), child: const Text('Salir')),
  ];

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(negocio), actions: _acciones()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VeciEspacio.l),
          children: [
            Text('¡Hola, $nombre!', style: textos.headlineSmall),
            const SizedBox(height: VeciEspacio.s),
            Text(
              enLaCaja
                  ? 'Tu aliado para vender y cobrar tiqueteras.'
                  : 'Aquí vas a ver tus tiqueteras y tu QR de este negocio.',
              style: textos.titleMedium,
            ),
            const SizedBox(height: VeciEspacio.l),
            if (!enLaCaja)
              const VeciAviso(
                tono: TonoAviso.aviso,
                mensaje: 'Muy pronto verás aquí tus almuerzos disponibles.',
              ),
            if (enLaCaja)
              VeciBoton(
                texto: 'Ver horarios',
                icono: Icons.schedule,
                grande: true,
                alTocar: () => context.push(Rutas.horarios),
              ),
            const SizedBox(height: VeciEspacio.m),
            VeciBoton(
              texto: 'Sistema de diseño',
              icono: Icons.palette,
              secundario: true,
              alTocar: () => context.push(Rutas.disenio),
            ),
          ],
        ),
      ),
    );
  }
}

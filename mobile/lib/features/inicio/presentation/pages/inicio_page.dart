import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_encabezado.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/saludo.dart';

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
    this.ahora = DateTime.now,
  });

  final String nombre;
  final String negocio;
  final bool enLaCaja;
  final bool variosNegocios;
  final Future<void> Function() alCambiarNegocio;
  final Future<void> Function() alSalir;
  final DateTime Function() ahora;

  List<Widget> _acciones() => [
    if (variosNegocios)
      TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: VeciColores.crema),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Cambiar'),
        onPressed: () => unawaited(alCambiarNegocio()),
      ),
    TextButton(
      style: TextButton.styleFrom(foregroundColor: VeciColores.crema),
      onPressed: () => unawaited(alSalir()),
      child: const Text('Salir'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          VeciEncabezado(
            antetitulo: negocio,
            titulo: '¡${saludoDelDia(ahora())}, ${primerNombre(nombre)}!',
            acciones: _acciones(),
          ),
          Expanded(child: _cuerpo(textos)),
          VeciMostrador(
            children: [
              if (enLaCaja)
                VeciBoton(
                  texto: 'Ver horarios',
                  icono: Icons.schedule,
                  grande: true,
                  alTocar: () => context.push(Rutas.horarios),
                ),
              VeciBoton(
                texto: 'Sistema de diseño',
                icono: Icons.palette,
                secundario: true,
                alTocar: () => context.push(Rutas.disenio),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cuerpo(TextTheme textos) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
    children: [
      VeciTarjeta(
        perforado: true,
        child: Text(
          enLaCaja
              ? 'Aquí estoy para ayudarte a vender y cobrar tiqueteras.'
              : 'Aquí vas a ver tus tiqueteras y tu QR de este negocio.',
          style: textos.titleMedium,
        ),
      ),
      if (!enLaCaja) ...[
        const SizedBox(height: VeciEspacio.l),
        const VeciAviso(
          tono: TonoAviso.aviso,
          mensaje: 'Muy pronto verás aquí tus almuerzos disponibles.',
        ),
      ],
    ],
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_encabezado.dart';

/// Encabezado de las pantallas del cliente: si es su inicio ofrece salir; si llegó desde
/// otra pantalla, volver.
class EncabezadoCliente extends ConsumerWidget {
  const EncabezadoCliente({
    super.key,
    required this.antetitulo,
    required this.titulo,
    this.explicacion,
  });

  final String antetitulo;
  final String titulo;
  final String? explicacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estilo = TextButton.styleFrom(foregroundColor: VeciColores.crema);
    return VeciEncabezado(
      antetitulo: antetitulo,
      titulo: titulo,
      explicacion: explicacion,
      acciones: [
        if (context.canPop())
          TextButton.icon(
            style: estilo,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
            onPressed: context.pop,
          )
        else
          TextButton(
            style: estilo,
            onPressed: () => unawaited(ref.read(gestorSesionProvider).salir()),
            child: const Text('Salir'),
          ),
      ],
    );
  }
}

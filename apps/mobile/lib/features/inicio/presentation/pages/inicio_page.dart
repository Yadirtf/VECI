import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_boton.dart';

/// Pantalla de bienvenida mientras llegan los modos Cajero y Cliente (EP-02).
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VeciEspacio.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('¡Hola, veci!', style: textos.headlineSmall),
              const SizedBox(height: VeciEspacio.s),
              Text('Tu aliado para vender y cobrar tiqueteras.', style: textos.titleMedium),
              const Spacer(),
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
      ),
    );
  }
}

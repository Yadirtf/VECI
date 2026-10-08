import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../providers/tiqueteras_providers.dart';
import '../widgets/historia_saldo.dart';
import '../widgets/saldos.dart';
import '../widgets/textos_tiqueteras.dart';

/// Saldo del cliente en el negocio (HU-05-03): cuánto le queda por unidad, la pila de
/// cartones (arriba el que se gasta primero) y la historia. Desde aquí se le vende.
class SaldoDelClientePage extends ConsumerWidget {
  const SaldoDelClientePage({super.key, required this.clienteId, this.nombre});

  final String clienteId;
  final String? nombre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuenta = ref.watch(cuentaDelClienteProvider(clienteId));
    return Scaffold(
      appBar: AppBar(title: Text(nombre ?? 'Tiqueteras del cliente')),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(cuentaDelClienteProvider(clienteId).future),
              child: ListView(
                padding: const EdgeInsets.all(VeciEspacio.m),
                children: switch (cuenta) {
                  AsyncData(:final value) => [
                    SaldosYCartones(cuenta: value),
                    if (value.movimientos.isNotEmpty) ...[
                      const SizedBox(height: VeciEspacio.l),
                      HistoriaSaldo(movimientos: value.movimientos),
                    ],
                  ],
                  AsyncError(:final error) => [
                    VeciAviso(tono: TonoAviso.aviso, mensaje: mensajeDeSaldo(error)),
                  ],
                  _ => const [Center(child: CircularProgressIndicator())],
                },
              ),
            ),
          ),
          VeciMostrador(
            children: [
              VeciBoton(
                texto: 'Vender tiquetera',
                icono: Icons.point_of_sale,
                grande: true,
                alTocar: () => unawaited(context.push(Rutas.venderA(clienteId, nombre: nombre))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/di/mi_qr_providers.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/mi_qr.dart';
import '../../domain/reglas/reglas_mi_qr.dart';
import '../providers/mi_qr_providers.dart';
import '../widgets/encabezado_cliente.dart';

/// Tus negocios (HU-04-03): donde la persona es cliente; cada uno abre su QR allí.
/// Es el inicio de quien ya es cliente de algún negocio y se ve sin internet.
class TusNegociosPage extends ConsumerWidget {
  const TusNegociosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vista = ref.watch(misNegociosProvider);
    final hoy = ref.watch(relojProvider)();
    return Scaffold(
      body: Column(
        children: [
          EncabezadoCliente(
            antetitulo: 'Tus negocios',
            titulo: '¡Hola, ${primerNombre(ref.watch(nombreDeLaPersonaProvider))}!',
            explicacion: 'Toca un negocio para ver tu QR allí.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
              children: [
                ..._lista(context, ref, vista, hoy),
                const SizedBox(height: VeciEspacio.l),
                const _QueVeCadaNegocio(),
                const SizedBox(height: VeciEspacio.m),
              ],
            ),
          ),
          VeciMostrador(
            children: [
              VeciBoton(
                texto: 'Mi QR personal',
                icono: Icons.qr_code_2,
                grande: true,
                alTocar: () => unawaited(context.push(Rutas.miQr)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _lista(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<VistaGuardada<List<NegocioDondeSoyCliente>>> vista,
    DateTime hoy,
  ) {
    final actual = vista.value;
    if (actual == null) {
      if (!vista.hasError) return const [Center(child: CircularProgressIndicator())];
      return [
        const VeciAviso(
          tono: TonoAviso.error,
          mensaje: 'Para ver tus negocios la primera vez necesitas internet. Conéctate, veci.',
        ),
        TextButton(
          onPressed: () => ref.invalidate(misNegociosProvider),
          child: const Text('Intentar otra vez'),
        ),
      ];
    }
    return [
      if (actual.sinSenal) ...[
        const VeciAviso(tono: TonoAviso.aviso, mensaje: 'Sin señal: te mostramos lo guardado.'),
        const SizedBox(height: VeciEspacio.m),
      ],
      if (actual.valor.isEmpty)
        const VeciTarjeta(
          perforado: true,
          child: Text(
            'Aún no eres cliente de ningún negocio. Muestra tu QR personal en tu negocio '
            'y quedas anotado.',
            style: TextStyle(fontSize: VeciTexto.cuerpo),
          ),
        ),
      for (final negocio in actual.valor)
        Card(
          margin: const EdgeInsets.only(bottom: VeciEspacio.m),
          child: ListTile(
            minTileHeight: VeciToque.botonGrande,
            leading: const Icon(Icons.storefront, color: VeciColores.selvaOscuro),
            title: Text(negocio.nombre, style: const TextStyle(fontSize: VeciTexto.subtitulo)),
            subtitle: Text('Cliente desde el ${fechaLegible(negocio.afiliadoEn, hoy)}'),
            trailing: const Icon(Icons.qr_code_2),
            onTap: () => unawaited(context.push(Rutas.qrDe(negocio.comercioId))),
          ),
        ),
    ];
  }
}

class _QueVeCadaNegocio extends StatelessWidget {
  const _QueVeCadaNegocio();

  @override
  Widget build(BuildContext context) => const VeciTarjeta(
    color: VeciColores.selvaClaro,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qué ve cada negocio de mí',
          style: TextStyle(
            fontSize: VeciTexto.subtitulo,
            fontWeight: VeciPeso.fuerte,
            color: VeciColores.selvaOscuro,
          ),
        ),
        SizedBox(height: VeciEspacio.xs),
        Text(queVeCadaNegocio, style: TextStyle(fontSize: VeciTexto.cuerpo)),
      ],
    ),
  );
}

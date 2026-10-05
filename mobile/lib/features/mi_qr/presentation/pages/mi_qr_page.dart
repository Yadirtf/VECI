import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/mi_qr_providers.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../domain/entities/mi_qr.dart';
import '../../domain/reglas/reglas_mi_qr.dart';
import '../providers/mi_qr_providers.dart';
import '../widgets/carnet_qr.dart';
import '../widgets/encabezado_cliente.dart';
import '../widgets/regenerar_qr.dart';

/// Mi QR (HU-04-02): el carnet para afiliarse en cualquier negocio. Es el inicio de
/// quien aún no es cliente de ningún negocio y se ve sin internet.
class MiQrPage extends ConsumerWidget {
  const MiQrPage({super.key});

  Future<void> _regenerar(WidgetRef ref) async {
    await ref.read(miQrRepositoryProvider).regenerar();
    ref.invalidate(miQrProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nombre = ref.watch(nombreDeLaPersonaProvider);
    final vista = ref.watch(miQrProvider);
    final negocios = ref.watch(misNegociosProvider).value?.valor ?? const [];
    final esInicio = !context.canPop();
    return Scaffold(
      body: Column(
        children: [
          EncabezadoCliente(
            antetitulo: 'Mi QR',
            titulo: '¡Hola, ${primerNombre(nombre)}!',
            explicacion: 'Este es tu QR de VECI.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
              children: [
                ..._carnet(ref, vista, nombre),
                if (negocios.isEmpty) ...[
                  const SizedBox(height: VeciEspacio.l),
                  const Text(
                    'Muéstralo en tu negocio y quedas anotado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
                  ),
                ],
                if (esInicio && ref.watch(soloClienteProvider))
                  TextButton(
                    onPressed: () => unawaited(context.push(Rutas.registrarNegocio)),
                    child: const Text('¿Tienes un negocio? Regístralo en VECI'),
                  ),
                const SizedBox(height: VeciEspacio.m),
              ],
            ),
          ),
          if (esInicio && negocios.isNotEmpty)
            VeciMostrador(
              children: [
                VeciBoton(
                  texto: 'Tus negocios',
                  icono: Icons.storefront,
                  grande: true,
                  alTocar: () => unawaited(context.push(Rutas.tusNegocios)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _carnet(WidgetRef ref, AsyncValue<VistaGuardada<MiQr>> vista, String nombre) {
    final actual = vista.value;
    if (actual == null) {
      if (!vista.hasError) return const [Center(child: CircularProgressIndicator())];
      return [
        const VeciAviso(
          tono: TonoAviso.error,
          mensaje: 'Para ver tu QR la primera vez necesitas internet. Conéctate, veci.',
        ),
        TextButton(
          onPressed: () => ref.invalidate(miQrProvider),
          child: const Text('Intentar otra vez'),
        ),
      ];
    }
    final qr = actual.valor;
    return [
      if (actual.sinSenal) ...[
        const VeciAviso(
          tono: TonoAviso.aviso,
          mensaje: 'Sin señal: este es tu QR guardado. Sirve igual.',
        ),
        const SizedBox(height: VeciEspacio.m),
      ],
      CarnetQr(key: ValueKey(qr.token), token: qr.token, nombre: nombre, version: qr.version),
      const SizedBox(height: VeciEspacio.l),
      RegenerarQr(alConfirmar: () => _regenerar(ref)),
    ];
  }
}

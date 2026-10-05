import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/veci_mostrador.dart';
import '../providers/lectura_qr_controller.dart';
import '../rutas_clientes.dart';
import '../widgets/panel_lectura.dart';
import '../widgets/visor_qr.dart';
import 'ficha_cliente_page.dart';

/// Cómo se ve la cámara: [activo] en false la pausa; [alLeer] recibe el texto del QR.
typedef ConstructorDeVisor = Widget Function(bool activo, ValueChanged<String> alLeer);

/// Escanear el QR personal del cliente (HU-04-02): solo QR y con la cámara de atrás.
/// Si es alguien por afiliar se confirma con su nombre; si ya es cliente, su ficha.
class EscanearQrPage extends ConsumerWidget {
  const EscanearQrPage({super.key, this.visor});

  /// Las pruebas cambian la cámara por un doble.
  final ConstructorDeVisor? visor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(lecturaQrProvider, (_, paso) {
      if (paso is! ListoParaFicha) return;
      final aviso = paso.recienAfiliado ? AvisoFicha.afiliado : AvisoFicha.yaEsCliente;
      context.pushReplacement(RutasClientes.fichaDe(paso.ficha.clienteId, aviso: aviso));
    });
    final paso = ref.watch(lecturaQrProvider);
    final controlador = ref.read(lecturaQrProvider.notifier);
    final construir = visor ?? (activo, alLeer) => VisorQr(activo: activo, alLeer: alLeer);
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Column(
        children: [
          Expanded(child: construir(paso is Mirando, controlador.leer)),
          VeciMostrador(
            children: [
              PanelLectura(
                paso: paso,
                alAfiliar: controlador.afiliar,
                alOtraVez: controlador.otraVez,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

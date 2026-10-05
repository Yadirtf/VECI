import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/mi_qr_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../domain/entities/mi_qr.dart';
import '../providers/mi_qr_providers.dart';
import '../widgets/carnet_qr.dart';

/// Mi QR en un negocio donde ya soy cliente (HU-04-03), desde lo guardado si no hay señal.
class QrEnNegocioPage extends ConsumerWidget {
  const QrEnNegocioPage({super.key, required this.comercioId});

  final String comercioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vista = ref.watch(misNegociosProvider).value;
    final negocio = vista?.valor.where((n) => n.comercioId == comercioId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(negocio?.nombre ?? 'Tu QR')),
      body: ListView(
        padding: const EdgeInsets.all(VeciEspacio.l),
        children: vista == null
            ? const [Center(child: CircularProgressIndicator())]
            : _contenido(ref.watch(nombreDeLaPersonaProvider), negocio),
      ),
    );
  }

  List<Widget> _contenido(String nombre, NegocioDondeSoyCliente? negocio) {
    final qr = negocio?.qr;
    if (negocio == null || qr == null) {
      return const [
        VeciAviso(
          tono: TonoAviso.aviso,
          mensaje: 'Aún no tenemos tu QR de este negocio. Muestra tu QR personal en la caja.',
        ),
      ];
    }
    return [
      CarnetQr(token: qr.token, nombre: nombre, version: qr.version, negocio: negocio.nombre),
      const SizedBox(height: VeciEspacio.l),
      Text(
        'Muéstralo en la caja de ${negocio.nombre}.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
      ),
    ];
  }
}

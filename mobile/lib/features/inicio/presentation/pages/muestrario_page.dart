import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_saldo.dart';
import '../../../../core/ui/veci_tarjeta.dart';

/// Muestra los componentes base de VECI para revisarlos al sol (HU-01-09).
class MuestrarioPage extends StatelessWidget {
  const MuestrarioPage({super.key});

  static const _espacio = SizedBox(height: VeciEspacio.m);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de diseño')),
      body: ListView(
        padding: const EdgeInsets.all(VeciEspacio.m),
        children: [
          VeciTarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                VeciSaldo(unidades: 12, singular: 'almuerzo', plural: 'almuerzos'),
                _espacio,
                VeciAviso(tono: TonoAviso.exito, mensaje: '¡Listo, veci! Te quedan 12 almuerzos.'),
                _espacio,
                VeciAviso(tono: TonoAviso.aviso, mensaje: '¡Ojo, veci! Le quedan 2 almuerzos.'),
                _espacio,
                VeciAviso(tono: TonoAviso.error, mensaje: 'Este QR es de otro negocio.'),
              ],
            ),
          ),
          _espacio,
          VeciBoton(
            texto: 'Cobrar con QR',
            icono: Icons.qr_code_scanner,
            grande: true,
            alTocar: () {},
          ),
          _espacio,
          VeciBoton(texto: 'Vender tiquetera', icono: Icons.sell, alTocar: () {}),
          _espacio,
          VeciBoton(texto: 'Buscar cliente', icono: Icons.search, secundario: true, alTocar: () {}),
          _espacio,
          const TextField(
            decoration: InputDecoration(labelText: 'Celular del cliente', hintText: '310 000 0000'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

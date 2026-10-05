import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_encabezado.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../../../core/ui/veci_tarjeta.dart';

/// Al terminar el registro: ya entró y ya tiene su QR (HU-04-01).
class Bienvenida extends StatelessWidget {
  const Bienvenida({super.key, required this.nombre, required this.alVerMiQr});

  final String nombre;
  final VoidCallback alVerMiQr;

  @override
  Widget build(BuildContext context) {
    final primero = nombre.trim().split(RegExp(r'\s+')).first;
    return Scaffold(
      body: Column(
        children: [
          VeciEncabezado(titulo: '¡Listo, ${primero.isEmpty ? 'veci' : primero}!'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
              children: const [
                Icon(Icons.qr_code_2, size: 120, color: VeciColores.selvaOscuro),
                SizedBox(height: VeciEspacio.m),
                VeciTarjeta(
                  perforado: true,
                  child: Text(
                    'Ya tienes tu QR. Muéstralo en tu negocio y quedas anotado.',
                    style: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
                  ),
                ),
                SizedBox(height: VeciEspacio.m),
                Text(
                  'Tu QR sirve sin internet. Entras con tu celular y tu PIN.',
                  style: TextStyle(fontSize: VeciTexto.cuerpo),
                ),
              ],
            ),
          ),
          VeciMostrador(
            children: [
              VeciBoton(
                texto: 'Ver mi QR',
                icono: Icons.qr_code_2,
                grande: true,
                alTocar: alVerMiQr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

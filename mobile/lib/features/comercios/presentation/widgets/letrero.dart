import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/alta.dart';
import '../../domain/reglas/reglas_alta.dart';
import 'sello_negocio.dart';

/// El resumen como el letrero que cuelga en la puerta del negocio.
class Letrero extends StatelessWidget {
  const Letrero({super.key, required this.borrador, this.tipo});

  final BorradorAlta borrador;
  final TipoDeNegocio? tipo;

  @override
  Widget build(BuildContext context) {
    final documento = documentoCompleto(borrador);
    final legible = borrador.esNit
        ? 'NIT ${documento.substring(0, documento.length - 1)}-${documento.substring(documento.length - 1)}'
        : 'Cédula $documento';
    return Column(
      children: [
        const Icon(Icons.circle, size: 12, color: VeciColores.tintaSuave),
        Transform.rotate(
          angle: -1.2 * math.pi / 180,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: VeciEspacio.s),
            padding: const EdgeInsets.all(VeciEspacio.l),
            decoration: BoxDecoration(
              color: VeciColores.arcillaClaro,
              border: Border.all(color: VeciColores.arcilla, width: 4),
              borderRadius: BorderRadius.circular(VeciRadio.l),
            ),
            child: Column(
              children: [
                SelloNegocio(nombre: borrador.nombre, tamano: 84),
                const SizedBox(height: VeciEspacio.s),
                Text(
                  borrador.nombre.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
                ),
                Text(tipo?.nombre ?? '', style: const TextStyle(color: VeciColores.arcilla)),
                const SizedBox(height: VeciEspacio.s),
                Text(legible),
                Text('Celular ${soloDigitos(borrador.celular)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: VeciEspacio.m),
        const Text('Así queda tu negocio. Arranca con 30 días de prueba gratis.'),
      ],
    );
  }
}

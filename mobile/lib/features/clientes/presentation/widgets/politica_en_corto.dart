import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/registro_asistido.dart';

/// La política de datos "en corto" para leerla en voz alta antes de registrar.
/// No hay casilla: el botón "Sí aceptó · Registrar" es la confirmación.
class PoliticaEnCortoTarjeta extends StatelessWidget {
  const PoliticaEnCortoTarjeta({super.key, required this.politica});

  final PoliticaEnCorto politica;

  @override
  Widget build(BuildContext context) => VeciTarjeta(
    perforado: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Léele esto en voz alta',
          style: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
        ),
        const SizedBox(height: VeciEspacio.s),
        Text(politica.paraQue, style: const TextStyle(fontSize: VeciTexto.cuerpo)),
        ..._lista('Lo que anotamos', politica.anotamos, Icons.edit_note),
        ..._lista('Lo que nunca hacemos', politica.nuncaHacemos, Icons.block),
        const SizedBox(height: VeciEspacio.m),
        const Text(
          '¿Está de acuerdo? Si dice que sí, toca "Sí aceptó · Registrar".',
          style: TextStyle(color: VeciColores.tintaSuave),
        ),
      ],
    ),
  );

  List<Widget> _lista(String titulo, List<String> puntos, IconData icono) => [
    const SizedBox(height: VeciEspacio.m),
    Text(titulo, style: const TextStyle(fontWeight: VeciPeso.fuerte)),
    for (final punto in puntos)
      Padding(
        padding: const EdgeInsets.only(top: VeciEspacio.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 20, color: VeciColores.selva),
            const SizedBox(width: VeciEspacio.s),
            Expanded(child: Text(punto)),
          ],
        ),
      ),
  ];
}

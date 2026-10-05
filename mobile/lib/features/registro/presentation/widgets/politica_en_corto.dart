import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/registro.dart';
import 'preguntas_registro.dart';

/// La política "en corto": qué anotamos, qué nunca hacemos y para qué. La completa
/// queda a un toque, para quien quiera leerla toda.
class PoliticaEnCorto extends StatelessWidget {
  const PoliticaEnCorto({super.key, required this.politica, required this.alLeerCompleta});

  final PoliticaDeDatos politica;
  final VoidCallback alLeerCompleta;

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: 'Así cuidamos tus datos',
    explicacion: 'Léelo con calma. Es corto.',
    children: [
      _Lista(titulo: 'Lo que anotamos', puntos: politica.anotamos, icono: Icons.edit_note),
      const SizedBox(height: VeciEspacio.m),
      _Lista(titulo: 'Lo que nunca hacemos', puntos: politica.nuncaHacemos, icono: Icons.block),
      const SizedBox(height: VeciEspacio.m),
      Text(
        'Para qué: ${politica.paraQue}',
        style: const TextStyle(fontSize: VeciTexto.cuerpo, fontWeight: VeciPeso.medio),
      ),
      const SizedBox(height: VeciEspacio.s),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: alLeerCompleta,
          icon: const Icon(Icons.menu_book),
          label: const Text('Leer la política completa'),
        ),
      ),
    ],
  );
}

class _Lista extends StatelessWidget {
  const _Lista({required this.titulo, required this.puntos, required this.icono});

  final String titulo;
  final List<String> puntos;
  final IconData icono;

  @override
  Widget build(BuildContext context) => VeciTarjeta(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: VeciColores.selvaOscuro),
            const SizedBox(width: VeciEspacio.s),
            Flexible(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: VeciTexto.subtitulo,
                  fontWeight: VeciPeso.fuerte,
                  color: VeciColores.selvaOscuro,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: VeciEspacio.s),
        for (final punto in puntos)
          Padding(
            padding: const EdgeInsets.only(bottom: VeciEspacio.xs),
            child: Text('•  $punto', style: const TextStyle(fontSize: VeciTexto.cuerpo)),
          ),
      ],
    ),
  );
}

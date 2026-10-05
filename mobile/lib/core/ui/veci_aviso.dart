import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';

enum TonoAviso { exito, aviso, error }

/// Mensaje en tono VECI, en un papelito perforado: dice qué pasó y qué hacer, sin
/// culpar a nadie. El sello de la izquierda cambia de forma según el tono (círculo,
/// triángulo, octágono), así el color nunca es la única señal.
class VeciAviso extends StatelessWidget {
  const VeciAviso({super.key, required this.tono, required this.mensaje});

  final TonoAviso tono;
  final String mensaje;

  static const _estilos = {
    TonoAviso.exito: (VeciColores.exito, VeciColores.exitoFondo, Icons.check_rounded),
    TonoAviso.aviso: (VeciColores.aviso, VeciColores.avisoFondo, Icons.priority_high_rounded),
    TonoAviso.error: (VeciColores.error, VeciColores.errorFondo, Icons.close_rounded),
  };

  static ShapeBorder _formaSello(TonoAviso tono) => switch (tono) {
    TonoAviso.exito => const CircleBorder(),
    TonoAviso.aviso => const StarBorder.polygon(sides: 3, pointRounding: 0.3),
    TonoAviso.error => const StarBorder.polygon(sides: 8, rotation: 22.5),
  };

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, icono) = _estilos[tono]!;
    const forma = PapelitoBorder(perforado: true);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(VeciEspacio.m).add(forma.dimensions),
        decoration: ShapeDecoration(color: fondo, shape: forma, shadows: VeciFormas.sombraPapel),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.only(top: tono == TonoAviso.aviso ? 8 : 0),
              decoration: ShapeDecoration(color: texto, shape: _formaSello(tono)),
              child: Icon(icono, color: fondo, size: tono == TonoAviso.aviso ? 20 : 26),
            ),
            const SizedBox(width: VeciEspacio.m),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(
                  color: texto,
                  fontSize: VeciTexto.cuerpo,
                  fontWeight: VeciPeso.medio,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

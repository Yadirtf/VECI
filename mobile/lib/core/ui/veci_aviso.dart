import 'package:flutter/material.dart';

import '../theme/veci_tokens.dart';

enum TonoAviso { exito, aviso, error }

/// Mensaje en tono VECI: dice qué pasó y qué hacer, sin culpar a nadie.
class VeciAviso extends StatelessWidget {
  const VeciAviso({super.key, required this.tono, required this.mensaje});

  final TonoAviso tono;
  final String mensaje;

  static const _colores = {
    TonoAviso.exito: (VeciColores.exito, VeciColores.exitoFondo, Icons.check_circle),
    TonoAviso.aviso: (VeciColores.aviso, VeciColores.avisoFondo, Icons.info),
    TonoAviso.error: (VeciColores.error, VeciColores.errorFondo, Icons.error),
  };

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, icono) = _colores[tono]!;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(VeciEspacio.m),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(VeciRadio.m),
          border: Border(left: BorderSide(color: texto, width: 8)),
        ),
        child: Row(
          children: [
            Icon(icono, color: texto, size: 28),
            const SizedBox(width: VeciEspacio.s),
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

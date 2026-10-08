import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_casillas.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/reglas/reglas_venta.dart';
import 'textos_tiqueteras.dart';

/// La tiquetera de cartón: su nombre, cuántas le quedan y una casilla por unidad, las
/// usadas perforadas. La que se gasta primero lo dice arriba (HU-05-03).
class CartonTiquetera extends StatelessWidget {
  const CartonTiquetera({super.key, required this.tiquetera});

  final Tiquetera tiquetera;

  @override
  Widget build(BuildContext context) {
    final t = tiquetera;
    return Opacity(
      opacity: t.vigente ? 1 : 0.6,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: VeciEspacio.s),
        padding: const EdgeInsets.all(VeciEspacio.m),
        decoration: BoxDecoration(
          color: VeciColores.crema,
          borderRadius: BorderRadius.circular(VeciRadio.m),
          border: Border.all(color: VeciColores.borde, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.turno == 1)
              const Text(
                'SE GASTA PRIMERO',
                style: TextStyle(
                  fontSize: VeciTexto.pequeno,
                  fontWeight: VeciPeso.fuerte,
                  color: VeciColores.selvaOscuro,
                ),
              ),
            Text(
              t.nombre,
              style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
            ),
            Text(detalleDeTiquetera(t, diaLegible(t.ultimoDia))),
            const SizedBox(height: VeciEspacio.s),
            if (t.compradas <= 60)
              VeciCasillas(usadas: t.compradas - t.saldo, total: t.compradas, tamano: 14),
          ],
        ),
      ),
    );
  }
}

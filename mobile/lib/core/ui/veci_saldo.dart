import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';
import 'veci_casillas.dart';

/// Saldo de una tiquetera en una colilla de boleto: "12 | almuerzos". Con [total]
/// muestra debajo la tiquetera de casillas: las usadas quedan perforadas.
class VeciSaldo extends StatelessWidget {
  const VeciSaldo({
    super.key,
    required this.unidades,
    required this.singular,
    required this.plural,
    this.total,
  });

  final int unidades;
  final String singular;
  final String plural;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final unidad = unidades == 1 ? singular : plural;
    final total = this.total;
    return Semantics(
      label: total == null ? 'Saldo: $unidades $unidad' : 'Saldo: $unidades $unidad de $total',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VeciEspacio.l + VeciForma.muesca,
          vertical: VeciEspacio.m,
        ),
        decoration: const ShapeDecoration(
          color: VeciColores.superficie,
          shape: ColillaBorder(side: BorderSide(color: VeciColores.borde, width: 1.5)),
          shadows: VeciFormas.sombraPapel,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cifra(unidad),
            if (total != null && total > 0) ...[
              const SizedBox(height: VeciEspacio.s),
              VeciCasillas(usadas: total - unidades, total: total),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cifra(String unidad) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$unidades',
        style: const TextStyle(
          fontSize: VeciTexto.saldo,
          fontWeight: VeciPeso.fuerte,
          color: VeciColores.selvaOscuro,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: VeciEspacio.m),
        child: _LineaDeCorte(),
      ),
      // En una tarjeta angosta la unidad baja de renglón en vez de salirse.
      Flexible(
        child: Text(
          unidad,
          style: const TextStyle(fontSize: VeciTexto.titulo, fontWeight: VeciPeso.medio),
        ),
      ),
    ],
  );
}

/// Línea punteada vertical entre la cifra y la unidad, como el corte de una colilla.
class _LineaDeCorte extends StatelessWidget {
  const _LineaDeCorte();

  @override
  Widget build(BuildContext context) => const CustomPaint(size: Size(2, 44), painter: _Puntos());
}

class _Puntos extends CustomPainter {
  const _Puntos();

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = VeciColores.borde
      ..strokeWidth = 2;
    for (var y = 0.0; y < size.height; y += 12) {
      canvas.drawLine(Offset(1, y), Offset(1, (y + 6).clamp(0, size.height)), pincel);
    }
  }

  @override
  bool shouldRepaint(_Puntos oldDelegate) => false;
}

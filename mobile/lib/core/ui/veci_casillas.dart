import 'package:flutter/material.dart';

import '../theme/veci_tokens.dart';

/// La tiquetera de cartón: una casilla por unidad. Las usadas quedan perforadas
/// (aro con hueco) y las disponibles, llenas. La forma, no solo el color, dice cuál es cuál.
class VeciCasillas extends StatelessWidget {
  const VeciCasillas({super.key, required this.usadas, required this.total, this.tamano = 18});

  final int usadas;
  final int total;
  final double tamano;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: VeciEspacio.xs,
    runSpacing: VeciEspacio.xs,
    children: [
      for (var i = 0; i < total; i++)
        CustomPaint(
          size: Size.square(tamano),
          painter: _Casilla(perforada: i < usadas),
        ),
    ],
  );
}

class _Casilla extends CustomPainter {
  const _Casilla({required this.perforada});

  final bool perforada;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;
    if (perforada) {
      canvas.drawCircle(
        centro,
        radio - 1.5,
        Paint()
          ..color = VeciColores.borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      return;
    }
    canvas.drawCircle(centro, radio, Paint()..color = VeciColores.selva);
  }

  @override
  bool shouldRepaint(_Casilla oldDelegate) => oldDelegate.perforada != perforada;
}

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';

/// El avance como piedras para cruzar la quebrada: pisadas (maíz), la actual (selva)
/// y las que faltan, solo contorno. No es una barra: se camina.
class PiedrasDelCamino extends StatelessWidget {
  const PiedrasDelCamino({super.key, required this.total, required this.actual});

  final int total;
  final int actual;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Paso ${actual + 1} de $total',
    child: SizedBox(
      height: 44,
      width: double.infinity,
      child: CustomPaint(painter: _Piedras(total, actual)),
    ),
  );
}

class _Piedras extends CustomPainter {
  _Piedras(this.total, this.actual);

  final int total;
  final int actual;

  @override
  void paint(Canvas canvas, Size size) {
    final agua = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width / 4, size.height * 0.2, size.width / 2, size.height * 0.6)
      ..quadraticBezierTo(size.width * 3 / 4, size.height, size.width, size.height * 0.6);
    canvas.drawPath(
      agua,
      Paint()
        ..color = VeciColores.selvaClaro
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    final paso = size.width / total;
    for (var i = 0; i < total; i++) {
      final centro = Offset(paso * (i + 0.5), size.height / 2 + (i.isOdd ? -6 : 6));
      final esActual = i == actual;
      final piedra = Rect.fromCenter(
        center: centro,
        width: esActual ? 30 : 24,
        height: esActual ? 20 : 15,
      );
      final relleno = Paint()
        ..color = esActual
            ? VeciColores.selva
            : i < actual
            ? VeciColores.maiz
            : VeciColores.crema;
      canvas.drawOval(piedra, relleno);
      if (i > actual) {
        canvas.drawOval(
          piedra,
          Paint()
            ..color = VeciColores.borde
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Piedras anterior) => anterior.actual != actual || anterior.total != total;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/reglas/reglas_alta.dart';

/// Sello de borde ondulado con la inicial del negocio: su cara mientras no hay logo.
class SelloNegocio extends StatelessWidget {
  const SelloNegocio({super.key, required this.nombre, this.tamano = 96});

  final String nombre;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(
      painter: _Sello(),
      child: Center(
        child: Text(
          inicialDe(nombre),
          style: TextStyle(
            color: VeciColores.crema,
            fontSize: tamano * 0.36,
            fontWeight: VeciPeso.fuerte,
          ),
        ),
      ),
    ),
  );
}

class _Sello extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final r = size.width / 2;
    const ondas = 18;
    final borde = Path();
    for (var i = 0; i <= ondas * 2; i++) {
      final angulo = math.pi * i / ondas;
      final radio = i.isOdd ? r * 0.9 : r;
      final punto = centro + Offset(math.cos(angulo), math.sin(angulo)) * radio;
      i == 0 ? borde.moveTo(punto.dx, punto.dy) : borde.lineTo(punto.dx, punto.dy);
    }
    canvas.drawPath(borde, Paint()..color = VeciColores.maiz);
    canvas.drawCircle(centro, r * 0.72, Paint()..color = VeciColores.selvaOscuro);
  }

  @override
  bool shouldRepaint(_Sello anterior) => false;
}

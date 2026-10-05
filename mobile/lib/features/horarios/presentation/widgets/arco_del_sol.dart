import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/horario.dart';

const _amanecer = 5 * 60;
const _anochecer = 22 * 60;
const _colores = [VeciColores.maiz, VeciColores.selva, VeciColores.arcilla];

/// El día de servicio como el camino del sol (igual que en el panel): cada servicio
/// es un tramo grueso y un sol pequeño marca la hora. Se dibuja con lo guardado en
/// el celular, así que funciona sin internet.
class ArcoDelSol extends StatelessWidget {
  const ArcoDelSol({
    super.key,
    required this.horarios,
    required this.ahora,
    required this.etiqueta,
  });

  final List<Horario> horarios;
  final DateTime ahora;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => Semantics(
    label: etiqueta,
    child: AspectRatio(
      aspectRatio: 2,
      child: CustomPaint(painter: _PintorArco(horarios, ahora.hour * 60 + ahora.minute)),
    ),
  );
}

class _PintorArco extends CustomPainter {
  _PintorArco(this.horarios, this.minuto);

  final List<Horario> horarios;
  final int minuto;

  double _angulo(int m) {
    final fraccion = (m.clamp(_amanecer, _anochecer) - _amanecer) / (_anochecer - _amanecer);
    return math.pi * (1 + fraccion);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radio = math.min(size.width / 2 - 24, size.height - 24);
    final centro = Offset(size.width / 2, size.height - 8);
    final rect = Rect.fromCircle(center: centro, radius: radio);
    final camino = Paint()
      ..color = VeciColores.borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(rect, math.pi, math.pi, false, camino);
    for (final (i, h) in horarios.indexed) {
      final tramo = Paint()
        ..color = _colores[i % _colores.length].withValues(alpha: h.activo ? 1 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 22;
      final inicio = _angulo(h.minutoInicio);
      canvas.drawArc(rect, inicio, _angulo(h.minutoFin) - inicio, false, tramo);
    }
    if (minuto >= _amanecer && minuto <= _anochecer) {
      final a = _angulo(minuto);
      final sol = centro + Offset(math.cos(a), math.sin(a)) * (radio - 30);
      canvas.drawCircle(sol, 10, Paint()..color = VeciColores.maiz);
      canvas.drawCircle(
        sol,
        10,
        Paint()
          ..color = VeciColores.arcilla
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorArco anterior) =>
      anterior.minuto != minuto || anterior.horarios != horarios;
}

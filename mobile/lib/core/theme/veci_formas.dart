import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'veci_tokens.dart';

/// Gramática de formas de VECI («El papelito del vecino»): la forma dice qué es,
/// así el color nunca es la única señal.
/// - Papelito dentado: VECI te habla (tarjetas y avisos).
/// - Piedra de canto: lo que tú haces (botones).
/// - Chaflán: cuidado, no se deshace.
/// - Colilla con muescas: el saldo.
/// - Arco: dónde estás (encabezado) y la zona del pulgar (mostrador).
abstract final class VeciFormas {
  /// Piedra de río: esquinas en diagonal más redondas que las otras. Nunca una cápsula perfecta.
  static RoundedRectangleBorder piedra({BorderSide side = BorderSide.none}) {
    const grande = Radius.elliptical(VeciRadio.piedra, VeciRadio.piedra * 0.85);
    const chica = Radius.circular(VeciRadio.piedraChica);
    return RoundedRectangleBorder(
      side: side,
      borderRadius: const BorderRadius.only(
        topLeft: grande,
        topRight: chica,
        bottomLeft: chica,
        bottomRight: grande,
      ),
    );
  }

  /// Esquinas cortadas: la acción que no se puede deshacer.
  static BeveledRectangleBorder chaflan({BorderSide side = BorderSide.none}) =>
      BeveledRectangleBorder(side: side, borderRadius: BorderRadius.circular(VeciForma.chaflan));

  /// Sombra dura, sin desenfoque: barata en gama baja y se ve al sol.
  static const sombraPapel = [
    BoxShadow(color: VeciColores.sombraPapel, offset: Offset(0, VeciForma.sombra)),
  ];
}

/// Papel de talonario arrancado: arriba recto con esquinas de 6 px y abajo dientes
/// de 12 × 6 px. Con [perforado], una fila de huecos arriba como la del talonario.
class PapelitoBorder extends OutlinedBorder {
  const PapelitoBorder({super.side, this.perforado = false, this.colorHuecos = VeciColores.crema});

  final bool perforado;
  final Color colorHuecos;

  static const _radio = 6.0;

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: VeciForma.dienteAlto, top: perforado ? VeciForma.perforacion : 0);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final abajo = rect.bottom - VeciForma.dienteAlto;
    final dientes = math.max(1, (rect.width / VeciForma.dienteAncho).floor());
    final ancho = rect.width / dientes;
    final path = Path()
      ..moveTo(rect.left, rect.top + _radio)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + _radio, rect.top)
      ..lineTo(rect.right - _radio, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + _radio)
      ..lineTo(rect.right, abajo);
    for (var i = dientes - 1; i >= 0; i--) {
      final x = rect.left + i * ancho;
      path
        ..lineTo(x + ancho / 2, rect.bottom)
        ..lineTo(x, abajo);
    }
    return path..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.strokeInset), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.none) {
      canvas.drawPath(getOuterPath(rect), side.toPaint());
    }
    if (!perforado) return;
    final huecos = Paint()..color = colorHuecos;
    final aro = Paint()
      ..color = VeciColores.sombraPapel
      ..style = PaintingStyle.stroke;
    for (
      var x = rect.left + VeciForma.perforacion;
      x < rect.right - 4;
      x += VeciForma.perforacion
    ) {
      final centro = Offset(x, rect.top + 6);
      canvas
        ..drawCircle(centro, 2.5, huecos)
        ..drawCircle(centro, 2.5, aro);
    }
  }

  @override
  PapelitoBorder copyWith({BorderSide? side}) =>
      PapelitoBorder(side: side ?? this.side, perforado: perforado, colorHuecos: colorHuecos);

  @override
  ShapeBorder scale(double t) => copyWith(side: side.scale(t));
}

/// Colilla de boleto: rectángulo redondeado con una muesca semicircular a cada lado.
class ColillaBorder extends OutlinedBorder {
  const ColillaBorder({super.side});

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cuerpo = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(VeciRadio.m)));
    final y = rect.center.dy;
    final muescas = Path()
      ..addOval(Rect.fromCircle(center: Offset(rect.left, y), radius: VeciForma.muesca))
      ..addOval(Rect.fromCircle(center: Offset(rect.right, y), radius: VeciForma.muesca));
    return Path.combine(PathOperation.difference, cuerpo, muescas);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.strokeInset));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.none) canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  ColillaBorder copyWith({BorderSide? side}) => ColillaBorder(side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => copyWith(side: side.scale(t));
}

/// Borde con un lado en arco suave de [VeciForma.arco] px. [abajo] curva el borde
/// inferior hacia afuera (encabezado: "aquí estás"); si no, el superior (mostrador).
class ArcoBorder extends OutlinedBorder {
  const ArcoBorder({super.side, this.abajo = true});

  final bool abajo;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const flecha = VeciForma.arco;
    if (abajo) {
      return Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..quadraticBezierTo(rect.center.dx, rect.bottom + flecha * 2, rect.left, rect.bottom)
        ..close();
    }
    return Path()
      ..moveTo(rect.left, rect.top)
      ..quadraticBezierTo(rect.center.dx, rect.top - flecha * 2, rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  /// Solo traza el lado curvo, para separar la franja del fondo sin sombras.
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final y = abajo ? rect.bottom : rect.top;
    final control = abajo ? rect.bottom + VeciForma.arco * 2 : rect.top - VeciForma.arco * 2;
    final curva = Path()
      ..moveTo(rect.left, y)
      ..quadraticBezierTo(rect.center.dx, control, rect.right, y);
    canvas.drawPath(curva, side.toPaint());
  }

  @override
  ArcoBorder copyWith({BorderSide? side}) => ArcoBorder(side: side ?? this.side, abajo: abajo);

  @override
  ShapeBorder scale(double t) => this;
}

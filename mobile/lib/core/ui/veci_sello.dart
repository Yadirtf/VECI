import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/veci_tokens.dart';

/// El sello de tinta que cae cuando algo quedó registrado ("¡Listo, veci! Quedan 12").
/// Sale un poco torcido, con un ángulo que depende de [semilla] (por ejemplo, el id
/// del consumo): cada sello es distinto, como los de la tiquetera de cartón, pero el
/// mismo consumo siempre se ve igual. La cifra nunca se tuerce respecto al sello.
class VeciSello extends StatefulWidget {
  const VeciSello({
    super.key,
    required this.cifra,
    required this.arriba,
    required this.abajo,
    required this.semilla,
    this.vibrar = true,
  });

  final String cifra;
  final String arriba;
  final String abajo;
  final String semilla;

  /// Golpe corto en la mano: la cajera sabe que quedó sin mirar la pantalla.
  final bool vibrar;

  /// Ángulo en grados entre −8 y 8, estable para la misma semilla.
  static double anguloPara(String semilla) {
    final suma = semilla.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
    return (suma % 17) - 8.0;
  }

  @override
  State<VeciSello> createState() => _VeciSelloState();
}

class _VeciSelloState extends State<VeciSello> {
  @override
  void initState() {
    super.initState();
    if (widget.vibrar) unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(BuildContext context) {
    final quieto = MediaQuery.disableAnimationsOf(context);
    final angulo = VeciSello.anguloPara(widget.semilla) * math.pi / 180;
    return Semantics(
      liveRegion: true,
      label: '${widget.arriba} ${widget.cifra} ${widget.abajo}',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: quieto ? 1 : 1.15, end: 1),
        duration: quieto ? Duration.zero : const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        builder: (context, escala, hijo) => Transform.scale(scale: escala, child: hijo),
        child: Transform.rotate(angle: angulo, child: _cara()),
      ),
    );
  }

  Widget _cara() => Container(
    width: 200,
    height: 200,
    padding: const EdgeInsets.all(6),
    decoration: const ShapeDecoration(
      color: VeciColores.selvaClaro,
      shape: CircleBorder(side: BorderSide(color: VeciColores.selvaOscuro, width: 4)),
    ),
    child: DecoratedBox(
      decoration: const ShapeDecoration(
        shape: CircleBorder(side: BorderSide(color: VeciColores.selvaOscuro, width: 1.5)),
      ),
      // Con letra grande del celular o una unidad larga, el texto se achica y no se sale.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _texto(widget.arriba, VeciTexto.cuerpo),
            Text(
              widget.cifra,
              style: const TextStyle(
                fontSize: VeciTexto.sello,
                height: 1.05,
                fontWeight: VeciPeso.fuerte,
                color: VeciColores.selvaOscuro,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            _texto(widget.abajo, VeciTexto.cuerpo),
          ],
        ),
      ),
    ),
  );

  Widget _texto(String texto, double tamano) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
    child: Text(
      texto,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TextStyle(
        fontSize: tamano,
        fontWeight: VeciPeso.fuerte,
        color: VeciColores.selvaOscuro,
      ),
    ),
  );
}

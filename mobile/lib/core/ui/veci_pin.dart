import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/veci_tokens.dart';

/// PIN como una tiquetera: una casilla por número que se perfora al escribirlo, sin
/// mostrar el número. Debajo hay un campo normal (teclado numérico, lector de
/// pantalla y pegar funcionan igual); solo se ven las casillas.
class VeciPin extends StatelessWidget {
  const VeciPin({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.ayuda,
    this.alTerminar,
    this.largo = 6,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? ayuda;
  final VoidCallback? alTerminar;
  final int largo;

  static const _casilla = 30.0;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      TextField(
        controller: controlador,
        obscureText: true,
        showCursor: false,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.number,
        maxLength: largo,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.transparent, fontSize: _casilla),
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda, counterText: ''),
        onSubmitted: (_) => alTerminar?.call(),
      ),
      Positioned(
        left: VeciEspacio.m + VeciEspacio.xs,
        top: VeciEspacio.l + VeciEspacio.xs,
        child: IgnorePointer(
          child: ListenableBuilder(
            listenable: controlador,
            builder: (context, _) => _casillas(controlador.text.length),
          ),
        ),
      ),
    ],
  );

  Widget _casillas(int llenas) => Padding(
    padding: const EdgeInsets.only(top: VeciEspacio.s),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < largo; i++)
          Padding(
            padding: const EdgeInsets.only(right: VeciEspacio.s),
            child: CustomPaint(size: const Size.square(_casilla), painter: _CasillaPin(i < llenas)),
          ),
      ],
    ),
  );
}

/// Vacía: aro punteado. Llena: disco selva con hueco, como una perforación.
class _CasillaPin extends CustomPainter {
  const _CasillaPin(this.llena);

  final bool llena;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;
    if (!llena) {
      canvas.drawCircle(
        centro,
        radio - 1.5,
        Paint()
          ..color = VeciColores.borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      return;
    }
    canvas
      ..drawCircle(centro, radio, Paint()..color = VeciColores.selva)
      ..drawCircle(centro, radio * 0.32, Paint()..color = VeciColores.superficie);
  }

  @override
  bool shouldRepaint(_CasillaPin oldDelegate) => oldDelegate.llena != llena;
}

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';

/// El PIN de bienvenida grande, en dos grupos de 3, para dictarlo al cliente.
class PinParaDictar extends StatelessWidget {
  const PinParaDictar({super.key, required this.pin});

  final String pin;

  String get _agrupado => pin.length == 6 ? '${pin.substring(0, 3)} ${pin.substring(3)}' : pin;

  @override
  Widget build(BuildContext context) => VeciTarjeta(
    perforado: true,
    color: VeciColores.selvaClaro,
    child: Column(
      children: [
        const Text(
          'Díctale su PIN de bienvenida',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
        ),
        const SizedBox(height: VeciEspacio.m),
        Semantics(
          label: 'PIN ${pin.split('').join(' ')}',
          excludeSemantics: true,
          child: Text(
            _agrupado,
            style: const TextStyle(
              fontSize: VeciTexto.sello,
              fontWeight: VeciPeso.fuerte,
              color: VeciColores.selvaOscuro,
              letterSpacing: 6,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: VeciEspacio.m),
        const Text(
          'Sirve 7 días. Con su celular y este PIN activa su app.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: VeciTexto.cuerpo),
        ),
      ],
    ),
  );
}

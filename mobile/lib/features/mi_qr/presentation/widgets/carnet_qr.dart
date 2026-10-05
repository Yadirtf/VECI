import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/veci_formas.dart';
import '../../../../core/theme/veci_tokens.dart';

/// El carnet: QR grande sobre un papelito, el nombre debajo, el sello con el número del
/// QR y la promesa de que sirve sin internet.
class CarnetQr extends StatelessWidget {
  const CarnetQr({
    super.key,
    required this.token,
    required this.nombre,
    required this.version,
    this.negocio,
  });

  final String token;
  final String nombre;
  final int version;

  /// Si es el QR de un negocio, su nombre arriba.
  final String? negocio;

  @override
  Widget build(BuildContext context) {
    const forma = PapelitoBorder(perforado: true);
    final negocio = this.negocio;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VeciEspacio.l).add(forma.dimensions),
      decoration: const ShapeDecoration(
        color: VeciColores.superficie,
        shape: forma,
        shadows: VeciFormas.sombraPapel,
      ),
      child: Column(
        children: [
          if (negocio != null)
            Text(negocio, textAlign: TextAlign.center, style: _estilo(VeciTexto.subtitulo)),
          LayoutBuilder(
            builder: (context, limites) => Semantics(
              label: negocio == null ? 'Tu QR de VECI' : 'Tu QR en $negocio',
              image: true,
              child: QrImageView(
                data: token,
                size: math.min(limites.maxWidth, 300),
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: VeciColores.tinta),
                dataModuleStyle: const QrDataModuleStyle(color: VeciColores.tinta),
              ),
            ),
          ),
          const SizedBox(height: VeciEspacio.s),
          Text(nombre, textAlign: TextAlign.center, style: _estilo(VeciTexto.titulo)),
          const SizedBox(height: VeciEspacio.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SelloNumero(version: version),
              const SizedBox(width: VeciEspacio.m),
              const Icon(Icons.wifi_off, color: VeciColores.selvaOscuro),
              const SizedBox(width: VeciEspacio.xs),
              Flexible(child: Text('Sirve sin internet', style: _estilo(VeciTexto.cuerpo))),
            ],
          ),
        ],
      ),
    );
  }

  static TextStyle _estilo(double tamano) =>
      TextStyle(fontSize: tamano, fontWeight: VeciPeso.fuerte, color: VeciColores.selvaOscuro);
}

/// Sello pequeño y algo torcido con el número del QR: si lo cambia, cambia el número.
class _SelloNumero extends StatelessWidget {
  const _SelloNumero({required this.version});

  final int version;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -6 * math.pi / 180,
    child: Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        color: VeciColores.selvaClaro,
        shape: CircleBorder(side: BorderSide(color: VeciColores.selvaOscuro, width: 3)),
      ),
      child: Text(
        'N.º $version',
        style: const TextStyle(
          fontSize: VeciTexto.cuerpo,
          fontWeight: VeciPeso.fuerte,
          color: VeciColores.selvaOscuro,
        ),
      ),
    ),
  );
}

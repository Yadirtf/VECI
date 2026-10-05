import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/veci_tokens.dart';

/// La cámara de atrás leyendo solo QR (ADR-0011). Se pausa mientras se muestra un
/// resultado, así no lee dos veces ni gasta batería.
class VisorQr extends StatefulWidget {
  const VisorQr({super.key, required this.activo, required this.alLeer});

  final bool activo;
  final ValueChanged<String> alLeer;

  @override
  State<VisorQr> createState() => _VisorQrState();
}

class _VisorQrState extends State<VisorQr> {
  final _camara = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void didUpdateWidget(VisorQr anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.activo == widget.activo) return;
    unawaited(widget.activo ? _camara.start() : _camara.stop());
  }

  @override
  void dispose() {
    unawaited(_camara.dispose());
    super.dispose();
  }

  void _detectar(BarcodeCapture captura) {
    if (!widget.activo) return;
    for (final codigo in captura.barcodes) {
      final texto = codigo.rawValue;
      if (texto != null && texto.isNotEmpty) return widget.alLeer(texto);
    }
  }

  @override
  Widget build(BuildContext context) => ClipRect(
    child: MobileScanner(
      controller: _camara,
      onDetect: _detectar,
      errorBuilder: (context, error) => const _SinCamara(),
    ),
  );
}

class _SinCamara extends StatelessWidget {
  const _SinCamara();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: VeciColores.crema,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(VeciEspacio.l),
        child: Text(
          'No pudimos abrir la cámara. Dale permiso a VECI en los ajustes del celular, '
          'o busca al cliente por su nombre.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: VeciTexto.cuerpo),
        ),
      ),
    ),
  );
}

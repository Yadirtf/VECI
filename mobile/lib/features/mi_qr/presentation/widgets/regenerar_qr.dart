import 'package:flutter/material.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';

/// Cambiar el QR, en línea y sin ventanas: el botón con chaflán (no se deshace) primero
/// explica qué pasa y pide confirmar ahí mismo (HU-04-02).
class RegenerarQr extends StatefulWidget {
  const RegenerarQr({super.key, required this.alConfirmar});

  /// Pide el QR nuevo; si falla, lanza el fallo para explicarlo.
  final Future<void> Function() alConfirmar;

  @override
  State<RegenerarQr> createState() => _RegenerarQrState();
}

class _RegenerarQrState extends State<RegenerarQr> {
  var _confirmando = false;
  var _ocupado = false;
  var _listo = false;
  String? _problema;

  void _preguntar(bool confirmando) => setState(() {
    _confirmando = confirmando;
    _problema = null;
    _listo = false;
  });

  Future<void> _confirmar() async {
    setState(() => _ocupado = true);
    try {
      await widget.alConfirmar();
      if (mounted) {
        setState(() {
          _confirmando = false;
          _listo = true;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _problema = _mensaje(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  static String _mensaje(Object error) => switch (error) {
    SinConexion() => 'Para cambiar tu QR necesitas internet. El de ahora sigue sirviendo.',
    PeticionRechazada(:final mensaje) => mensaje,
    _ => 'No pudimos cambiar tu QR. El de ahora sigue sirviendo.',
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_listo) ...[
        const VeciAviso(tono: TonoAviso.exito, mensaje: '¡Listo! Este es tu QR nuevo.'),
        const SizedBox(height: VeciEspacio.m),
      ],
      if (_confirmando) ..._confirmacion() else _botonCambiar(),
      if (_problema != null) ...[
        const SizedBox(height: VeciEspacio.m),
        VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
      ],
    ],
  );

  Widget _botonCambiar() => VeciBoton(
    texto: 'Cambiar mi QR',
    icono: Icons.autorenew,
    peligro: true,
    alTocar: () => _preguntar(true),
  );

  List<Widget> _confirmacion() => [
    const VeciAviso(
      tono: TonoAviso.aviso,
      mensaje: 'El QR anterior deja de servir. Sigues siendo cliente de tus negocios.',
    ),
    const SizedBox(height: VeciEspacio.m),
    VeciBoton(
      texto: _ocupado ? 'Cambiando tu QR…' : 'Sí, cambiar mi QR',
      icono: Icons.autorenew,
      peligro: true,
      alTocar: _ocupado ? null : _confirmar,
    ),
    TextButton(
      onPressed: _ocupado ? null : () => _preguntar(false),
      child: const Text('No, dejarlo así'),
    ),
  ];
}

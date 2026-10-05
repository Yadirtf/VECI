import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_encabezado.dart';
import '../../../../core/ui/veci_mostrador.dart';
import 'mensaje_de_fallo.dart';

/// Esqueleto de las pantallas de ingreso: encabezado en arco que saluda, campos en el
/// medio y el botón en el mostrador de abajo, al alcance del pulgar. El botón se
/// bloquea mientras el servidor responde.
class FormularioConEspera extends StatefulWidget {
  const FormularioConEspera({
    super.key,
    required this.titulo,
    required this.explicacion,
    required this.campos,
    required this.textoBoton,
    required this.validar,
    required this.enviar,
    this.avisoInicial,
  });

  final String titulo;
  final String explicacion;
  final List<Widget> campos;
  final String textoBoton;

  /// Revisión antes de enviar; devuelve el problema o null si todo está bien.
  final String? Function() validar;
  final Future<void> Function() enviar;
  final String? avisoInicial;

  @override
  State<FormularioConEspera> createState() => _FormularioConEsperaState();
}

class _FormularioConEsperaState extends State<FormularioConEspera> {
  bool _ocupado = false;
  String? _problema;

  Future<void> _enviar() async {
    final problema = widget.validar();
    setState(() => _problema = problema);
    if (problema != null) return;
    setState(() => _ocupado = true);
    try {
      await widget.enviar();
    } on Object catch (error) {
      if (mounted) setState(() => _problema = mensajeDeFallo(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aviso = widget.avisoInicial;
    return Column(
      children: [
        VeciEncabezado(titulo: widget.titulo, explicacion: widget.explicacion),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: VeciEspacio.l),
            children: [
              if (aviso != null && _problema == null) ...[
                VeciAviso(tono: TonoAviso.aviso, mensaje: aviso),
                const SizedBox(height: VeciEspacio.l),
              ],
              ...widget.campos,
              if (_problema != null) ...[
                const SizedBox(height: VeciEspacio.l),
                VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
              ],
              const SizedBox(height: VeciEspacio.m),
            ],
          ),
        ),
        VeciMostrador(
          children: [
            VeciBoton(
              texto: _ocupado ? 'Un momento…' : widget.textoBoton,
              grande: true,
              alTocar: _ocupado ? null : _enviar,
            ),
          ],
        ),
      ],
    );
  }
}

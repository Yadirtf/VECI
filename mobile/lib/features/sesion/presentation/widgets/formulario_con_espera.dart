import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import 'mensaje_de_fallo.dart';

/// Esqueleto de las pantallas de ingreso: título, campos, aviso de error y un botón
/// que se bloquea mientras el servidor responde.
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
    final textos = Theme.of(context).textTheme;
    final aviso = widget.avisoInicial;
    return ListView(
      padding: const EdgeInsets.all(VeciEspacio.l),
      children: [
        Text(widget.titulo, style: textos.headlineSmall),
        const SizedBox(height: VeciEspacio.s),
        Text(widget.explicacion, style: textos.titleMedium),
        const SizedBox(height: VeciEspacio.l),
        if (aviso != null && _problema == null) ...[
          VeciAviso(tono: TonoAviso.aviso, mensaje: aviso),
          const SizedBox(height: VeciEspacio.m),
        ],
        ...widget.campos,
        const SizedBox(height: VeciEspacio.m),
        if (_problema != null) ...[
          VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
          const SizedBox(height: VeciEspacio.m),
        ],
        VeciBoton(
          texto: _ocupado ? 'Un momento…' : widget.textoBoton,
          grande: true,
          alTocar: _ocupado ? null : _enviar,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';

/// Banda de arriba con borde en arco: dice dónde estás y quién te saluda. Va en el
/// cuerpo del Scaffold (sin AppBar) en las pantallas de entrada e inicio.
class VeciEncabezado extends StatelessWidget {
  const VeciEncabezado({
    super.key,
    required this.titulo,
    this.antetitulo,
    this.explicacion,
    this.acciones = const [],
  });

  final String titulo;

  /// Línea pequeña sobre el título; por ejemplo, el nombre del negocio.
  final String? antetitulo;
  final String? explicacion;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: VeciForma.arco),
    child: Material(
      color: VeciColores.selvaOscuro,
      shape: const ArcoBorder(),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VeciEspacio.l,
            VeciEspacio.m,
            VeciEspacio.l,
            VeciEspacio.s,
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: VeciColores.crema),
            child: SizedBox(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _lineas()),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _lineas() {
    final antetitulo = this.antetitulo;
    final explicacion = this.explicacion;
    return [
      if (acciones.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.end, children: acciones),
      if (antetitulo != null)
        Text(
          antetitulo,
          style: const TextStyle(fontSize: VeciTexto.cuerpo, fontWeight: VeciPeso.medio),
        ),
      Text(
        titulo,
        style: const TextStyle(
          fontSize: VeciTexto.grande,
          fontWeight: VeciPeso.fuerte,
          height: 1.15,
        ),
      ),
      if (explicacion != null) ...[
        const SizedBox(height: VeciEspacio.xs),
        Text(explicacion, style: const TextStyle(fontSize: VeciTexto.subtitulo)),
      ],
    ];
  }
}

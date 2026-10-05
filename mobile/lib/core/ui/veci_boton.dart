import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';

/// Botón de VECI: una piedra de río con canto, como una tecla. Al tocarlo baja y el
/// canto se achica, así se siente en el dedo aunque no se mire. Ocupa el ancho y mide
/// 56 px (72 px en [grande]). [peligro] usa esquinas cortadas: no se puede deshacer.
class VeciBoton extends StatefulWidget {
  const VeciBoton({
    super.key,
    required this.texto,
    required this.alTocar,
    this.icono,
    this.grande = false,
    this.secundario = false,
    this.peligro = false,
  });

  final String texto;
  final VoidCallback? alTocar;
  final IconData? icono;
  final bool grande;
  final bool secundario;
  final bool peligro;

  @override
  State<VeciBoton> createState() => _VeciBotonState();
}

class _VeciBotonState extends State<VeciBoton> {
  bool _abajo = false;

  void _presionar(bool abajo) {
    if (widget.alTocar != null && abajo != _abajo) setState(() => _abajo = abajo);
  }

  ({Color fondo, Color texto, Color canto, BorderSide borde}) get _colores {
    if (widget.alTocar == null) {
      return (
        fondo: VeciColores.arcillaClaro,
        texto: VeciColores.tintaSuave,
        canto: VeciColores.borde,
        borde: BorderSide.none,
      );
    }
    if (widget.peligro) {
      return (
        fondo: VeciColores.error,
        texto: VeciColores.superficie,
        canto: VeciColores.errorOscuro,
        borde: BorderSide.none,
      );
    }
    if (widget.secundario) {
      return (
        fondo: VeciColores.superficie,
        texto: VeciColores.selvaOscuro,
        canto: VeciColores.tinta,
        borde: const BorderSide(color: VeciColores.tinta, width: 3),
      );
    }
    return (
      fondo: VeciColores.selva,
      texto: VeciColores.superficie,
      canto: VeciColores.selvaOscuro,
      borde: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alto = widget.grande ? VeciToque.botonGrande : VeciToque.boton;
    final c = _colores;
    final forma = widget.peligro
        ? VeciFormas.chaflan(side: c.borde)
        : VeciFormas.piedra(side: c.borde);
    final bajada = _abajo ? VeciForma.canto - VeciForma.cantoPresionado : 0.0;
    final duracion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 70);
    return Listener(
      onPointerDown: (_) => _presionar(true),
      onPointerUp: (_) => _presionar(false),
      onPointerCancel: (_) => _presionar(false),
      child: SizedBox(
        height: alto + VeciForma.canto,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: alto,
              child: DecoratedBox(
                decoration: ShapeDecoration(color: c.canto, shape: forma),
              ),
            ),
            AnimatedPositioned(
              duration: duracion,
              left: 0,
              right: 0,
              top: bajada,
              height: alto,
              child: _boton(alto, c.fondo, c.texto, forma),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boton(double alto, Color fondo, Color texto, OutlinedBorder forma) {
    final estilo = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(alto)),
      backgroundColor: WidgetStatePropertyAll(fondo),
      foregroundColor: WidgetStatePropertyAll(texto),
      shape: WidgetStatePropertyAll(forma),
      side: WidgetStatePropertyAll(forma.side),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: widget.grande ? VeciTexto.titulo : VeciTexto.subtitulo,
          fontWeight: VeciPeso.fuerte,
        ),
      ),
    );
    final etiqueta = Text(widget.texto, textAlign: TextAlign.center);
    final icono = widget.icono == null ? null : Icon(widget.icono, size: widget.grande ? 32 : 24);
    if (widget.secundario) {
      return OutlinedButton.icon(
        onPressed: widget.alTocar,
        style: estilo,
        icon: icono,
        label: etiqueta,
      );
    }
    return FilledButton.icon(
      onPressed: widget.alTocar,
      style: estilo,
      icon: icono,
      label: etiqueta,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/lectura_qr.dart';
import '../providers/lectura_qr_controller.dart';
import 'mensajes_clientes.dart';

/// Lo que va en el mostrador mientras se escanea: la indicación, la confirmación
/// "¿Es Luz Marina C.?" o el mensaje de un QR que no sirve.
class PanelLectura extends StatelessWidget {
  const PanelLectura({
    super.key,
    required this.paso,
    required this.alAfiliar,
    required this.alOtraVez,
  });

  final PasoLectura paso;
  final VoidCallback alAfiliar;
  final VoidCallback alOtraVez;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: switch (paso) {
      Mirando() => [_texto('Apunta la cámara al QR del cliente.')],
      Consultando() || ListoParaFicha() => [_esperando('Buscando de quién es…')],
      Afiliando(:final lectura) => [_esperando('Afiliando a ${lectura.persona.nombre}…')],
      Leido(lectura: PorAfiliar(:final persona)) => _confirmar(persona),
      Leido(:final lectura) => _noSirve(mensajeDeLectura(lectura) ?? ''),
      LecturaFallida(:final mensaje) => _noSirve(mensaje),
    },
  );

  List<Widget> _confirmar(PersonaEncontrada persona) => [
    VeciTarjeta(
      child: Column(
        children: [
          Text(
            '¿Es ${persona.nombre}?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
          ),
          const SizedBox(height: VeciEspacio.xs),
          Text(
            'Cédula ${persona.documento}',
            style: const TextStyle(fontSize: VeciTexto.subtitulo),
          ),
        ],
      ),
    ),
    const SizedBox(height: VeciEspacio.m),
    VeciBoton(texto: 'Sí, afiliar', icono: Icons.check, grande: true, alTocar: alAfiliar),
    const SizedBox(height: VeciEspacio.s),
    VeciBoton(texto: 'No es', secundario: true, alTocar: alOtraVez),
  ];

  List<Widget> _noSirve(String mensaje) => [
    VeciAviso(tono: TonoAviso.aviso, mensaje: mensaje),
    const SizedBox(height: VeciEspacio.m),
    VeciBoton(texto: 'Escanear otro', icono: Icons.qr_code_scanner, alTocar: alOtraVez),
  ];

  Widget _texto(String texto) => Padding(
    padding: const EdgeInsets.symmetric(vertical: VeciEspacio.m),
    child: Text(
      texto,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: VeciTexto.subtitulo),
    ),
  );

  Widget _esperando(String texto) => Column(
    children: [
      const SizedBox(height: VeciEspacio.s),
      const CircularProgressIndicator(),
      _texto(texto),
    ],
  );
}

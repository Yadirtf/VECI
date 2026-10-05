import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_pin.dart';
import '../../../../core/ui/veci_saldo.dart';
import '../../../../core/ui/veci_sello.dart';
import '../../../../core/ui/veci_tarjeta.dart';

/// Muestra los componentes base de VECI para revisarlos al sol (HU-01-09). La forma
/// dice qué es: papelito = VECI te habla, piedra = lo que tú haces, chaflán = cuidado,
/// colilla = saldo, arco = dónde estás.
class MuestrarioPage extends StatefulWidget {
  const MuestrarioPage({super.key});

  @override
  State<MuestrarioPage> createState() => _MuestrarioPageState();
}

class _MuestrarioPageState extends State<MuestrarioPage> {
  static const _espacio = SizedBox(height: VeciEspacio.l);
  final _pin = TextEditingController(text: '482');
  int _consumos = 0;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sistema de diseño')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        VeciEspacio.m,
        VeciEspacio.xl,
        VeciEspacio.m,
        VeciEspacio.xl,
      ),
      children: [..._caja(12 - _consumos), ..._piezas()],
    ),
  );

  List<Widget> _caja(int quedan) => [
    const VeciTarjeta(
      perforado: true,
      child: Text(
        'Así habla VECI: en papelitos de talonario. Toca «Registrar almuerzo» para ver el sello.',
        style: TextStyle(fontSize: VeciTexto.subtitulo),
      ),
    ),
    _espacio,
    VeciSaldo(unidades: quedan, singular: 'almuerzo', plural: 'almuerzos', total: 20),
    _espacio,
    if (_consumos > 0) ...[
      Center(
        key: ValueKey(_consumos),
        child: VeciSello(
          arriba: '¡Listo, veci!',
          cifra: '$quedan',
          abajo: quedan == 1 ? 'almuerzo' : 'almuerzos',
          semilla: 'consumo-$_consumos',
        ),
      ),
      _espacio,
    ],
    VeciBoton(
      texto: 'Registrar almuerzo',
      icono: Icons.qr_code_scanner,
      grande: true,
      alTocar: quedan > 0 ? () => setState(() => _consumos++) : null,
    ),
  ];

  List<Widget> _piezas() => [
    _espacio,
    VeciBoton(texto: 'Vender tiquetera', icono: Icons.sell, alTocar: () {}),
    _espacio,
    VeciBoton(texto: 'Buscar cliente', icono: Icons.search, secundario: true, alTocar: () {}),
    _espacio,
    VeciBoton(texto: 'Anular venta', icono: Icons.block, peligro: true, alTocar: () {}),
    _espacio,
    const VeciAviso(tono: TonoAviso.exito, mensaje: '¡Listo, veci! Te quedan 12 almuerzos.'),
    _espacio,
    const VeciAviso(tono: TonoAviso.aviso, mensaje: '¡Ojo, veci! Le quedan 2 almuerzos.'),
    _espacio,
    const VeciAviso(tono: TonoAviso.error, mensaje: 'Este QR es de otro negocio.'),
    _espacio,
    const TextField(
      decoration: InputDecoration(labelText: 'Celular del cliente', hintText: '310 000 0000'),
      keyboardType: TextInputType.phone,
    ),
    _espacio,
    VeciPin(etiqueta: 'PIN', controlador: _pin, ayuda: 'Cada número perfora una casilla.'),
  ];
}

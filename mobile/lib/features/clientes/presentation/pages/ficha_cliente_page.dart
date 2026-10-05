import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/clientes_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../domain/entities/ficha_cliente.dart';
import '../providers/ficha_cliente_providers.dart';
import '../rutas_clientes.dart';
import '../widgets/mensajes_clientes.dart';
import '../widgets/pin_para_dictar.dart';
import '../widgets/tarjeta_ficha.dart';

/// Cómo se llegó a la ficha, para celebrarlo arriba.
enum AvisoFicha { afiliado, yaEsCliente, registrado }

/// Ficha del cliente (HU-04-03): sus datos como los manda la API y, si aún no activa
/// su app, el botón para darle un PIN de bienvenida.
class FichaClientePage extends ConsumerStatefulWidget {
  const FichaClientePage({super.key, required this.clienteId, this.aviso});

  final String clienteId;
  final AvisoFicha? aviso;

  @override
  ConsumerState<FichaClientePage> createState() => _FichaClientePageState();
}

class _FichaClientePageState extends ConsumerState<FichaClientePage> {
  String? _pin;
  var _ocupado = false;
  String? _problema;

  static const _avisos = {
    AvisoFicha.afiliado: '¡Listo, veci! Ya es cliente de tu negocio.',
    AvisoFicha.yaEsCliente: 'Ya es cliente de tu negocio.',
    AvisoFicha.registrado: '¡Listo, veci! Quedó registrado en tu negocio.',
  };

  Future<void> _darPin() async {
    setState(() {
      _ocupado = true;
      _problema = null;
    });
    try {
      final pin = await ref.read(clientesRepositoryProvider).darPinDeBienvenida(widget.clienteId);
      if (mounted) setState(() => _pin = pin);
    } on Object catch (error) {
      if (mounted) setState(() => _problema = mensajeConSenal(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ficha = ref.watch(fichaClienteProvider(widget.clienteId));
    final aviso = widget.aviso;
    final pin = _pin;
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha del cliente')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeciEspacio.m),
              children: [
                if (aviso != null) ...[
                  VeciAviso(tono: TonoAviso.exito, mensaje: _avisos[aviso]!),
                  const SizedBox(height: VeciEspacio.m),
                ],
                if (pin != null) ...[
                  PinParaDictar(pin: pin),
                  const SizedBox(height: VeciEspacio.m),
                ],
                ..._contenido(ficha),
              ],
            ),
          ),
          VeciMostrador(children: _acciones(ficha.value)),
        ],
      ),
    );
  }

  List<Widget> _contenido(AsyncValue<FichaCliente> ficha) => switch (ficha) {
    AsyncData(:final value) => [
      TarjetaFicha(ficha: value),
      if (_problema != null) ...[
        const SizedBox(height: VeciEspacio.m),
        VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
      ],
    ],
    AsyncError(:final error) => [
      VeciAviso(tono: TonoAviso.aviso, mensaje: mensajeConSenal(error)),
      const SizedBox(height: VeciEspacio.m),
      VeciBoton(
        texto: 'Intentar de nuevo',
        icono: Icons.refresh,
        secundario: true,
        alTocar: () => ref.invalidate(fichaClienteProvider(widget.clienteId)),
      ),
    ],
    _ => const [Center(child: CircularProgressIndicator())],
  };

  List<Widget> _acciones(FichaCliente? ficha) => [
    if (ficha != null && ficha.puedeRecibirPin && _pin == null)
      VeciBoton(
        texto: _ocupado ? 'Un momento…' : 'Dar PIN de bienvenida',
        icono: Icons.pin,
        grande: true,
        alTocar: _ocupado ? null : _darPin,
      ),
    VeciBoton(
      texto: 'Buscar a otro',
      icono: Icons.search,
      secundario: true,
      alTocar: () => context.canPop() ? context.pop() : context.go(RutasClientes.caja),
    ),
  ];
}

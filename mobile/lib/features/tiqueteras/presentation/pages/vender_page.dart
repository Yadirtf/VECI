import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/di/tiqueteras_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../domain/entities/catalogo.dart';
import '../../domain/entities/venta.dart';
import '../../domain/reglas/reglas_venta.dart';
import '../providers/tiqueteras_providers.dart';
import '../widgets/cola_de_ventas.dart';
import '../widgets/eleccion_de_venta.dart';
import '../widgets/resultado_venta.dart';
import '../widgets/textos_tiqueteras.dart';

/// Vender una tiquetera (HU-05-02): qué lleva y cómo pagó. Funciona sin internet con
/// el catálogo guardado; la venta entra a la cola del celular y se envía sola.
class VenderPage extends ConsumerStatefulWidget {
  const VenderPage({super.key, required this.clienteId, this.nombre});

  final String clienteId;
  final String? nombre;

  @override
  ConsumerState<VenderPage> createState() => _VenderPageState();
}

class _VenderPageState extends ConsumerState<VenderPage> {
  final _referencia = TextEditingController();
  late final String _ventaId = ref.read(nuevoIdDeVentaProvider)();
  String? _tipoId;
  String? _medio;
  String? _canal;
  var _ocupado = false;
  String? _problema;
  (VentaEnCaja, ResultadoVenta)? _hecha;

  @override
  void dispose() {
    _referencia.dispose();
    super.dispose();
  }

  Future<void> _cobrar(CatalogoDeVenta catalogo) async {
    final tipo = catalogo.tipos.where((t) => t.tipoId == _tipoId).firstOrNull;
    final medio = catalogo.medios.where((m) => m.codigo == _medio).firstOrNull;
    final (:pago, :falta) = armarPago(medio, _canal, _referencia.text);
    if (tipo == null || pago == null) {
      setState(() => _problema = tipo == null ? 'Elige cuál tiquetera lleva.' : falta);
      return;
    }
    final venta = VentaEnCaja(
      ventaId: _ventaId,
      clienteId: widget.clienteId,
      nombreCliente: widget.nombre ?? 'Cliente',
      tipo: tipo,
      pago: pago,
      ocurridaEn: ref.read(relojProvider)(),
    );
    setState(() {
      _ocupado = true;
      _problema = null;
    });
    try {
      final resultado = await ref.read(ventasRepositoryProvider).vender(venta);
      ref.invalidate(cuentaDelClienteProvider(widget.clienteId));
      ref.invalidate(ventasPorEnviarProvider);
      if (mounted) setState(() => _hecha = (venta, resultado));
    } on Object catch (error) {
      if (mounted) setState(() => _problema = mensajeDeVenta(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(catalogoDeVentaProvider);
    final hecha = _hecha;
    return Scaffold(
      appBar: AppBar(title: Text('Vender a ${widget.nombre ?? 'tu cliente'}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeciEspacio.m),
              children: hecha == null
                  ? _formulario(catalogo)
                  : [ResultadoDeVenta(venta: hecha.$1, resultado: hecha.$2)],
            ),
          ),
          VeciMostrador(children: _acciones(catalogo.value)),
        ],
      ),
    );
  }

  List<Widget> _formulario(AsyncValue<CatalogoDeVenta> catalogo) => switch (catalogo) {
    AsyncData(:final value) => [
      ..._cola(),
      if (value.sinSenal) ...[
        const VeciAviso(tono: TonoAviso.aviso, mensaje: 'Sin señal: vendes con lo guardado.'),
        const SizedBox(height: VeciEspacio.m),
      ],
      if (value.tipos.isEmpty)
        const VeciAviso(
          tono: TonoAviso.aviso,
          mensaje: 'No hay tiqueteras en venta. El dueño las escribe en la pizarra del panel.',
        )
      else
        EleccionDeVenta(
          catalogo: value,
          tipoId: _tipoId,
          medio: _medio,
          canal: _canal,
          referencia: _referencia,
          alElegirTipo: (v) => setState(() => _tipoId = v),
          alElegirMedio: (v) => setState(() => _medio = v),
          alElegirCanal: (v) => setState(() => _canal = v),
        ),
      if (_problema != null) ...[
        const SizedBox(height: VeciEspacio.m),
        VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
      ],
    ],
    AsyncError(:final error) => [VeciAviso(tono: TonoAviso.error, mensaje: mensajeDeVenta(error))],
    _ => const [Center(child: CircularProgressIndicator())],
  };

  List<Widget> _cola() {
    final ventas = ref.watch(ventasPorEnviarProvider).value ?? const [];
    if (ventas.isEmpty) return const [];
    return [
      ColaDeVentas(
        ventas: ventas,
        alDescartar: (id) async {
          await ref.read(ventasRepositoryProvider).descartar(id);
          ref.invalidate(ventasPorEnviarProvider);
        },
      ),
      const SizedBox(height: VeciEspacio.m),
    ];
  }

  List<Widget> _acciones(CatalogoDeVenta? catalogo) {
    if (_hecha != null) {
      return [VeciBoton(texto: 'Listo', icono: Icons.check, grande: true, alTocar: context.pop)];
    }
    final tipo = catalogo?.tipos.where((t) => t.tipoId == _tipoId).firstOrNull;
    return [
      VeciBoton(
        texto: _ocupado
            ? 'Un momento…'
            : (tipo == null ? 'Cobrar' : 'Cobrar ${pesos(tipo.precio)}'),
        icono: Icons.point_of_sale,
        grande: true,
        alTocar: _ocupado || catalogo == null || catalogo.tipos.isEmpty
            ? null
            : () => _cobrar(catalogo),
      ),
    ];
  }
}

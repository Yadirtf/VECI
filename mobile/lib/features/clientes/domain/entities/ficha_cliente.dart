import 'cliente_en_caja.dart';

/// La ficha de un cliente del negocio, como la manda la API: el cajero recibe el
/// documento y el celular enmascarados; el dueño, completos ([datosCompletos]).
class FichaCliente {
  const FichaCliente({
    required this.clienteId,
    required this.nombre,
    required this.tipoDocumento,
    required this.documento,
    required this.cuenta,
    required this.estado,
    required this.afiliadoEn,
    this.celular,
    this.datosCompletos = false,
  });

  final String clienteId;
  final String nombre;

  /// Código del catálogo: CC, TI, CE...
  final String tipoDocumento;
  final String documento;
  final String? celular;
  final CuentaCliente cuenta;
  final String estado;

  /// Desde cuándo es cliente de este negocio.
  final DateTime afiliadoEn;
  final bool datosCompletos;

  /// Solo quien aún no activa su app recibe un PIN de bienvenida.
  bool get puedeRecibirPin => cuenta == CuentaCliente.pendiente;
}

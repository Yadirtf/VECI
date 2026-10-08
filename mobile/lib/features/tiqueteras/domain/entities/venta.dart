import 'catalogo.dart';
import 'estado_de_cuenta.dart';

class Pago {
  const Pago({required this.medio, this.canal, this.referencia});

  final String medio;
  final String? canal;
  final String? referencia;
}

/// Una venta hecha en la caja. El id lo pone el celular (UUID v7): si se envía dos
/// veces, el servidor la registra una sola vez (ADR-0004).
class VentaEnCaja {
  const VentaEnCaja({
    required this.ventaId,
    required this.clienteId,
    required this.nombreCliente,
    required this.tipo,
    required this.pago,
    required this.ocurridaEn,
  });

  final String ventaId;
  final String clienteId;
  final String nombreCliente;
  final TipoEnVenta tipo;
  final Pago pago;
  final DateTime ocurridaEn;
}

/// Qué pasó al vender: llegó al servidor o quedó guardada para enviarla después.
sealed class ResultadoVenta {
  const ResultadoVenta();
}

final class VentaEnviada extends ResultadoVenta {
  const VentaEnviada(this.cuenta);

  /// El saldo del cliente con la tiquetera nueva.
  final EstadoDeCuenta cuenta;
}

final class VentaGuardada extends ResultadoVenta {
  const VentaGuardada();
}

/// Una venta del celular que aún no llega al servidor, o que el servidor rechazó.
class VentaPorEnviar {
  const VentaPorEnviar({
    required this.ventaId,
    required this.nombreCliente,
    required this.nombreTipo,
    required this.precio,
    required this.ocurridaEn,
    this.rechazo,
  });

  final String ventaId;
  final String nombreCliente;
  final String nombreTipo;
  final int precio;
  final DateTime ocurridaEn;

  /// Por qué el servidor no la aceptó; null mientras espera señal.
  final String? rechazo;
}

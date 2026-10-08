import '../entities/catalogo.dart';
import '../entities/estado_de_cuenta.dart';
import '../entities/venta.dart';

/// Ventas del negocio activo desde la caja (HU-05-02). El catálogo se guarda en el
/// celular y una venta sin señal queda en la cola hasta que haya internet.
abstract interface class VentasRepository {
  Future<CatalogoDeVenta?> catalogoGuardado();

  /// Pregunta al servidor si el catálogo cambió (ETag). Sin señal devuelve el guardado
  /// con [CatalogoDeVenta.sinSenal]; sin copia, lanza el fallo.
  Future<CatalogoDeVenta> actualizarCatalogo();

  /// Saldo, tiqueteras e historia del cliente (necesita señal).
  Future<EstadoDeCuenta> cuenta(String clienteId);

  /// Guarda la venta en la cola y la intenta enviar. Sin señal queda [VentaGuardada];
  /// si el servidor la rechaza, sale de la cola y se lanza el fallo.
  Future<ResultadoVenta> vender(VentaEnCaja venta);

  /// Envía las ventas que esperan señal; devuelve cuántas llegaron.
  Future<int> enviarPendientes();

  Future<List<VentaPorEnviar>> porEnviar();

  /// Saca de la cola una venta que el servidor rechazó.
  Future<void> descartar(String ventaId);
}

/// El saldo de la persona en sus negocios, también sin señal (copia del celular).
abstract interface class MisTiqueterasRepository {
  Future<List<SaldoEnNegocio>?> guardadas();

  Future<List<SaldoEnNegocio>> traer();

  Future<void> olvidar();
}

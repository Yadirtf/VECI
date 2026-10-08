/// Rutas de la app en un solo lugar.
abstract final class Rutas {
  static const cargando = '/cargando';
  static const entrar = '/entrar';
  static const registro = '/registro';
  static const politica = '/politica-de-datos';
  static const pinNuevo = '/pin-nuevo';
  static const negocio = '/negocio';
  static const registrarNegocio = '/negocio/nuevo';

  /// Ajustes de la cuenta: desde aquí se pide registrar un negocio (ADR-0019).
  static const ajustes = '/ajustes';

  /// Las abre cualquiera con sesión, tenga o no negocio: pedir el registro de uno.
  static const deLaCuenta = [ajustes, registrarNegocio];
  static const inicio = '/';
  static const horarios = '/horarios';
  static const disenio = '/disenio';

  /// Lado del cliente (EP-04): su QR personal y los negocios donde es cliente.
  static const miQr = '/mi-qr';
  static const tusNegocios = '/tus-negocios';
  static const qrEnNegocio = '$tusNegocios/:comercioId';

  static String qrDe(String comercioId) => '$tusNegocios/$comercioId';

  /// El saldo de la persona en todos sus negocios (EP-05).
  static const tusTiqueteras = '/tus-tiqueteras';

  /// Caja (EP-05): saldo e historia de un cliente, y venderle una tiquetera (también
  /// sin señal). `?nombre=` lleva su nombre para mostrarlo aunque no haya internet.
  static const saldoDelCliente = '/saldo/:clienteId';
  static const venderTiquetera = '/vender/:clienteId';

  static String saldoDe(String clienteId, {String? nombre}) =>
      Uri(path: '/saldo/$clienteId', queryParameters: _conNombre(nombre)).toString();

  static String venderA(String clienteId, {String? nombre}) =>
      Uri(path: '/vender/$clienteId', queryParameters: _conNombre(nombre)).toString();

  static Map<String, String>? _conNombre(String? nombre) =>
      nombre == null || nombre.isEmpty ? null : {'nombre': nombre};

  /// Entrar con el celular ya escrito (por ejemplo, si al registrarse ya tenía cuenta).
  static String entrarCon(String celular) =>
      Uri(path: entrar, queryParameters: {'celular': celular}).toString();

  /// Pantallas que se ven sin sesión: entrar o crear la cuenta.
  static const sinSesion = [entrar, registro, politica];

  /// Pantallas de antes de tener sesión y negocio: con ambos, se sale de ellas.
  static const deIngreso = [cargando, entrar, registro, politica, pinNuevo, negocio];

  static bool esDelCliente(String ubicacion) =>
      ubicacion == miQr ||
      ubicacion == tusNegocios ||
      ubicacion == tusTiqueteras ||
      ubicacion.startsWith('$tusNegocios/');
}

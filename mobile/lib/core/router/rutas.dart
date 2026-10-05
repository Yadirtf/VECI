/// Rutas de la app en un solo lugar.
abstract final class Rutas {
  static const cargando = '/cargando';
  static const entrar = '/entrar';
  static const registro = '/registro';
  static const politica = '/politica-de-datos';
  static const pinNuevo = '/pin-nuevo';
  static const negocio = '/negocio';
  static const registrarNegocio = '/negocio/nuevo';
  static const inicio = '/';
  static const horarios = '/horarios';
  static const disenio = '/disenio';

  /// Lado del cliente (EP-04): su QR personal y los negocios donde es cliente.
  static const miQr = '/mi-qr';
  static const tusNegocios = '/tus-negocios';
  static const qrEnNegocio = '$tusNegocios/:comercioId';

  static String qrDe(String comercioId) => '$tusNegocios/$comercioId';

  /// Entrar con el celular ya escrito (por ejemplo, si al registrarse ya tenía cuenta).
  static String entrarCon(String celular) =>
      Uri(path: entrar, queryParameters: {'celular': celular}).toString();

  /// Pantallas que se ven sin sesión: entrar o crear la cuenta.
  static const sinSesion = [entrar, registro, politica];

  /// Pantallas de antes de tener sesión y negocio: con ambos, se sale de ellas.
  static const deIngreso = [
    cargando,
    entrar,
    registro,
    politica,
    pinNuevo,
    negocio,
    registrarNegocio,
  ];

  static bool esDelCliente(String ubicacion) =>
      ubicacion == miQr || ubicacion == tusNegocios || ubicacion.startsWith('$tusNegocios/');
}

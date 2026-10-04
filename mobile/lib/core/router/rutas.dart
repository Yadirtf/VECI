/// Rutas de la app en un solo lugar.
abstract final class Rutas {
  static const cargando = '/cargando';
  static const entrar = '/entrar';
  static const pinNuevo = '/pin-nuevo';
  static const negocio = '/negocio';
  static const inicio = '/';
  static const horarios = '/horarios';
  static const disenio = '/disenio';

  /// Pantallas de antes de tener sesión y negocio: con ambos, se sale de ellas.
  static const deIngreso = [cargando, entrar, pinNuevo, negocio];
}

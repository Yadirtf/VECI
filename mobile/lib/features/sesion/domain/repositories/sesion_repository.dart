import '../entities/sesion.dart';

/// Cómo la app abre, renueva y cierra sesiones; data/ decide por dónde.
abstract interface class SesionRepository {
  Future<ResultadoIngreso> entrarConPin(String celular, String pin);

  Future<SesionAbierta> crearPinNuevo(String tokenCambio, String pinNuevo);

  /// null si la sesión ya no existe (se cerró desde el panel, venció o la reusaron).
  Future<SesionAbierta?> renovar(String tokenRenovacion);

  Future<void> elegirComercio(String tokenAcceso, String comercioId);

  Future<void> salir(String tokenAcceso);
}

/// Lo que sobrevive a cerrar la app, guardado cifrado (Android Keystore). Guardar la
/// sesión completa (no solo el token) deja trabajar a la caja sin internet al abrir.
abstract interface class AlmacenSesion {
  Future<SesionAbierta?> leerSesion();

  Future<void> guardarSesion(SesionAbierta? sesion);

  Future<String?> leerComercio();

  Future<void> guardarComercio(String? comercioId);
}

/// Ventas y consumos guardados en el celular que aún no llegan al servidor (EP-07).
abstract interface class EventosPendientes {
  Future<int> contar();
}

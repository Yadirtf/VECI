/// Configuración de red que llega con --dart-define al compilar.
class ApiConfig {
  const ApiConfig({
    required this.urlBase,
    required this.comercioId,
    required this.usuarioDesarrolloId,
  });

  /// Sin VECI_API la app usa el computador visto desde el emulador de Android.
  factory ApiConfig.desdeEntorno() => const ApiConfig(
    urlBase: String.fromEnvironment('VECI_API', defaultValue: 'http://10.0.2.2:3000'),
    comercioId: String.fromEnvironment(
      'VECI_COMERCIO',
      defaultValue: 'd1000000-0000-7000-8000-000000000001',
    ),
    usuarioDesarrolloId: String.fromEnvironment(
      'VECI_USUARIO_DESARROLLO',
      defaultValue: 'd4000000-0000-7000-8000-000000000002',
    ),
  );

  final String urlBase;

  /// Negocio activo hasta que el inicio de sesión (EP-02) lo elija.
  final String comercioId;

  /// Solo desarrollo y staging, hasta EP-02.
  final String usuarioDesarrolloId;
}

/// Configuración de red que llega con --dart-define al compilar.
class ApiConfig {
  const ApiConfig({required this.urlBase});

  /// Sin VECI_API la app usa el computador visto desde el emulador de Android.
  factory ApiConfig.desdeEntorno() => const ApiConfig(
    urlBase: String.fromEnvironment('VECI_API', defaultValue: 'http://10.0.2.2:3000'),
  );

  final String urlBase;
}

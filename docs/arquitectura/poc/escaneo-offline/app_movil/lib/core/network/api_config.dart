/// Dirección del servidor de prueba. Se cambia al compilar:
/// `flutter run --dart-define=VECI_API=http://192.168.1.20:3000`
class ApiConfig {
  const ApiConfig({required this.baseUrl, this.timeout = const Duration(seconds: 15)});

  factory ApiConfig.fromEnvironment() => const ApiConfig(
    baseUrl: String.fromEnvironment('VECI_API', defaultValue: 'http://10.0.2.2:3000'),
  );

  final String baseUrl;
  final Duration timeout;

  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);
}

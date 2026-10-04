/// La red falló o el servidor no respondió: el lote se reintenta después.
class NetworkFailure implements Exception {
  const NetworkFailure(this.message);

  final String message;

  @override
  String toString() => 'NetworkFailure: $message';
}

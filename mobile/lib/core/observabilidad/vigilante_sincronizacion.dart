/// Avisa cuando la sincronización falla varias veces seguidas (HU-01-07).
/// Un fallo aislado es normal sin señal; varios seguidos merecen una alerta.
class VigilanteSincronizacion {
  VigilanteSincronizacion({required this.alertar, this.umbral = 3});

  /// Recibe cuántos fallos seguidos van; la implementación lo envía a Sentry.
  final void Function(int fallosSeguidos, Object ultimoError) alertar;
  final int umbral;
  int _fallosSeguidos = 0;

  int get fallosSeguidos => _fallosSeguidos;

  void registrarExito() => _fallosSeguidos = 0;

  void registrarFallo(Object error) {
    _fallosSeguidos++;
    if (_fallosSeguidos == umbral || (_fallosSeguidos > umbral && _fallosSeguidos % umbral == 0)) {
      alertar(_fallosSeguidos, error);
    }
  }
}

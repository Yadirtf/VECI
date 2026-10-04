/// Tiempos de un escaneo, para comprobar RNF-REN-01 (3 segundos o menos).
class ScanTiming {
  const ScanTiming({required this.cameraToResult, required this.detectToResult});

  /// Desde que se abre la cámara hasta ver el resultado.
  final Duration cameraToResult;

  /// Desde que la cámara lee el QR hasta que el consumo queda guardado.
  final Duration detectToResult;
}

/// Resumen de varios escaneos: mediana, percentil 95 y peor caso.
class ScanTimingSummary {
  ScanTimingSummary(List<ScanTiming> timings)
    : count = timings.length,
      _camera = timings.map((t) => t.cameraToResult).toList()..sort(),
      _detect = timings.map((t) => t.detectToResult).toList()..sort();

  static const target = Duration(seconds: 3);

  final int count;
  final List<Duration> _camera;
  final List<Duration> _detect;

  Duration get cameraP50 => _percentile(_camera, 0.5);
  Duration get cameraP95 => _percentile(_camera, 0.95);
  Duration get cameraMax => _camera.isEmpty ? Duration.zero : _camera.last;
  Duration get detectP50 => _percentile(_detect, 0.5);
  Duration get detectP95 => _percentile(_detect, 0.95);
  int get withinTarget => _camera.where((d) => d <= target).length;

  static Duration _percentile(List<Duration> sorted, double p) {
    if (sorted.isEmpty) return Duration.zero;
    final index = ((sorted.length - 1) * p).round();
    return sorted[index];
  }
}

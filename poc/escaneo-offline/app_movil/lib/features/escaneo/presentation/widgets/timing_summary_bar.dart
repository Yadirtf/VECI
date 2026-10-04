import 'package:flutter/material.dart';

import '../providers/scan_timing.dart';

/// Barra con la medición acumulada de la prueba de rendimiento.
class TimingSummaryBar extends StatelessWidget {
  const TimingSummaryBar({super.key, required this.summary, required this.onClear});

  final ScanTimingSummary summary;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (summary.count == 0) {
      return const ListTile(dense: true, title: Text('Aún no hay escaneos medidos'));
    }
    return ListTile(
      dense: true,
      title: Text('${summary.count} escaneos · ${summary.withinTarget} en 3 s o menos'),
      subtitle: Text(
        'Cámara→resultado p50 ${_ms(summary.cameraP50)} · p95 ${_ms(summary.cameraP95)} · '
        'máx ${_ms(summary.cameraMax)}\n'
        'Lectura→guardado p50 ${_ms(summary.detectP50)} · p95 ${_ms(summary.detectP95)}',
      ),
      trailing: IconButton(icon: const Icon(Icons.restart_alt), onPressed: onClear),
    );
  }

  static String _ms(Duration d) => '${d.inMilliseconds} ms';
}

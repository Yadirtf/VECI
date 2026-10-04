import 'package:flutter/material.dart';

import '../../domain/entities/scan_outcome.dart';
import '../providers/scan_timing.dart';

/// Resultado del escaneo con lenguaje cercano: verde si pasa, tierra si no.
class ScanResultCard extends StatelessWidget {
  const ScanResultCard({super.key, required this.outcome, this.timing, required this.onNext});

  final ScanOutcome outcome;
  final ScanTiming? timing;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accepted = outcome is ScanAccepted;
    final color = accepted ? scheme.primary : scheme.secondary;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(accepted ? Icons.check_circle : Icons.error, color: color, size: 72),
            const SizedBox(height: 12),
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_detail, textAlign: TextAlign.center),
            if (timing != null) ...[
              const SizedBox(height: 12),
              Text(_timingText(timing!), style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onNext, child: const Text('Escanear otro')),
          ],
        ),
      ),
    );
  }

  String get _title => switch (outcome) {
    ScanAccepted() => '¡Listo, buen provecho!',
    ScanRejected() => 'Este QR no sirve aquí',
  };

  String get _detail => switch (outcome) {
    ScanAccepted(:final eventId) =>
      'Consumo guardado en el celular.\nSe enviará cuando haya internet.\nId: ${eventId.substring(0, 13)}…',
    ScanRejected(:final reason) => reason.message,
  };

  static String _timingText(ScanTiming t) =>
      'Cámara a resultado: ${t.cameraToResult.inMilliseconds} ms · '
      'Lectura a guardado: ${t.detectToResult.inMilliseconds} ms';
}

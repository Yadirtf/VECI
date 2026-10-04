import 'package:flutter/material.dart';

import '../../domain/entities/sync_report.dart';

/// Informe de la última sincronización y conteo del servidor.
class SyncReportCard extends StatelessWidget {
  const SyncReportCard({super.key, required this.report, this.serverStats});

  final SyncReport report;
  final Map<String, num>? serverStats;

  @override
  Widget build(BuildContext context) {
    final stats = serverStats;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Última sincronización', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Lotes con respuesta: ${report.batchesSent}'),
            Text('Envíos sin respuesta (reintentados): ${report.failedAttempts}'),
            Text('Eventos confirmados: ${report.eventsConfirmed}'),
            Text('Ya los tenía el servidor (reintentos): ${report.replayedByServer}'),
            Text('Rechazados: ${report.rejectedByServer}'),
            Text('Duración: ${(report.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} s'),
            if (stats != null) ...[
              const Divider(),
              Text('En el servidor', style: Theme.of(context).textTheme.titleMedium),
              Text('Eventos únicos guardados: ${stats['eventosUnicos']}'),
              Text('Entregas recibidas: ${stats['entregasRecibidas']}'),
              Text('Reenvíos detectados: ${stats['reenviosDetectados']}'),
              Text('Fuera de orden: ${stats['eventosFueraDeOrden']}'),
            ],
          ],
        ),
      ),
    );
  }
}

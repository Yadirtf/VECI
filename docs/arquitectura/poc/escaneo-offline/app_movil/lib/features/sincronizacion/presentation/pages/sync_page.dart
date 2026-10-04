import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_controller.dart';
import '../widgets/outbox_counts_card.dart';
import '../widgets/sync_report_card.dart';

/// Bajada de datos, envío de la bandeja y prueba de 1.000 eventos.
class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final enabled = !state.busy;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const OutboxCountsCard(),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: enabled ? controller.pullOfflineData : null,
          icon: const Icon(Icons.download),
          label: const Text('Bajar datos del negocio'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: enabled ? controller.sync : null,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Enviar pendientes'),
        ),
        SwitchListTile(
          value: state.simulateCuts,
          onChanged: enabled ? controller.toggleCuts : null,
          title: const Text('Simular cortes de señal'),
          subtitle: Text(
            'El servidor corta la respuesta del ${(simulatedCutRate * 100).round()} % de los lotes',
          ),
        ),
        const Divider(),
        Text('Prueba de 1.000 eventos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: enabled ? controller.generateLoad : null,
          child: const Text('Guardar 1.000 consumos sin internet'),
        ),
        OutlinedButton(
          onPressed: enabled ? controller.resetAll : null,
          child: const Text('Reiniciar prueba (celular y servidor)'),
        ),
        if (state.busy)
          const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
        if (state.message != null)
          Padding(padding: const EdgeInsets.all(8), child: Text(state.message!)),
        if (state.report != null)
          SyncReportCard(report: state.report!, serverStats: state.serverStats),
      ],
    );
  }
}

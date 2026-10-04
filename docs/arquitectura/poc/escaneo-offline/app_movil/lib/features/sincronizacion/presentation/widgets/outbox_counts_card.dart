import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sincronizacion_providers.dart';

/// Cuántos eventos esperan en el celular y cuántos ya confirmó el servidor.
class OutboxCountsCard extends ConsumerWidget {
  const OutboxCountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(outboxCountsProvider).value;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Count(label: 'Por enviar', value: counts?.pending ?? 0, style: text.headlineMedium),
            _Count(label: 'Confirmados', value: counts?.applied ?? 0, style: text.headlineMedium),
            _Count(label: 'Rechazados', value: counts?.rejected ?? 0, style: text.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, this.style});

  final String label;
  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: style),
      Text(label),
    ],
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/escaneo_providers.dart';
import '../../../../core/di/sincronizacion_providers.dart';
import '../../domain/entities/sync_report.dart';
import '../../domain/usecases/sincronizar_bandeja.dart';

/// Fracción de lotes cuya respuesta se corta cuando se simulan cortes.
const simulatedCutRate = 0.3;

class SyncUiState {
  const SyncUiState({
    this.busy = false,
    this.message,
    this.report,
    this.serverStats,
    this.simulateCuts = false,
  });

  final bool busy;
  final String? message;
  final SyncReport? report;
  final Map<String, num>? serverStats;
  final bool simulateCuts;

  SyncUiState copyWith({
    bool? busy,
    String? message,
    SyncReport? report,
    Map<String, num>? serverStats,
    bool? simulateCuts,
  }) => SyncUiState(
    busy: busy ?? this.busy,
    message: message ?? this.message,
    report: report ?? this.report,
    serverStats: serverStats ?? this.serverStats,
    simulateCuts: simulateCuts ?? this.simulateCuts,
  );
}

class SyncController extends Notifier<SyncUiState> {
  @override
  SyncUiState build() => const SyncUiState();

  void toggleCuts(bool value) => state = state.copyWith(simulateCuts: value);

  Future<void> pullOfflineData() => _run(() async {
    final data = await ref.read(bajarDatosOfflineProvider)();
    return 'Datos del negocio listos: ${data.keys.length} clave(s) y '
        '${data.revokedQrCodeIds.length} QR revocado(s). Ya puedes cobrar sin internet.';
  });

  Future<void> generateLoad() => _run(() async {
    final created = await ref.read(generarConsumosDePruebaProvider)();
    return created == 0
        ? 'Primero baja los datos del negocio.'
        : '$created consumos guardados en el celular, sin internet.';
  });

  Future<void> sync() => _run(() async {
    final params = SincronizarBandejaParams(
      simulatedCutRate: state.simulateCuts ? simulatedCutRate : 0,
    );
    final report = await ref.read(sincronizarBandejaProvider)(params);
    state = state.copyWith(report: report);
    await _refreshStats();
    return report.completed
        ? 'Todo enviado.'
        : 'Quedaron pendientes: ${report.lastError ?? 'sin conexión'}.';
  });

  Future<void> resetAll() => _run(() async {
    await ref.read(outboxRepositoryProvider).clear();
    await ref.read(syncRemoteProvider).resetServer();
    state = const SyncUiState();
    return 'Bandeja y servidor en cero.';
  });

  Future<void> _refreshStats() async {
    try {
      state = state.copyWith(serverStats: await ref.read(syncRemoteProvider).fetchServerStats());
    } on Exception {
      // Sin red no hay estadísticas; el informe local sigue siendo válido.
    }
  }

  Future<void> _run(Future<String> Function() action) async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      state = state.copyWith(busy: false, message: await action());
    } on Object catch (e) {
      state = state.copyWith(busy: false, message: 'No se pudo: $e');
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncUiState>(SyncController.new);

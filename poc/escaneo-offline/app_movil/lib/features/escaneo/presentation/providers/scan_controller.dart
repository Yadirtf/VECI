import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/escaneo_providers.dart';
import '../../domain/entities/scan_outcome.dart';
import 'scan_timing.dart';

enum ScanPhase { scanning, processing, showingResult }

class ScanState {
  const ScanState({this.phase = ScanPhase.scanning, this.outcome, this.timings = const []});

  final ScanPhase phase;
  final ScanOutcome? outcome;
  final List<ScanTiming> timings;

  ScanTiming? get lastTiming => timings.isEmpty ? null : timings.last;
}

/// Orquesta la pantalla de cobro: recibe la lectura de la cámara, ejecuta el
/// caso de uso y mide cuánto tardó.
class ScanController extends Notifier<ScanState> {
  final _sinceCamera = Stopwatch();

  @override
  ScanState build() => const ScanState();

  /// La pantalla llama esto justo antes de encender la cámara.
  void cameraOpening() {
    _sinceCamera
      ..reset()
      ..start();
    state = ScanState(timings: state.timings);
  }

  Future<void> onDetected(String raw) async {
    if (state.phase != ScanPhase.scanning) return;
    state = ScanState(phase: ScanPhase.processing, timings: state.timings);
    final sinceDetect = Stopwatch()..start();
    final outcome = await ref.read(registrarConsumoPorQrProvider)(raw);
    final timing = ScanTiming(
      cameraToResult: _sinceCamera.elapsed,
      detectToResult: sinceDetect.elapsed,
    );
    state = ScanState(
      phase: ScanPhase.showingResult,
      outcome: outcome,
      timings: [...state.timings, timing],
    );
  }

  void clearTimings() => state = ScanState(phase: state.phase, outcome: state.outcome);
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(ScanController.new);

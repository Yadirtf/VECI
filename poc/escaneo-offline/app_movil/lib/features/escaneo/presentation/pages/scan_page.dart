import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/scan_controller.dart';
import '../providers/scan_timing.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/timing_summary_bar.dart';

/// Pantalla de cobro: cámara, resultado y medición de tiempos.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  // 640x480 y solo QR: menos trabajo para celulares de 2 GB (RNF-REN-01).
  final _camera = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    cameraResolution: const Size(640, 480),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scanControllerProvider.notifier).cameraOpening());
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    await ref.read(scanControllerProvider.notifier).onDetected(raw);
    await _camera.stop();
  }

  Future<void> _scanAgain() async {
    ref.read(scanControllerProvider.notifier).cameraOpening();
    await _camera.start();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanControllerProvider);
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(controller: _camera, onDetect: _onDetect),
              if (state.phase == ScanPhase.processing)
                const Center(child: CircularProgressIndicator()),
              if (state.phase == ScanPhase.showingResult && state.outcome != null)
                Center(
                  child: ScanResultCard(
                    outcome: state.outcome!,
                    timing: state.lastTiming,
                    onNext: _scanAgain,
                  ),
                ),
            ],
          ),
        ),
        TimingSummaryBar(
          summary: ScanTimingSummary(state.timings),
          onClear: ref.read(scanControllerProvider.notifier).clearTimings,
        ),
      ],
    );
  }
}

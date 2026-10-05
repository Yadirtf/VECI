import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/clientes_providers.dart';
import '../../domain/entities/cliente_en_caja.dart';

/// La copia de clientes para la ranura: primero la del celular (al instante, sin
/// internet) y enseguida pregunta al servidor si cambió. Se vuelve a construir, y
/// así a revisar, al abrir la caja y cada vez que se afilia o registra a alguien.
final copiaDeClientesProvider =
    AsyncNotifierProvider.autoDispose<CopiaDeClientesController, CopiaDeClientes>(
      CopiaDeClientesController.new,
    );

class CopiaDeClientesController extends AsyncNotifier<CopiaDeClientes> {
  @override
  Future<CopiaDeClientes> build() async {
    final guardada = await ref.watch(clientesRepositoryProvider).copiaGuardada();
    unawaited(Future.microtask(actualizar));
    return guardada;
  }

  /// Revisa la copia con el servidor. Si algo falla, se queda con la guardada.
  Future<void> actualizar() async {
    final repositorio = ref.read(clientesRepositoryProvider);
    CopiaDeClientes copia;
    try {
      copia = await repositorio.actualizarCopia();
    } on Object {
      final guardada = await repositorio.copiaGuardada();
      copia = CopiaDeClientes(
        clientes: guardada.clientes,
        alDiaEn: guardada.alDiaEn,
        sinSenal: true,
      );
    }
    if (ref.mounted) state = AsyncData(copia);
  }
}
